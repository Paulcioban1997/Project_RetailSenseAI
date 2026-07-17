import '../models/demand_request.dart';
import '../models/prevision_request.dart';
import '../models/demand_response.dart';
import '../models/prevision_response.dart';
import 'api_service.dart';

class DemandService {
	final ApiService apiService;

	DemandService({required this.apiService});

	Future<DemandResponse> predictDemand(DemandRequest request) async {
		final json = await apiService.predictDemand(request.toJson());

		return DemandResponse.fromJson(json);
	}

	Future<PrevisionResponse> predictWeeklyDemand(PrevisionRequest request) async {
		final json = await apiService.predictWeeklyDemand(request.toJson());
		return PrevisionResponse.fromJson(json);
	}
}