import '../models/anomaly_request.dart';
import '../models/anomaly_response.dart';
import 'api_service.dart';

class AnomalyService {
	final ApiService apiService;

	AnomalyService({required this.apiService});

	Future<AnomalyResponse> detectAnomaly(AnomalyRequest request) async {
		final json = await apiService.detectAnomaly(request.toJson());
		return AnomalyResponse.fromJson(json);
	}
}