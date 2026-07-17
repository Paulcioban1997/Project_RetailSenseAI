class SentimentResponse {
	final int reviewScore;
	final String label;

	SentimentResponse({
		required this.reviewScore,
		required this.label,
	});

	factory SentimentResponse.fromJson(Map<String, dynamic> json) {
		return SentimentResponse(
			reviewScore: json['review_score'] as int,
			label: json['label'] as String,
		);
	}
}