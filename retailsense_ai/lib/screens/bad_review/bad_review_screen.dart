import 'package:flutter/material.dart';

import '../../app/localization/app_i18n.dart';
import '../../models/bad_review_request.dart';
import '../../models/bad_review_response.dart';
import '../../services/api_service.dart';
import '../../services/bad_review_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class BadReviewScreen extends StatefulWidget {
	const BadReviewScreen({super.key});

	@override
	State<BadReviewScreen> createState() => _BadReviewScreenState();
}

class _BadReviewScreenState extends State<BadReviewScreen> {
	final _orderStatus = TextEditingController(text: 'delivered');
	final _delayDays = TextEditingController(text: '-8');
	final _deliveryDays = TextEditingController(text: '8');
	final _nItems = TextEditingController(text: '1');
	final _customerState = TextEditingController(text: 'SP');
	final _mainCategory = TextEditingController(text: 'housewares');
	final _purchaseMonth = TextEditingController(text: '10');
	final _totalFreight = TextEditingController(text: '8.72');

	final _badReviewService = BadReviewService(apiService: ApiService());
	bool _loading = false;
	String _result = '';

	@override
	void dispose() {
		_orderStatus.dispose();
		_delayDays.dispose();
		_deliveryDays.dispose();
		_nItems.dispose();
		_customerState.dispose();
		_mainCategory.dispose();
		_purchaseMonth.dispose();
		_totalFreight.dispose();
		super.dispose();
	}

	Future<void> _submit() async {
		setState(() {
			_loading = true;
		});
		try {
			final request = BadReviewRequest(
				orderStatus: _orderStatus.text,
				delayDays: double.tryParse(_delayDays.text) ?? -8.0,
				deliveryDays: double.tryParse(_deliveryDays.text) ?? 8.0,
				nItems: double.tryParse(_nItems.text) ?? 1.0,
				customerState: _customerState.text,
				mainCategory: _mainCategory.text,
				purchaseMonth: int.tryParse(_purchaseMonth.text) ?? 10,
				totalFreight: double.tryParse(_totalFreight.text) ?? 8.72,
			);

			final BadReviewResponse response =
				await _badReviewService.predictBadReview(request);

			setState(() {
				_result = response.isBadReview
					? '${AppI18n.t(context, 'bad_review_risk_bad')}${response.prediction}${AppI18n.t(context, 'bad_review_result_suffix')}'
					: '${AppI18n.t(context, 'bad_review_risk_good')}${response.prediction}${AppI18n.t(context, 'bad_review_result_suffix')}';
			});
		} catch (e) {
			setState(() {
				_result = '${AppI18n.t(context, 'result_error_prefix')}$e';
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
			title: 'Prediction Bad Review',
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
												Icons.info_outline,
												color: Theme.of(context).colorScheme.primary,
											),
											const SizedBox(width: 8),
											Text(
												AppI18n.t(context, 'card_bad_review_title'),
												style: Theme.of(context).textTheme.titleMedium?.copyWith(
													fontWeight: FontWeight.bold,
												),
											),
										],
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_bad_review_desc')),
									const SizedBox(height: 10),
									Text(
										AppI18n.t(context, 'card_bad_review_instr'),
										style: TextStyle(fontWeight: FontWeight.w600),
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_bad_review_v1')),
									Text(AppI18n.t(context, 'card_bad_review_v2')),
									Text(AppI18n.t(context, 'card_bad_review_v3')),
									Text(AppI18n.t(context, 'card_bad_review_v4')),
									Text(AppI18n.t(context, 'card_bad_review_v5')),
									Text(AppI18n.t(context, 'card_bad_review_v6')),
									Text(AppI18n.t(context, 'card_bad_review_v7')),
									Text(AppI18n.t(context, 'card_bad_review_v8')),
								],
							),
						),
					),
					const SizedBox(height: 12),
					CustomTextField(controller: _orderStatus, label: AppI18n.t(context, 'field_order_status')),
					const SizedBox(height: 8),
					CustomTextField(controller: _delayDays, label: AppI18n.t(context, 'field_delay_days')),
					const SizedBox(height: 8),
					CustomTextField(controller: _deliveryDays, label: AppI18n.t(context, 'field_delivery_days')),
					const SizedBox(height: 8),
					CustomTextField(controller: _nItems, label: 'n_items'),
					const SizedBox(height: 8),
					CustomTextField(controller: _customerState, label: AppI18n.t(context, 'field_customer_state')),
					const SizedBox(height: 8),
					CustomTextField(controller: _mainCategory, label: AppI18n.t(context, 'field_main_category')),
					const SizedBox(height: 8),
					CustomTextField(controller: _purchaseMonth, label: AppI18n.t(context, 'field_purchase_month')),
					const SizedBox(height: 8),
					CustomTextField(controller: _totalFreight, label: AppI18n.t(context, 'field_total_freight')),
					const SizedBox(height: 16),
					CustomButton(label: AppI18n.t(context, 'bad_review_button'), isLoading: _loading, onPressed: _submit),
					const SizedBox(height: 16),
					SelectableText(_result),
				],
			),
		);
	}
}