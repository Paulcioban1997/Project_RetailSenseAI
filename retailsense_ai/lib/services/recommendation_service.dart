import '../models/recommendation_request.dart';
import '../models/recommendation_response.dart';
import 'api_service.dart';

class RecommendationService {
	final ApiService apiService;

	RecommendationService({required this.apiService});

	Future<RecommendationResponse> recommendProducts(RecommendationRequest request) async {
		final json = await apiService.recommendProducts(request.toJson());
		return RecommendationResponse.fromJson(json);
	}
}