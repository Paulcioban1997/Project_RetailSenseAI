class SegmentationResponse {
  final int segment;
  final String segmentName;

  SegmentationResponse({
    required this.segment,
    required this.segmentName,
  });

  String get businessInterpretation {
    switch (segmentName.toLowerCase()) {
      case 'clients vip':
        return 'Clients a forte valeur: prioriser fidelisation et offres premium.';
      case 'clients fidèles':
      case 'clients fideles':
        return 'Clients reguliers: maintenir satisfaction et upsell progressif.';
      case 'clients récents':
      case 'clients recents':
        return 'Nouveaux clients: onboarding et relance rapide pour 2e achat.';
      case 'clients dormants':
        return 'Clients inactifs: campagnes de reactivation ciblees.';
      default:
        return 'Segment standard: optimiser experience et conversion.';
    }
  }

  factory SegmentationResponse.fromJson(Map<String, dynamic> json) {
    return SegmentationResponse(
      segment: (json['segment'] as num).toInt(),
      segmentName: (json['segment_name'] ?? '').toString(),
    );
  }
}