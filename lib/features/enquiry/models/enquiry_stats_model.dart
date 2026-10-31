class EnquiryStatsModel {
  final int total;
  final int newCount;
  final int contacted;
  final int converted;
  final int lost;

  const EnquiryStatsModel({
    required this.total,
    required this.newCount,
    required this.contacted,
    required this.converted,
    required this.lost,
  });

  factory EnquiryStatsModel.fromJson(Map<String, dynamic> json) {
    return EnquiryStatsModel(
      total: json['total'] ?? 0,
      newCount: json['new'] ?? 0,
      contacted: json['contacted'] ?? 0,
      converted: json['converted'] ?? 0,
      lost: json['lost'] ?? 0,
    );
  }
}
