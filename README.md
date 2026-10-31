# Tribe Green – Admin Dashboard Handover

## 1. Project Overview

The Tribe Green Admin Dashboard is a Flutter Web application used to manage the corporate gifting catalogue and customer enquiries.

**Main features**

- Admin authentication
- Product listing and management
- Customer enquiry management
- Enquiry status tracking: New, Contacted, Converted, Lost
- Dashboard statistics
- CSV export

## 2. Technology Stack

| Technology         | Purpose                                         |
| ------------------ | ----------------------------------------------- |
| Flutter & Dart     | Web application and UI                          |
| GetX               | State management and navigation                 |
| Supabase           | Backend, PostgreSQL database and authentication |
| SharedPreferences  | Local preference storage                        |
| CachedNetworkImage | Product image loading                           |
| Intl               | Date and number formatting                      |

**Why this stack?**

- Flutter provides a single codebase for building a responsive web dashboard.
- GetX keeps state management and navigation straightforward.
- Supabase provides authentication, database access and Row Level Security without requiring a separate backend server.
- CachedNetworkImage improves the product-image loading experience.

## 3. How to Run the Project

**Prerequisites**

- Flutter SDK
- Dart SDK
- Git
- Supabase project credentials

**Setup**

```bash
git clone https://github.com/Vjy-p/gifting_admin.git
cd gifting_admin
flutter pub get
```

Configure the required Supabase environment values in the project's expected configuration file. Do not commit private keys or service-role credentials.

**Run locally**

```bash
flutter run -d chrome
```

**Build for web**

```bash
flutter build web --release --base-href /gifting_admin/
```

The base href above is for deployment under the GitHub Pages project URL. Adjust it if the hosting path changes.

## 4. Deployment

- Source code is maintained in GitHub.
- Web deployment is configured through GitHub Actions.
- GitHub Pages should use **GitHub Actions** as its deployment source.
- Configure Supabase credentials as GitHub repository secrets.
- Add the deployed website URL to Supabase Auth redirect URLs where required.

## 5. Incomplete Items and Known Limitations

- Enquiry pagination currently works on the client side after fetching records, rather than using server-side pagination.
- CSV export uses the records currently loaded in memory; it does not guarantee export of every enquiry.
- Product image upload and storage integration need further completion/verification.
- Email and push notifications are not implemented.
- Automated tests and broader error-handling coverage need improvement.

## 6. Improvements With More Time

- Implement server-side pagination, filtering and search.
- Export all enquiries directly from Supabase in batches.
- Complete product image upload using Supabase Storage.
- Add email notifications for new enquiries and status changes.
- Add push notifications for admin users.
- Improve dashboard analytics and reporting.
- Add unit, widget and integration tests.
- Improve logging, monitoring and CI checks.

## 7. Development Time

**Recorded development-time estimate: 7 hours**

This is the estimate recorded for the admin dashboard; it is not a separately verified time-tracking report.
