import 'package:flutter/material.dart';

import '../../app/localization/app_i18n.dart';
import '../../models/sentiment_request.dart';
import '../../models/sentiment_response.dart';
import '../../services/api_service.dart';
import '../../services/sentiment_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class SentimentScreen extends StatefulWidget {
	const SentimentScreen({super.key});

	@override
	State<SentimentScreen> createState() => _SentimentScreenState();
}

class _SentimentScreenState extends State<SentimentScreen> {
	final _textController = TextEditingController(
		text: 'Produit excellent, livraison rapide et client tres satisfait',
	);
	final _sentimentService = SentimentService(apiService: ApiService());

	bool _loading = false;
	String _result = '';

	@override
	void dispose() {
		_textController.dispose();
		super.dispose();
	}

	Future<void> _submit() async {
		setState(() {
			_loading = true;
		});
		try {
			final request = SentimentRequest(text: _textController.text.trim());
			final SentimentResponse response = await _sentimentService.predictSentiment(request);

			setState(() {
				_result =
					'${AppI18n.t(context, 'sentiment_score')}${response.reviewScore}/5\n'
					'${AppI18n.t(context, 'sentiment_label')}${response.label}';
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
			title: 'Prediction Sentiment',
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
												Icons.sentiment_satisfied_alt_outlined,
												color: Theme.of(context).colorScheme.primary,
											),
											const SizedBox(width: 8),
											Expanded(
												child: Text(
													AppI18n.t(context, 'card_sentiment_title'),
													style: Theme.of(context).textTheme.titleMedium?.copyWith(
														fontWeight: FontWeight.bold,
													),
												),
											),
										],
									),
									const SizedBox(height: 12),
									Text(AppI18n.t(context, 'card_sentiment_desc')),
									const SizedBox(height: 10),
									Text(
										AppI18n.t(context, 'card_sentiment_instr'),
										style: TextStyle(fontWeight: FontWeight.w600),
									),
									const SizedBox(height: 10),
									Text(AppI18n.t(context, 'card_sentiment_v1')),
									const SizedBox(height: 10),
									Text(AppI18n.t(context, 'card_sentiment_footer')),
								],
							),
						),
					),
					const SizedBox(height: 12),
					CustomTextField(
						controller: _textController,
										label: AppI18n.t(context, 'field_text_review'),
						maxLines: 4,
					),
					const SizedBox(height: 16),
					CustomButton(label: AppI18n.t(context, 'sentiment_button'), isLoading: _loading, onPressed: _submit),
					const SizedBox(height: 16),
					SelectableText(_result),
				],
			),
		);
	}
}
