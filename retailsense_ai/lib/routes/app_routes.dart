import 'package:flutter/material.dart';

import '../app/localization/app_i18n.dart';
import '../screens/anomaly/anomaly_screen.dart';
import '../screens/bad_review/bad_review_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/demand/demand_screen.dart';
import '../screens/weekly_demand/weekly_demand_screen.dart';
import '../screens/generation/generation_screen.dart';
import '../screens/price/price_screen.dart';
import '../screens/recommendation/recommendation_screen.dart';
import '../screens/segmentation/segmentation_screen.dart';
import '../screens/sentiment/sentiment_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/landing/landing_screen.dart';
import '../login/login_screen.dart';
import 'route_names.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteNames.landing:
        return MaterialPageRoute(builder: (_) => const LandingScreen());

      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteNames.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case RouteNames.badReview:
        return MaterialPageRoute(builder: (_) => const BadReviewScreen());

      case RouteNames.demand:
        return MaterialPageRoute(builder: (_) => const DemandScreen());

      case RouteNames.weeklyDemand:
        return MaterialPageRoute(builder: (_) => const WeeklyDemandScreen());

      case RouteNames.price:
        return MaterialPageRoute(builder: (_) => const PriceScreen());

      case RouteNames.segmentation:
        return MaterialPageRoute(builder: (_) => const SegmentationScreen());

      case RouteNames.anomaly:
        return MaterialPageRoute(builder: (_) => const AnomalyScreen());

      case RouteNames.generation:
        return MaterialPageRoute(builder: (_) => const GenerationScreen());

      case RouteNames.sentiment:
        return MaterialPageRoute(builder: (_) => const SentimentScreen());

      case RouteNames.recommendation:
        return MaterialPageRoute(builder: (_) => const RecommendationScreen());

      default:
        return MaterialPageRoute(builder: (context) {
          return Scaffold(
            body: Center(child: Text(AppI18n.t(context, 'route_not_found'))),
          );
        });
    }
  }
}