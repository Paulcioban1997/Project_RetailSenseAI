class DemandRequest {
    final String orderStatus;
    final String customerState;
    final double deliveryDays;
    final double delayDays;
    final int purchaseMonth;
    final int purchaseDow;
    final double totalPrice;
    final double totalFreight;
    final double totalWeight;
    final String mainCategory;
    final double paymentValue;
    final double maxInstallments;
    final String paymentType;

    DemandRequest({
        required this.orderStatus,
        required this.customerState,
        required this.deliveryDays,
        required this.delayDays,
        required this.purchaseMonth,
        required this.purchaseDow,
        required this.totalPrice,
        required this.totalFreight,
        required this.totalWeight,
        required this.mainCategory,
        required this.paymentValue,
        required this.maxInstallments,
        required this.paymentType,
    });

    Map<String, dynamic> toJson() {
        return {
            'order_status': orderStatus,
            'customer_state': customerState,
            'delivery_days': deliveryDays,
            'delay_days': delayDays,
            'purchase_month': purchaseMonth,
            'purchase_dow': purchaseDow,
            'total_price': totalPrice,
            'total_freight': totalFreight,
            'total_weight': totalWeight,
            'main_category': mainCategory,
            'payment_value': paymentValue,
            'max_installments': maxInstallments,
            'payment_type': paymentType,
        };
    }
}

