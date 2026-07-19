import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/localization/app_i18n.dart';
import 'app/localization/locale_controller.dart';
import 'routes/app_routes.dart';
import 'routes/route_names.dart';
import 'theme/app_theme.dart';

class RetailSenseAI extends StatelessWidget {
  const RetailSenseAI({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppI18n.t(context, 'app_name'),
          theme: AppTheme.darkTheme,
          locale: LocaleController.instance.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr'),
            Locale('en'),
          ],
          initialRoute: kIsWeb ? RouteNames.landing : RouteNames.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}