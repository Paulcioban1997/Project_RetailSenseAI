import 'dart:convert';

import 'package:flutter/material.dart';

import '../../app/localization/app_i18n.dart';
import '../../models/generation_request.dart';
import '../../models/generation_response.dart';
import '../../services/api_service.dart';
import '../../services/generation_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class GenerationScreen extends StatefulWidget {
	const GenerationScreen({super.key});

	@override
	State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
	final _count = TextEditingController(text: '10');
	final _generationService = GenerationService(apiService: ApiService());

	bool _loading = false;
	String _result = '';

	@override
	void dispose() {
		_count.dispose();
		super.dispose();
	}

	Future<void> _submit() async {
		setState(() {
			_loading = true;
		});
		try {
			final request = GenerationRequest(
				count: int.tryParse(_count.text) ?? 10,
			);
			final GenerationResponse response = await _generationService.generateData(request);

			final preview = response.generatedData.take(3).toList();

			setState(() {
				_result =
					'${response.message}\n'
					'${AppI18n.t(context, 'generation_rows_prefix')}${response.rowCount}\n\n'
					'${AppI18n.t(context, 'generation_preview_title')}\n'
					'${const JsonEncoder.withIndent('  ').convert(preview)}';
			});
		} catch (e) {
			setState(() {
				_result = '${AppI18n.t(context, 'generation_error_prefix')}$e';
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
			title: 'Generation Synthétique',
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
												Icons.auto_awesome_outlined,
												color: Theme.of(context).colorScheme.primary,
											),
											const SizedBox(width: 8),
											Expanded(
												child: Text(
													AppI18n.t(context, 'card_generation_title'),
													style: Theme.of(context).textTheme.titleMedium?.copyWith(
														fontWeight: FontWeight.bold,
													),
												),
											),
										],
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_generation_desc')),
									const SizedBox(height: 10),
									Text(
										AppI18n.t(context, 'card_generation_instr'),
										style: TextStyle(fontWeight: FontWeight.w600),
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_generation_v1')),
									const SizedBox(height: 10),
									Text(AppI18n.t(context, 'card_generation_footer')),
								],
							),
						),
					),
					const SizedBox(height: 12),
					CustomTextField(controller: _count, label: AppI18n.t(context, 'field_count')),
					const SizedBox(height: 16),
					CustomButton(label: AppI18n.t(context, 'generation_button'), isLoading: _loading, onPressed: _submit),
					const SizedBox(height: 16),
					SelectableText(_result),
				],
			),
		);
	}
}
