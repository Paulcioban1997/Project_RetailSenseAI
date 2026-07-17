class AnomalyRequest {
	final double deliveryDays;
	final double delayDays;
	final double purchaseMonth;
	final double purchaseDow;
	final double nItems;
	final double totalPrice;
	final double totalFreight;
	final double totalWeight;
	final double paymentValue;
	final double maxInstallments;
	final double reviewScore;
	final double badReview;

	AnomalyRequest({
		required this.deliveryDays,
		required this.delayDays,
		required this.purchaseMonth,
		required this.purchaseDow,
		required this.nItems,
		required this.totalPrice,
		required this.totalFreight,
		required this.totalWeight,
		required this.paymentValue,
		required this.maxInstallments,
		required this.reviewScore,
		required this.badReview,
	});

	Map<String, dynamic> toJson() {
		return {
			'delivery_days': deliveryDays,
			'delay_days': delayDays,
			'purchase_month': purchaseMonth,
			'purchase_dow': purchaseDow,
			'n_items': nItems,
			'total_price': totalPrice,
			'total_freight': totalFreight,
			'total_weight': totalWeight,
			'payment_value': paymentValue,
			'max_installments': maxInstallments,
			'review_score': reviewScore,
			'bad_review': badReview,
		};
	}
}