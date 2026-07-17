class RecommendationRequest {
	final String productId;

	RecommendationRequest({required this.productId});

	Map<String, dynamic> toJson() {
		return {
			'product_id': productId,
		};
	}
}