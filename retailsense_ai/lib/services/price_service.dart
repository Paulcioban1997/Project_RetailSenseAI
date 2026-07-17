import '../models/price_request.dart';
import '../models/price_response.dart';
import 'api_service.dart';

class PriceService {
	final ApiService apiService;

	PriceService({required this.apiService});

	Future<PriceResponse> predictPrice(PriceRequest request) async {
		final json = await apiService.predictPrice(request.toJson());
		return PriceResponse.fromJson(json);
	}
}