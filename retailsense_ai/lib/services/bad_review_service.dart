import '../models/bad_review_request.dart';
import '../models/bad_review_response.dart';
import 'api_service.dart';

class BadReviewService {
  final ApiService apiService;

  BadReviewService({required this.apiService});

  Future<BadReviewResponse> predictBadReview(BadReviewRequest request) async {
    final json = await apiService.predictBadReview(request.toJson());
    return BadReviewResponse.fromJson(json);
  }
}