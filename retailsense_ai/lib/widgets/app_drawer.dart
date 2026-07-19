import 'package:flutter/material.dart';

import '../app/localization/app_i18n.dart';
import '../login/login_screen.dart';
import '../services/auth_service.dart';
import '../screens/bad_review/bad_review_screen.dart';
import '../screens/anomaly/anomaly_screen.dart';
import '../screens/demand/demand_screen.dart';
import '../screens/weekly_demand/weekly_demand_screen.dart';
import '../screens/generation/generation_screen.dart';
import '../screens/price/price_screen.dart';
import '../screens/recommendation/recommendation_screen.dart';
import '../screens/segmentation/segmentation_screen.dart';
import '../screens/sentiment/sentiment_screen.dart';

class AppDrawer extends StatelessWidget {
	const AppDrawer({super.key});

	@override
	Widget build(BuildContext context) {
		return Drawer(
			child: SafeArea(
				child: ListView(
					padding: EdgeInsets.zero,
					children: [
						DrawerHeader(
							child: Align(
								alignment: Alignment.bottomLeft,
								child: Text(
									AppI18n.t(context, 'app_name'),
									style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
								),
							),
						),
						_item(context, AppI18n.t(context, 'drawer_bad_review'), Icons.fact_check, const BadReviewScreen()),
						_item(context, AppI18n.t(context, 'drawer_demand'), Icons.shopping_cart, const DemandScreen()),
					_item(context, AppI18n.t(context, 'drawer_weekly_demand'), Icons.trending_up, const WeeklyDemandScreen()),
						_item(context, AppI18n.t(context, 'drawer_price'), Icons.attach_money, const PriceScreen()),
						_item(context, AppI18n.t(context, 'drawer_segmentation'), Icons.groups, const SegmentationScreen()),
						_item(context, AppI18n.t(context, 'drawer_anomaly'), Icons.error_outline, const AnomalyScreen()),
						_item(context, AppI18n.t(context, 'drawer_generation'), Icons.auto_awesome, const GenerationScreen()),
						_item(context, AppI18n.t(context, 'drawer_sentiment'), Icons.rate_review, const SentimentScreen()),
						_item(context, AppI18n.t(context, 'drawer_recommendation'), Icons.recommend, const RecommendationScreen()),
						const Divider(height: 1),
						ListTile(
							leading: const Icon(Icons.logout),
							title: Text(AppI18n.t(context, 'drawer_logout')),
							onTap: () {
								AuthService().logout();
								Navigator.pushAndRemoveUntil(
									context,
									MaterialPageRoute(builder: (_) => const LoginScreen()),
									(_) => false,
								);
							},
						),
					],
				),
			),
		);
	}

	ListTile _item(BuildContext context, String title, IconData icon, Widget screen) {
		return ListTile(
			leading: Icon(icon),
			title: Text(title),
			onTap: () {
				Navigator.push(
					context,
					MaterialPageRoute(builder: (_) => screen),
				);
			},
		);
	}
}

