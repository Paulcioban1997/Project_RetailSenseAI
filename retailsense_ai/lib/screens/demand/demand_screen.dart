import 'package:flutter/material.dart';

import '../../app/localization/app_i18n.dart';
import '../../models/demand_request.dart';
import '../../models/demand_response.dart';
import '../../services/api_service.dart';
import '../../services/demand_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

// Ecran XGBoost: predit le nombre d articles d une COMMANDE precise
// Entrees: caracteristiques de la commande (statut, etat client, prix, etc.)
// Sortie: predicted_n_items (nombre d articles predit pour cette commande)
class DemandScreen extends StatefulWidget {
  const DemandScreen({super.key});

  @override
  State<DemandScreen> createState() => _DemandScreenState();
}

class _DemandScreenState extends State<DemandScreen> {
  final _orderStatus      = TextEditingController(text: 'delivered');
  final _customerState    = TextEditingController(text: 'SP');
  final _deliveryDays     = TextEditingController(text: '8');
  final _delayDays        = TextEditingController(text: '-8');
  final _purchaseMonth    = TextEditingController(text: '10');
  final _purchaseDow      = TextEditingController(text: '0');
  final _totalPrice       = TextEditingController(text: '29.99');
  final _totalFreight     = TextEditingController(text: '8.72');
  final _totalWeight      = TextEditingController(text: '500');
  final _mainCategory     = TextEditingController(text: 'housewares');
  final _paymentValue     = TextEditingController(text: '38.71');
  final _maxInstallments  = TextEditingController(text: '1');
  final _paymentType      = TextEditingController(text: 'voucher');

  final _demandService = DemandService(apiService: ApiService());
  bool _loading = false;
  String _result = '';

  @override
  void dispose() {
    _orderStatus.dispose();
    _customerState.dispose();
    _deliveryDays.dispose();
    _delayDays.dispose();
    _purchaseMonth.dispose();
    _purchaseDow.dispose();
    _totalPrice.dispose();
    _totalFreight.dispose();
    _totalWeight.dispose();
    _mainCategory.dispose();
    _paymentValue.dispose();
    _maxInstallments.dispose();
    _paymentType.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final request = DemandRequest(
        orderStatus:     _orderStatus.text.trim(),
        customerState:   _customerState.text.trim(),
        deliveryDays:    double.tryParse(_deliveryDays.text) ?? 8,
        delayDays:       double.tryParse(_delayDays.text) ?? 0,
        purchaseMonth:   int.tryParse(_purchaseMonth.text) ?? 10,
        purchaseDow:     int.tryParse(_purchaseDow.text) ?? 0,
        totalPrice:      double.tryParse(_totalPrice.text) ?? 29.99,
        totalFreight:    double.tryParse(_totalFreight.text) ?? 8.72,
        totalWeight:     double.tryParse(_totalWeight.text) ?? 500,
        mainCategory:    _mainCategory.text.trim(),
        paymentValue:    double.tryParse(_paymentValue.text) ?? 38.71,
        maxInstallments: double.tryParse(_maxInstallments.text) ?? 1,
        paymentType:     _paymentType.text.trim(),
      );
      final DemandResponse response = await _demandService.predictDemand(request);
      setState(() {
        _result = '${AppI18n.t(context, 'demand_result_prefix')}${response.predictedItems.toStringAsFixed(2)}';
      });
    } catch (e) {
      setState(() => _result = '${AppI18n.t(context, 'result_error_prefix')}$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Prediction Demande Commande',
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
                      Expanded(
                        child: Text(
                          AppI18n.t(context, 'card_demand_title'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(AppI18n.t(context, 'card_demand_desc')),
                  const SizedBox(height: 10),
                  Text(
                    AppI18n.t(context, 'card_demand_instr'),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(AppI18n.t(context, 'card_demand_v1')),
                  Text(AppI18n.t(context, 'card_demand_v2')),
                  Text(AppI18n.t(context, 'card_demand_v3')),
                  Text(AppI18n.t(context, 'card_demand_v4')),
                  Text(AppI18n.t(context, 'card_demand_v5')),
                  Text(AppI18n.t(context, 'card_demand_v6')),
                  Text(AppI18n.t(context, 'card_demand_v7')),
                  Text(AppI18n.t(context, 'card_demand_v8')),
                  Text(AppI18n.t(context, 'card_demand_v9')),
                  Text(AppI18n.t(context, 'card_demand_v10')),
                  Text(AppI18n.t(context, 'card_demand_v11')),
                  Text(AppI18n.t(context, 'card_demand_v12')),
                  Text(AppI18n.t(context, 'card_demand_v13')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(AppI18n.t(context, 'demand_subtitle')),
          const SizedBox(height: 12),
          CustomTextField(controller: _orderStatus,     label: AppI18n.t(context, 'field_order_status')),
          const SizedBox(height: 8),
          CustomTextField(controller: _customerState,   label: AppI18n.t(context, 'field_customer_state')),
          const SizedBox(height: 8),
          CustomTextField(controller: _deliveryDays,    label: AppI18n.t(context, 'field_delivery_days'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          CustomTextField(controller: _delayDays,       label: AppI18n.t(context, 'field_delay_days'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          CustomTextField(controller: _purchaseMonth,   label: AppI18n.t(context, 'field_purchase_month'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          CustomTextField(controller: _purchaseDow,     label: AppI18n.t(context, 'field_purchase_dow'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          CustomTextField(controller: _totalPrice,      label: AppI18n.t(context, 'field_total_price'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          CustomTextField(controller: _totalFreight,    label: AppI18n.t(context, 'field_total_freight'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          CustomTextField(controller: _totalWeight,     label: AppI18n.t(context, 'field_total_weight'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          CustomTextField(controller: _mainCategory,    label: AppI18n.t(context, 'field_main_category')),
          const SizedBox(height: 8),
          CustomTextField(controller: _paymentValue,    label: AppI18n.t(context, 'field_payment_value'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          CustomTextField(controller: _maxInstallments, label: AppI18n.t(context, 'field_max_installments'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          CustomTextField(controller: _paymentType,     label: AppI18n.t(context, 'field_payment_type')),
          const SizedBox(height: 16),
          CustomButton(label: AppI18n.t(context, 'demand_button'), isLoading: _loading, onPressed: _submit),
          const SizedBox(height: 16),
          SelectableText(_result),
        ],
      ),
    );
  }
}
