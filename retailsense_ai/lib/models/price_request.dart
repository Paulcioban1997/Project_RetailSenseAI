class PriceRequest {
  final int orderItemId;
  final double freightValue;
  final String orderStatus;
  final String productCategoryName;
  final double productNameLenght;
  final double productDescriptionLenght;
  final double productPhotosQty;
  final double productWeightG;
  final double productLengthCm;
  final double productHeightCm;
  final double productWidthCm;

  PriceRequest({
    required this.orderItemId,
    required this.freightValue,
    required this.orderStatus,
    required this.productCategoryName,
    required this.productNameLenght,
    required this.productDescriptionLenght,
    required this.productPhotosQty,
    required this.productWeightG,
    required this.productLengthCm,
    required this.productHeightCm,
    required this.productWidthCm,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_item_id': orderItemId,
      'freight_value': freightValue,
      'order_status': orderStatus,
      'product_category_name': productCategoryName,
      'product_name_lenght': productNameLenght,
      'product_description_lenght': productDescriptionLenght,
      'product_photos_qty': productPhotosQty,
      'product_weight_g': productWeightG,
      'product_length_cm': productLengthCm,
      'product_height_cm': productHeightCm,
      'product_width_cm': productWidthCm,
    };
  }
}