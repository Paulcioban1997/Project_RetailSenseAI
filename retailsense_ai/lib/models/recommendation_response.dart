class RecommendationResponse {
	final String? productId;
	final List<String> recommendedProducts;
	final String? message;

	RecommendationResponse({
		required this.productId,
		required this.recommendedProducts,
		required this.message,
	});

	factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
		final items = (json['recommended_products'] as List<dynamic>? ?? const [])
			.map((item) => item.toString())
			.toList();

		return RecommendationResponse(
			productId: json['product_id']?.toString(),
			recommendedProducts: items,
			message: json['message']?.toString(),
		);
	}

	bool get hasRecommendations => recommendedProducts.isNotEmpty;
}