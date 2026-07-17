class PrevisionResponse {
	final double predictedWeek1Items;
	final double? predictedWeek2Items;
	final int horizonDays;
	final int lookBackUsed;
	final String modelUsed;

	PrevisionResponse({
		required this.predictedWeek1Items,
		this.predictedWeek2Items,
		required this.horizonDays,
		required this.lookBackUsed,
		required this.modelUsed,
	});

	factory PrevisionResponse.fromJson(Map<String, dynamic> json) {
		return PrevisionResponse(
			predictedWeek1Items: (json['predicted_week_1_n_items'] as num).toDouble(),
			predictedWeek2Items: (json['predicted_week_2_n_items'] as num?)?.toDouble(),
			horizonDays: (json['horizon_days'] as num?)?.toInt() ?? 7,
			lookBackUsed: (json['look_back_used'] as num?)?.toInt() ?? 14,
			modelUsed: (json['model_used'] as String?) ?? 'unknown_model',
		);
	}
}

