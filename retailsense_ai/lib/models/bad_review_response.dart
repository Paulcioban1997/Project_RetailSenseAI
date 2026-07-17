class BadReviewResponse { 
    final int prediction;

    BadReviewResponse({
        required this.prediction,
    });

    bool get isBadReview => prediction == 1;

    factory BadReviewResponse.fromJson(Map<String, dynamic> json) {
        return BadReviewResponse(
            prediction: (json['bad_review_prediction'] as num).toInt(),
        );
    }
}