class AnomalyResponse {
	final bool isAnomaly;
	final String status;
	final String riskLevel;
	final double reconstructionError;
	final double threshold;

	AnomalyResponse({
		required this.isAnomaly,
		required this.status,
		required this.riskLevel,
		required this.reconstructionError,
		required this.threshold,
	});

	factory AnomalyResponse.fromJson(Map<String, dynamic> json) {
		return AnomalyResponse(
			isAnomaly: json['is_anomaly'] as bool,
			status: json['status'] as String,
			riskLevel: json['risk_level'] as String,
			reconstructionError: (json['reconstruction_error'] as num).toDouble(),
			threshold: (json['threshold'] as num).toDouble(),
		);
	}

	String get summary {
		return '$status | Risque: $riskLevel';
	}
}