import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const WORKER_SECRET = Deno.env.get("PUSH_WORKER_SECRET")!;

const FCM_PROJECT_ID = Deno.env.get("FCM_PROJECT_ID")!;

const ADMIN_WEB_URL = Deno.env.get("ADMIN_WEB_URL")!;

const QUEUE = "enquiry_push";
const BATCH_SIZE = 5000;

const supabase = createClient(
  SUPABASE_URL,
  SERVICE_ROLE_KEY,
  {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  },
);

interface QueueMessage {
  msg_id: number;
  message: {
    enquiry_id: string;
    reference_code?: string;
  };
}

interface FcmDevice {
  id: string;
  fcm_token: string;
  platform: string;
}

interface ServiceAccount {
  client_email: string;
  private_key: string;
  token_uri: string;
}

let cachedAccessToken: string | null = null;
let tokenExpiresAt = 0;

// ========================================
// BASE64 URL ENCODING
// ========================================

function base64Url(input: string | Uint8Array): string {
  const bytes = typeof input === "string"
    ? new TextEncoder().encode(input)
    : input;

  let binary = "";

  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }

  return btoa(binary)
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

// ========================================
// GOOGLE SERVICE ACCOUNT JWT
// ========================================

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const base64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s/g, "");

  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);

  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }

  return bytes.buffer;
}

// ========================================
// GET GOOGLE OAUTH ACCESS TOKEN
// ========================================

async function getGoogleAccessToken(): Promise<string> {
  if (
    cachedAccessToken &&
    Date.now() < tokenExpiresAt - 60000
  ) {
    return cachedAccessToken;
  }

  const serviceAccount: ServiceAccount = JSON.parse(
    Deno.env.get("FCM_SERVICE_ACCOUNT_JSON")!,
  );

  const now = Math.floor(Date.now() / 1000);

  const header = base64Url(
    JSON.stringify({
      alg: "RS256",
      typ: "JWT",
    }),
  );

  const claims = base64Url(
    JSON.stringify({
      iss: serviceAccount.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: serviceAccount.token_uri ||
        "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    }),
  );

  const unsignedToken = `${header}.${claims}`;

  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(
      serviceAccount.private_key.replace(/\\n/g, "\n"),
    ),
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    new TextEncoder().encode(unsignedToken),
  );

  const assertion = `${unsignedToken}.${base64Url(new Uint8Array(signature))}`;

  const response = await fetch(
    "https://oauth2.googleapis.com/token",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion,
      }),
    },
  );

  if (!response.ok) {
    throw new Error(
      `Google OAuth failed: ${await response.text()}`,
    );
  }

  const result = await response.json();

  cachedAccessToken = result.access_token;
  tokenExpiresAt = Date.now() + result.expires_in * 1000;

  return cachedAccessToken!;
}

// ========================================
// SEND FCM HTTP V1
// ========================================

async function sendFcm(
  device: FcmDevice,
  title: string,
  body: string,
  data: Record<string, string>,
  accessToken: string,
): Promise<void> {
  const webLink = `${ADMIN_WEB_URL}/#/enquiries`;

  const message: Record<string, unknown> = {
    token: device.fcm_token,

    notification: {
      title,
      body,
    },

    data: {
      ...data,
      link: webLink,
    },

    android: {
      priority: "high",
      notification: {
        channel_id: "enquiries",
        sound: "default",
        tag: "tribe-green-enquiries",
      },
    },

    apns: {
      headers: {
        "apns-priority": "10",
      },
      payload: {
        aps: {
          sound: "default",
        },
      },
    },

    webpush: {
      headers: {
        Urgency: "high",
      },
      fcm_options: {
        link: webLink,
      },
      notification: {
        icon: "/icons/Icon-192.png",
        tag: "tribe-green-enquiries",
      },
    },
  };

  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message,
      }),
    },
  );

  if (!response.ok) {
    const errorBody = await response.text();

    // Remove permanently invalid registration tokens.
    if (
      response.status === 404 ||
      errorBody.includes("UNREGISTERED")
    ) {
      const { error } = await supabase
        .from("admin_fcm_tokens")
        .delete()
        .eq("id", device.id);

      if (error) {
        throw error;
      }

      return;
    }

    throw new Error(
      `FCM failed (${response.status}): ${errorBody}`,
    );
  }
}

// ========================================
// SEND TO ALL ADMIN DEVICES
// ========================================

async function sendToAdmins(
  devices: FcmDevice[],
  title: string,
  body: string,
  data: Record<string, string>,
) {
  const accessToken = await getGoogleAccessToken();

  // Bounded concurrency prevents excessive
  // simultaneous outbound requests.

  const concurrency = 20;

  for (let i = 0; i < devices.length; i += concurrency) {
    const batch = devices.slice(i, i + concurrency);

    const results = await Promise.allSettled(
      batch.map((device) =>
        sendFcm(
          device,
          title,
          body,
          data,
          accessToken,
        )
      ),
    );

    const failed = results.filter(
      (result) => result.status === "rejected",
    );

    if (failed.length > 0) {
      throw new Error(
        `${failed.length} FCM device deliveries failed`,
      );
    }
  }
}

// ========================================
// EDGE FUNCTION ENTRY POINT
// ========================================

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", {
      status: 405,
    });
  }

  if (
    req.headers.get("x-worker-secret") !== WORKER_SECRET
  ) {
    return new Response("Unauthorized", {
      status: 401,
    });
  }

  const { data: acquired, error: lockError } = await supabase.rpc(
    "try_lock_push_worker",
  );

  if (lockError) {
    return Response.json({
      error: lockError.message,
    }, { status: 500 });
  }

  if (!acquired) {
    return Response.json({
      message: "Another worker is processing the queue",
    });
  }

  try {
    // Read pending messages.
    // 300 seconds is the queue visibility timeout.

    const { data: messages, error } = await supabase
      .schema("pgmq_public")
      .rpc("read", {
        queue_name: QUEUE,
        sleep_seconds: 300,
        n: BATCH_SIZE,
      });

    if (error) {
      throw error;
    }

    const queueMessages = (messages || []) as QueueMessage[];

    if (queueMessages.length === 0) {
      return Response.json({
        message: "No pending enquiries",
      });
    }

    const count = queueMessages.length;

    // Get all active admin device tokens.
    const { data: devices, error: deviceError } = await supabase
      .from("admin_fcm_tokens")
      .select("id, fcm_token, platform")
      .eq("is_active", true);

    if (deviceError) {
      throw deviceError;
    }

    if (!devices || devices.length === 0) {
      // No registered admin devices.
      // Database remains the source of truth.
      console.log("No registered admin devices");
    } else {
      const firstMessage = queueMessages[0].message;

      const title = count === 1
        ? "New enquiry received!"
        : `${count} new enquiries received!`;

      const body = count === 1
        ? `${
          firstMessage.reference_code || "A customer"
        } submitted a new enquiry.`
        : `${count} customers submitted new enquiries. Open the dashboard to review them.`;

      await sendToAdmins(
        devices,
        title,
        body,
        {
          type: "new_enquiry",
          count: String(count),
          enquiry_id: count === 1 ? String(firstMessage.enquiry_id) : "",
        },
      );
    }

    // Delete messages only after successful delivery
    // to all registered admin devices.

    for (const message of queueMessages) {
      const { error: deleteError } = await supabase
        .schema("pgmq_public")
        .rpc("delete", {
          queue_name: QUEUE,
          msg_id: message.msg_id,
        });

      if (deleteError) {
        throw deleteError;
      }
    }

    return Response.json({
      success: true,
      processed: count,
      devices: devices?.length || 0,
    });
  } catch (error) {
    console.error("Notification worker failed:", error);

    // Messages remain in the queue and become visible
    // again after their visibility timeout.

    return Response.json({
      error: String(error),
    }, { status: 500 });
  } finally {
    await supabase.rpc("release_push_worker");
  }
});
