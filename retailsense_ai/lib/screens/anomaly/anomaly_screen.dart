import 'package:flutter/material.dart';

import '../../app/localization/app_i18n.dart';
import '../../models/anomaly_request.dart';
import '../../models/anomaly_response.dart';
import '../../services/api_service.dart';
import '../../services/anomaly_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AnomalyScreen extends StatefulWidget {
	const AnomalyScreen({super.key});

	@override
	State<AnomalyScreen> createState() => _AnomalyScreenState();
}

class _AnomalyScreenState extends State<AnomalyScreen> {
	final _deliveryDays = TextEditingController(text: '8');
	final _delayDays = TextEditingController(text: '-8');
	final _purchaseMonth = TextEditingController(text: '10');
	final _purchaseDow = TextEditingController(text: '0');
	final _nItems = TextEditingController(text: '1');
	final _totalPrice = TextEditingController(text: '29.99');
	final _totalFreight = TextEditingController(text: '8.72');
	final _totalWeight = TextEditingController(text: '500');
	final _paymentValue = TextEditingController(text: '38.71');
	final _maxInstallments = TextEditingController(text: '1');
	final _reviewScore = TextEditingController(text: '4');
	final _badReview = TextEditingController(text: '0');

	final _anomalyService = AnomalyService(apiService: ApiService());
	bool _loading = false;
	String _result = '';

	@override
	void dispose() {
		_deliveryDays.dispose();
		_delayDays.dispose();
		_purchaseMonth.dispose();
		_purchaseDow.dispose();
		_nItems.dispose();
		_totalPrice.dispose();
		_totalFreight.dispose();
		_totalWeight.dispose();
		_paymentValue.dispose();
		_maxInstallments.dispose();
		_reviewScore.dispose();
		_badReview.dispose();
		super.dispose();
	}

	Future<void> _submit() async {
		setState(() {
			_loading = true;
		});
		try {
			final request = AnomalyRequest(
				deliveryDays: double.tryParse(_deliveryDays.text) ?? 8,
				delayDays: double.tryParse(_delayDays.text) ?? -8,
				purchaseMonth: double.tryParse(_purchaseMonth.text) ?? 10,
				purchaseDow: double.tryParse(_purchaseDow.text) ?? 0,
				nItems: double.tryParse(_nItems.text) ?? 1,
				totalPrice: double.tryParse(_totalPrice.text) ?? 29.99,
				totalFreight: double.tryParse(_totalFreight.text) ?? 8.72,
				totalWeight: double.tryParse(_totalWeight.text) ?? 500,
				paymentValue: double.tryParse(_paymentValue.text) ?? 38.71,
				maxInstallments: double.tryParse(_maxInstallments.text) ?? 1,
				reviewScore: double.tryParse(_reviewScore.text) ?? 4,
				badReview: double.tryParse(_badReview.text) ?? 0,
			);

			final AnomalyResponse response = await _anomalyService.detectAnomaly(request);
			setState(() {
				_result =
					'${AppI18n.t(context, 'anomaly_result_status')}${response.status}\n'
					'${AppI18n.t(context, 'anomaly_result_risk')}${response.riskLevel}\n'
					'${AppI18n.t(context, 'anomaly_result_anomaly')}${response.isAnomaly ? AppI18n.t(context, 'anomaly_result_yes') : AppI18n.t(context, 'anomaly_result_no')}\n'
					'${AppI18n.t(context, 'anomaly_result_error')}${response.reconstructionError.toStringAsFixed(8)}\n'
					'${AppI18n.t(context, 'anomaly_result_threshold')}${response.threshold.toStringAsFixed(8)}';
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
			title: 'Detection Anomalie',
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
												Icons.warning_amber_rounded,
												color: Theme.of(context).colorScheme.primary,
											),
											const SizedBox(width: 8),
											Expanded(
												child: Text(
													AppI18n.t(context, 'card_anomaly_title'),
													style: Theme.of(context).textTheme.titleMedium?.copyWith(
														fontWeight: FontWeight.bold,
													),
												),
											),
										],
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_anomaly_desc')),
									const SizedBox(height: 10),
									Text(
										AppI18n.t(context, 'card_anomaly_instr'),
										style: TextStyle(fontWeight: FontWeight.w600),
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_anomaly_v1')),
									Text(AppI18n.t(context, 'card_anomaly_v2')),
									Text(AppI18n.t(context, 'card_anomaly_v3')),
									Text(AppI18n.t(context, 'card_anomaly_v4')),
									Text(AppI18n.t(context, 'card_anomaly_v5')),
									Text(AppI18n.t(context, 'card_anomaly_v6')),
									Text(AppI18n.t(context, 'card_anomaly_v7')),
									Text(AppI18n.t(context, 'card_anomaly_v8')),
									Text(AppI18n.t(context, 'card_anomaly_v9')),
									Text(AppI18n.t(context, 'card_anomaly_v10')),
									Text(AppI18n.t(context, 'card_anomaly_v11')),
									Text(AppI18n.t(context, 'card_anomaly_v12')),
									const SizedBox(height: 10),
									Text(AppI18n.t(context, 'card_anomaly_footer')),
								],
							),
						),
					),
					const SizedBox(height: 12),
					CustomTextField(controller: _deliveryDays, label: AppI18n.t(context, 'field_delivery_days')),
					const SizedBox(height: 8),
					CustomTextField(controller: _delayDays, label: AppI18n.t(context, 'field_delay_days')),
					const SizedBox(height: 8),
					CustomTextField(controller: _purchaseMonth, label: AppI18n.t(context, 'field_purchase_month')),
					const SizedBox(height: 8),
					CustomTextField(controller: _purchaseDow, label: AppI18n.t(context, 'field_purchase_dow')),
					const SizedBox(height: 8),
					CustomTextField(controller: _nItems, label: 'n_items'),
					const SizedBox(height: 8),
					CustomTextField(controller: _totalPrice, label: AppI18n.t(context, 'field_total_price')),
					const SizedBox(height: 8),
					CustomTextField(controller: _totalFreight, label: AppI18n.t(context, 'field_total_freight')),
					const SizedBox(height: 8),
					CustomTextField(controller: _totalWeight, label: AppI18n.t(context, 'field_total_weight')),
					const SizedBox(height: 8),
					CustomTextField(controller: _paymentValue, label: AppI18n.t(context, 'field_payment_value')),
					const SizedBox(height: 8),
					CustomTextField(controller: _maxInstallments, label: AppI18n.t(context, 'field_max_installments')),
					const SizedBox(height: 8),
					CustomTextField(controller: _reviewScore, label: AppI18n.t(context, 'field_review_score')),
					const SizedBox(height: 8),
					CustomTextField(controller: _badReview, label: AppI18n.t(context, 'field_bad_review')),
					const SizedBox(height: 16),
					CustomButton(label: AppI18n.t(context, 'anomaly_button'), isLoading: _loading, onPressed: _submit),
					const SizedBox(height: 16),
					SelectableText(_result),
				],
			),
		);
	}
}
