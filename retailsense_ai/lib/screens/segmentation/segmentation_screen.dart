import 'package:flutter/material.dart';

import '../../app/localization/app_i18n.dart';
import '../../models/segmentation_request.dart';
import '../../models/segmentation_response.dart';
import '../../services/api_service.dart';
import '../../services/segmentation_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class SegmentationScreen extends StatefulWidget {
	const SegmentationScreen({super.key});

	@override
	State<SegmentationScreen> createState() => _SegmentationScreenState();
}

class _SegmentationScreenState extends State<SegmentationScreen> {
	final _recency = TextEditingController(text: '30');
	final _frequency = TextEditingController(text: '5');
	final _monetary = TextEditingController(text: '500');
	final _segmentationService = SegmentationService(apiService: ApiService());

	bool _loading = false;
	String _result = '';

	@override
	void dispose() {
		_recency.dispose();
		_frequency.dispose();
		_monetary.dispose();
		super.dispose();
	}

	Future<void> _submit() async {
		setState(() {
			_loading = true;
		});
		try {
			final request = SegmentationRequest(
				recency: int.tryParse(_recency.text) ?? 30,
				frequency: int.tryParse(_frequency.text) ?? 5,
				monetary: double.tryParse(_monetary.text) ?? 500.0,
			);

			final SegmentationResponse response =
				await _segmentationService.segmentCustomer(request);

			setState(() {
				_result =
					'${AppI18n.t(context, 'segmentation_result_segment')}${response.segment}\n'
					'${AppI18n.t(context, 'segmentation_result_name')}${response.segmentName}\n'
					'${AppI18n.t(context, 'segmentation_result_interpretation')}${response.businessInterpretation}';
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
			title: 'Segmentation',
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
												Icons.groups_outlined,
												color: Theme.of(context).colorScheme.primary,
											),
											const SizedBox(width: 8),
											Expanded(
												child: Text(
													AppI18n.t(context, 'card_seg_title'),
													style: Theme.of(context).textTheme.titleMedium?.copyWith(
														fontWeight: FontWeight.bold,
													),
												),
											),
										],
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_seg_desc')),
									const SizedBox(height: 10),
									Text(
										AppI18n.t(context, 'card_seg_instr'),
										style: TextStyle(fontWeight: FontWeight.w600),
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_seg_v1')),
									Text(AppI18n.t(context, 'card_seg_v2')),
									Text(AppI18n.t(context, 'card_seg_v3')),
									const SizedBox(height: 10),
									Text(AppI18n.t(context, 'card_seg_footer')),
								],
							),
						),
					),
					const SizedBox(height: 12),
					CustomTextField(controller: _recency, label: 'Recency', keyboardType: TextInputType.number),
					const SizedBox(height: 10),
					CustomTextField(controller: _recency, label: AppI18n.t(context, 'field_recency'), keyboardType: TextInputType.number),
					const SizedBox(height: 10),
					CustomTextField(controller: _frequency, label: AppI18n.t(context, 'field_frequency'), keyboardType: TextInputType.number),
					const SizedBox(height: 10),
					CustomTextField(controller: _monetary, label: AppI18n.t(context, 'field_monetary'), keyboardType: TextInputType.number),
					const SizedBox(height: 16),
					CustomButton(label: AppI18n.t(context, 'segmentation_button'), isLoading: _loading, onPressed: _submit),
					const SizedBox(height: 16),
					SelectableText(_result),
				],
			),
		);
	}
}
