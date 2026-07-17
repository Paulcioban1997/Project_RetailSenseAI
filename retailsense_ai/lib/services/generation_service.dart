import '../models/generation_request.dart';
import '../models/generation_response.dart';
import 'api_service.dart';

class GenerationService {
	final ApiService apiService;

	GenerationService({required this.apiService});

	Future<GenerationResponse> generateData(GenerationRequest request) async {
		final json = await apiService.generateData(request.count);
		return GenerationResponse.fromJson(json);
	}
}