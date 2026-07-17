class SegmentationRequest {
  final int recency;
  final int frequency;
  final double monetary;

  SegmentationRequest({
    required this.recency,
    required this.frequency,
    required this.monetary,
  });

  Map<String, dynamic> toJson() {
    return {
      'recency': recency,
      'frequency': frequency,
      'monetary': monetary,
    };
  }
}