class PriceResponse {
	final double predictedPrice;

	PriceResponse({required this.predictedPrice});

	factory PriceResponse.fromJson(Map<String, dynamic> json) {
		return PriceResponse(
			predictedPrice: (json['predicted_price'] as num).toDouble(),
		);
	}
}