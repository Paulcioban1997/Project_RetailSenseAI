import '../models/sentiment_request.dart';
import '../models/sentiment_response.dart';
import 'api_service.dart';

class SentimentService {
	final ApiService apiService;

	SentimentService({required this.apiService});

	Future<SentimentResponse> predictSentiment(SentimentRequest request) async {
		final json = await apiService.predictSentiment(request.toJson());
		return SentimentResponse.fromJson(json);
	}
}