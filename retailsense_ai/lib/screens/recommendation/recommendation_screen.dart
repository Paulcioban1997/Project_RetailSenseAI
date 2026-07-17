import 'package:flutter/material.dart';

import '../../app/localization/app_i18n.dart';
import '../../models/recommendation_request.dart';
import '../../models/recommendation_response.dart';
import '../../services/api_service.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RecommendationScreen extends StatefulWidget {
	const RecommendationScreen({super.key});

	@override
	State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
	final _productId = TextEditingController(
		text: '87285b34884572647811a353c7ac498a',
	);
	final _recommendationService = RecommendationService(apiService: ApiService());

	bool _loading = false;
	String _result = '';

	@override
	void dispose() {
		_productId.dispose();
		super.dispose();
	}

	Future<void> _submit() async {
		setState(() {
			_loading = true;
		});
		try {
			final request = RecommendationRequest(productId: _productId.text.trim());
			final RecommendationResponse response =
				await _recommendationService.recommendProducts(request);

			setState(() {
				if (!response.hasRecommendations) {
					_result = response.message ?? AppI18n.t(context, 'recommendation_none');
					return;
				}

				_result =
					'${AppI18n.t(context, 'recommendation_source_prefix')}${response.productId}\n'
					'${AppI18n.t(context, 'recommendation_count_prefix')}${response.recommendedProducts.length}\n\n'
					'${response.recommendedProducts.join('\n')}';
			});
		} catch (e) {
			setState(() {
				_result = '${AppI18n.t(context, 'recommendation_error_prefix')}$e';
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
			title: 'Recommendation Produits',
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
												Icons.hub_outlined,
												color: Theme.of(context).colorScheme.primary,
											),
											const SizedBox(width: 8),
											Expanded(
												child: Text(
													AppI18n.t(context, 'card_reco_title'),
													style: Theme.of(context).textTheme.titleMedium?.copyWith(
														fontWeight: FontWeight.bold,
													),
												),
											),
										],
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_reco_desc')),
									const SizedBox(height: 10),
									Text(
										AppI18n.t(context, 'card_reco_instr'),
										style: TextStyle(fontWeight: FontWeight.w600),
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_reco_v1')),
									const SizedBox(height: 10),
									Text(AppI18n.t(context, 'card_reco_footer')),
								],
							),
						),
					),
					const SizedBox(height: 12),
					CustomTextField(controller: _productId, label: AppI18n.t(context, 'field_product_id')),
					const SizedBox(height: 16),
					CustomButton(label: AppI18n.t(context, 'recommendation_button'), isLoading: _loading, onPressed: _submit),
					const SizedBox(height: 16),
					SelectableText(_result),
				],
			),
		);
	}
}
