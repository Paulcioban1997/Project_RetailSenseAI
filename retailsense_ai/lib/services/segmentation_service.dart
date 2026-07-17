import '../models/segmentation_request.dart';
import '../models/segmentation_response.dart';
import 'api_service.dart';

class SegmentationService {
  final ApiService apiService;

  SegmentationService({required this.apiService});

  Future<SegmentationResponse> segmentCustomer(
    SegmentationRequest request,
  ) async {
    final json = await apiService.segmentCustomer(request.toJson());
    return SegmentationResponse.fromJson(json);
  }
}