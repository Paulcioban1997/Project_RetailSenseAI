import '../models/prevision_request.dart';
import '../models/prevision_response.dart';
import 'api_service.dart';

class PrevisionDemandService {
	final ApiService apiService;

	PrevisionDemandService({required this.apiService});

	Future<PrevisionResponse> predictWeeklyDemand(PrevisionRequest request) async {
		final json = await apiService.predictWeeklyDemand(request.toJson());
		return PrevisionResponse.fromJson(json);
	}
}
