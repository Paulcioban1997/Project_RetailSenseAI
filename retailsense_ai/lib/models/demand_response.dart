class DemandResponse {
    final double predictedItems;

    DemandResponse({required this.predictedItems});

    factory DemandResponse.fromJson(Map<String, dynamic> json) {
        return DemandResponse(
            predictedItems: (json['predicted_n_items'] as num).toDouble(),
        );
    }
}

