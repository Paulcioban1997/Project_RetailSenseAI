import 'package:flutter/material.dart';

import '../app/localization/locale_controller.dart';

class LanguageSelector extends StatefulWidget {
	const LanguageSelector({super.key});

	@override
	State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
	static const _languages = [
		'FR',
		'EN',
	];

	@override
	Widget build(BuildContext context) {
		final current = LocaleController.instance.languageCode;

		return DropdownButtonHideUnderline(
			child: DropdownButton<String>(
			value: current,
				items: _languages
					.map(
						(lang) => DropdownMenuItem(
							value: lang,
							child: Text(lang),
						),
					)
					.toList(),
				onChanged: (value) {
					if (value != null) {
						LocaleController.instance.setLanguageCode(value);
					}
				},
			),
		);
	}
}
