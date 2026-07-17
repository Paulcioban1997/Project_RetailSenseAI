import 'package:flutter/material.dart';

import '../../app/localization/app_i18n.dart';
import '../../models/prevision_request.dart';
import '../../models/prevision_response.dart';
import '../../services/api_service.dart';
import '../../services/prevision_demand_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

// Ecran RNN: predit la demande HEBDOMADAIRE totale
// Entrees: les 14 dernieres semaines de demande agregee (somme n_items)
// Sortie: demande prevue semaine prochaine (et semaine+2 si horizon=14)
class WeeklyDemandScreen extends StatefulWidget {
  const WeeklyDemandScreen({super.key});

  @override
  State<WeeklyDemandScreen> createState() => _WeeklyDemandScreenState();
}

class _WeeklyDemandScreenState extends State<WeeklyDemandScreen> {
  final _recentWeeksController = TextEditingController(
    text: '1720,1685,1810,1760,1640,1900,1950,1780,1840,1710,1630,1880,1920,1800',
  );
  final _horizonDaysController = TextEditingController(text: '14');

  final _previsionService = PrevisionDemandService(apiService: ApiService());
  bool _loading = false;
  String _result = '';

  @override
  void dispose() {
    _recentWeeksController.dispose();
    _horizonDaysController.dispose();
    super.dispose();
  }

  List<double> _parseWeeks(String raw) {
    return raw
        .split(',')
        .map((v) => double.tryParse(v.trim()))
        .whereType<double>()
        .toList();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final weeks = _parseWeeks(_recentWeeksController.text);
      final horizon = int.tryParse(_horizonDaysController.text) ?? 14;
      if (weeks.length < 14) {
        throw Exception(AppI18n.t(context, 'weekly_min_error'));
      }
      final request = PrevisionRequest(
        recentWeeklyNItems: weeks,
        horizonDays: horizon,
      );
      final PrevisionResponse response = await _previsionService.predictWeeklyDemand(request);
      setState(() {
        final w1 = response.predictedWeek1Items.toStringAsFixed(0);
        final w2 = response.predictedWeek2Items?.toStringAsFixed(0);
        _result = horizon > 7 && w2 != null
          ? '${AppI18n.t(context, 'weekly_result_week1')}$w1${AppI18n.t(context, 'weekly_result_items')}\n${AppI18n.t(context, 'weekly_result_week2')}$w2${AppI18n.t(context, 'weekly_result_items')}\n${AppI18n.t(context, 'weekly_result_model')}${response.modelUsed}'
          : '${AppI18n.t(context, 'weekly_result_week1')}$w1${AppI18n.t(context, 'weekly_result_items')}\n${AppI18n.t(context, 'weekly_result_model')}${response.modelUsed}';
      });
    } catch (e) {
      setState(() => _result = '${AppI18n.t(context, 'weekly_error_prefix')}$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Prevision hebdomadaire (7-14 jours)',
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
                        Icons.calendar_month_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppI18n.t(context, 'card_weekly_title'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(AppI18n.t(context, 'card_weekly_desc')),
                  const SizedBox(height: 8),
                  Text(
                    AppI18n.t(context, 'card_weekly_model'),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppI18n.t(context, 'card_weekly_instr'),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(AppI18n.t(context, 'card_weekly_v1')),
                  Text(AppI18n.t(context, 'card_weekly_v2')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _recentWeeksController,
            label: AppI18n.t(context, 'field_recent_weekly_n_items'),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _horizonDaysController,
            label: AppI18n.t(context, 'field_horizon_days'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: AppI18n.t(context, 'weekly_button'),
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
