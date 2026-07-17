class BadReviewRequest {
    final String orderStatus;
    final double delayDays;
    final double deliveryDays;
    final double nItems;
    final String customerState;
    final String mainCategory;
    final int purchaseMonth;
    final double totalFreight;

    BadReviewRequest({
        required this.orderStatus,
        required this.delayDays,
        required this.deliveryDays,
        required this.nItems,
        required this.customerState,
        required this.mainCategory,
        required this.purchaseMonth,
        required this.totalFreight,
    });

    Map<String, dynamic> toJson() {
        return {
            'order_status': orderStatus,
            'delay_days': delayDays,
            'delivery_days': deliveryDays,
            'n_items': nItems,
            'customer_state': customerState,
            'main_category': mainCategory,
            'purchase_month': purchaseMonth,
            'total_freight': totalFreight,
        };
    }
}