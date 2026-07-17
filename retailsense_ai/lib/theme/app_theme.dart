import 'package:flutter/material.dart';

import '../utils/colors.dart';

class AppTheme {
	static ThemeData get darkTheme {
		return ThemeData(
			brightness: Brightness.dark,
			scaffoldBackgroundColor: AppColors.bg,
			colorScheme: ColorScheme.fromSeed(
				brightness: Brightness.dark,
				seedColor: AppColors.primary,
			),
			appBarTheme: const AppBarTheme(
				centerTitle: true,
				backgroundColor: AppColors.card,
				foregroundColor: AppColors.text,
			),
			inputDecorationTheme: InputDecorationTheme(
				filled: true,
				fillColor: AppColors.card,
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
				),
			),
			cardTheme: const CardThemeData(
				color: AppColors.card,
			),
		);
	}
}
