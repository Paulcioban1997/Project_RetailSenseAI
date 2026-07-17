class GenerationResponse {
	final String message;
	final List<Map<String, dynamic>> generatedData;

	GenerationResponse({
		required this.message,
		required this.generatedData,
	});

	factory GenerationResponse.fromJson(Map<String, dynamic> json) {
		final rows = (json['generated_data'] as List<dynamic>? ?? [])
			.map((item) => Map<String, dynamic>.from(item as Map))
			.toList();

		return GenerationResponse(
			message: (json['message'] ?? '').toString(),
			generatedData: rows,
		);
	}

	int get rowCount => generatedData.length;
}