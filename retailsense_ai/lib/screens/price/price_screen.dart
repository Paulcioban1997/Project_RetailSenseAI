import 'package:flutter/material.dart';

import '../../app/localization/app_i18n.dart';
import '../../models/price_request.dart';
import '../../services/api_service.dart';
import '../../services/price_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/app_scaffold.dart';

class PriceScreen extends StatefulWidget {
	const PriceScreen({super.key});

	@override
	State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
	final _orderItemId = TextEditingController(text: '1');
	final _freightValue = TextEditingController(text: '8.72');
	final _orderStatus = TextEditingController(text: 'delivered');
	final _productCategoryName = TextEditingController(text: 'housewares');
	final _productNameLenght = TextEditingController(text: '40');
	final _productDescriptionLenght = TextEditingController(text: '268');
	final _productPhotosQty = TextEditingController(text: '4');
	final _productWeightG = TextEditingController(text: '500');
	final _productLengthCm = TextEditingController(text: '19');
	final _productHeightCm = TextEditingController(text: '8');
	final _productWidthCm = TextEditingController(text: '13');

	final _priceService = PriceService(apiService: ApiService());
	bool _loading = false;
	String _result = '';

	@override
	void dispose() {
		_orderItemId.dispose();
		_freightValue.dispose();
		_orderStatus.dispose();
		_productCategoryName.dispose();
		_productNameLenght.dispose();
		_productDescriptionLenght.dispose();
		_productPhotosQty.dispose();
		_productWeightG.dispose();
		_productLengthCm.dispose();
		_productHeightCm.dispose();
		_productWidthCm.dispose();
		super.dispose();
	}

	Future<void> _submit() async {
		setState(() {
			_loading = true;
		});

		try {
			final request = PriceRequest(
				orderItemId: int.tryParse(_orderItemId.text) ?? 1,
				freightValue: double.tryParse(_freightValue.text) ?? 8.72,
				orderStatus: _orderStatus.text,
				productCategoryName: _productCategoryName.text,
				productNameLenght: double.tryParse(_productNameLenght.text) ?? 40,
				productDescriptionLenght:
					double.tryParse(_productDescriptionLenght.text) ?? 268,
				productPhotosQty: double.tryParse(_productPhotosQty.text) ?? 4,
				productWeightG: double.tryParse(_productWeightG.text) ?? 500,
				productLengthCm: double.tryParse(_productLengthCm.text) ?? 19,
				productHeightCm: double.tryParse(_productHeightCm.text) ?? 8,
				productWidthCm: double.tryParse(_productWidthCm.text) ?? 13,
			);

			final response = await _priceService.predictPrice(request);

			setState(() {
				_result =
					'${AppI18n.t(context, "price_result_prefix")}${response.predictedPrice.toStringAsFixed(2)}';
			});
		} catch (e) {
			setState(() {
				_result = '${AppI18n.t(context, "price_error_prefix")}$e';
			});
		} finally {
			setState(() {
				_loading = false;
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return AppScaffold(
			title: 'Prediction Prix',
			body: ListView(
				padding: const EdgeInsets.all(16),
				children: [
					Card(
						color: Theme.of(context).colorScheme.surfaceContainerHigh,
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(16),
						),
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Row(
										children: [
											Icon(
												Icons.sell_outlined,
												color: Theme.of(context).colorScheme.primary,
											),
											const SizedBox(width: 8),
											Expanded(
												child: Text(
													AppI18n.t(context, 'card_price_title'),
													style: Theme.of(context).textTheme.titleMedium?.copyWith(
														fontWeight: FontWeight.bold,
													),
												),
											),
										],
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_price_desc')),
									const SizedBox(height: 10),
									Text(
										AppI18n.t(context, 'card_price_instr'),
										style: TextStyle(fontWeight: FontWeight.w600),
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_price_v1')),
									Text(AppI18n.t(context, 'card_price_v2')),
									Text(AppI18n.t(context, 'card_price_v3')),
									Text(AppI18n.t(context, 'card_price_v4')),
									Text(AppI18n.t(context, 'card_price_v5')),
									Text(AppI18n.t(context, 'card_price_v6')),
									Text(AppI18n.t(context, 'card_price_v7')),
									Text(AppI18n.t(context, 'card_price_v8')),
									Text(AppI18n.t(context, 'card_price_v9')),
									Text(AppI18n.t(context, 'card_price_v10')),
									Text(AppI18n.t(context, 'card_price_v11')),
								],
							),
						),
					),
					const SizedBox(height: 12),
						CustomTextField(controller: _orderItemId, label: AppI18n.t(context, 'field_order_item_id')),
					const SizedBox(height: 8),
						CustomTextField(controller: _freightValue, label: AppI18n.t(context, 'field_freight_value')),
					const SizedBox(height: 8),
						CustomTextField(controller: _orderStatus, label: AppI18n.t(context, 'field_order_status')),
					const SizedBox(height: 8),
					CustomTextField(
						controller: _productCategoryName,
							label: AppI18n.t(context, 'field_product_category_name'),
					),
					const SizedBox(height: 8),
					CustomTextField(
						controller: _productNameLenght,
							label: AppI18n.t(context, 'field_product_name_length'),
					),
					const SizedBox(height: 8),
					CustomTextField(
						controller: _productDescriptionLenght,
							label: AppI18n.t(context, 'field_product_description_length'),
					),
					const SizedBox(height: 8),
					CustomTextField(
						controller: _productPhotosQty,
							label: AppI18n.t(context, 'field_product_photos_qty'),
					),
					const SizedBox(height: 8),
						CustomTextField(controller: _productWeightG, label: AppI18n.t(context, 'field_product_weight_g')),
					const SizedBox(height: 8),
						CustomTextField(controller: _productLengthCm, label: AppI18n.t(context, 'field_product_length_cm')),
					const SizedBox(height: 8),
						CustomTextField(controller: _productHeightCm, label: AppI18n.t(context, 'field_product_height_cm')),
					const SizedBox(height: 8),
						CustomTextField(controller: _productWidthCm, label: AppI18n.t(context, 'field_product_width_cm')),
					const SizedBox(height: 16),
					CustomButton(
							label: AppI18n.t(context, 'price_button'),
						isLoading: _loading,
						onPressed: _submit,
					),
					const SizedBox(height: 16),
					SelectableText(_result),
				],
			),
		);
	}
}