import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'local_inference_service.dart';

class ApiService {
	Future<Map<String, dynamic>> post(
		String path,
		Map<String, dynamic> body,
	) async {
		if (ApiConfig.useLocalInference) {
			return LocalInferenceService.predict(path, body);
		}

		final url = Uri.parse('${ApiConfig.baseUrl}$path');

		final response = await http.post(
			url,
			headers: {
				'Content-Type': 'application/json',
			},
			body: jsonEncode(body),
		);

		if (response.statusCode >= 200 && response.statusCode < 300) {
			return jsonDecode(response.body) as Map<String, dynamic>;
		}

		throw Exception('HTTP ${response.statusCode}: ${response.body}');
	}

	Future<Map<String, dynamic>> predictDemand(Map<String, dynamic> body) {
		return post('/predict/demand', body);
	}

	Future<Map<String, dynamic>> predictWeeklyDemand(Map<String, dynamic> body) {
		return post('/predict/weekly-demand', body);
	}

	Future<Map<String, dynamic>> predictPrice(Map<String, dynamic> body) {
		return post('/predict/price', body);
	}

	Future<Map<String, dynamic>> predictBadReview(Map<String, dynamic> body) {
		return post('/predict/bad-review', body);
	}

	Future<Map<String, dynamic>> segmentCustomer(Map<String, dynamic> body) {
		return post('/segment/customer', body);
	}

	Future<Map<String, dynamic>> detectAnomaly(Map<String, dynamic> body) {
		return post('/detect/anomaly', body);
	}

	Future<Map<String, dynamic>> predictSentiment(Map<String, dynamic> body) {
		return post('/predict/sentiment', body);
	}

	Future<Map<String, dynamic>> recommendProducts(Map<String, dynamic> body) {
		return post('/recommend/products', body);
	}

	Future<Map<String, dynamic>> generateData(int count) {
		return post('/generate/data?count=$count', {});
	}
}