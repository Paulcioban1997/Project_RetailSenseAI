import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/localization/app_i18n.dart';
import '../routes/route_names.dart';
import 'app_drawer.dart';
import 'language_selector.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackToHome = true,
  });

  final String title;
  final Widget body;
  final bool showBackToHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: showBackToHome
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                tooltip: AppI18n.t(context, 'home'),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.dashboard,
                    (_) => false,
                  );
                },
              )
            : null,
        title: Text(AppI18n.localizeKnownTitle(context, title)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: LanguageSelector(),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: body,
      bottomNavigationBar: kIsWeb
          ? null
          : SafeArea(
              minimum: const EdgeInsets.only(bottom: 48),
              child: _PredictionBottomBar(
                activeRoute: _routeForTitle(title),
              ),
            ),
    );
  }

  String _routeForTitle(String value) {
    final map = <String, String>{
      'Prediction Bad Review': RouteNames.badReview,
      'Prediction Demande Commande': RouteNames.demand,
      'Prevision hebdomadaire (7-14 jours)': RouteNames.weeklyDemand,
      'Prediction Prix': RouteNames.price,
      'Segmentation': RouteNames.segmentation,
      'Detection Anomalie': RouteNames.anomaly,
      'Generation Synthétique': RouteNames.generation,
      'Prediction Sentiment': RouteNames.sentiment,
      'Recommendation Produits': RouteNames.recommendation,
      'Home': RouteNames.dashboard,
      'Dashboard': RouteNames.dashboard,
      'Accueil': RouteNames.dashboard,
    };
    return map[value] ?? RouteNames.dashboard;
  }
}

class _PredictionBottomBar extends StatelessWidget {
  const _PredictionBottomBar({required this.activeRoute});

  final String activeRoute;

  @override
  Widget build(BuildContext context) {
    final items = <_NavItem>[
      _NavItem(RouteNames.badReview, Icons.fact_check, AppI18n.t(context, 'bottom_bad_review')),
      _NavItem(RouteNames.demand, Icons.shopping_cart, AppI18n.t(context, 'bottom_demand')),
      _NavItem(RouteNames.weeklyDemand, Icons.trending_up, AppI18n.t(context, 'bottom_weekly_demand')),
      _NavItem(RouteNames.price, Icons.attach_money, AppI18n.t(context, 'bottom_price')),
      _NavItem(RouteNames.segmentation, Icons.groups, AppI18n.t(context, 'bottom_segmentation')),
      _NavItem(RouteNames.anomaly, Icons.error_outline, AppI18n.t(context, 'bottom_anomaly')),
      _NavItem(RouteNames.generation, Icons.auto_awesome, AppI18n.t(context, 'bottom_generation')),
      _NavItem(RouteNames.sentiment, Icons.rate_review, AppI18n.t(context, 'bottom_sentiment')),
      _NavItem(RouteNames.recommendation, Icons.recommend, AppI18n.t(context, 'bottom_recommendation')),
    ];

    return Container(
      color: Theme.of(context).colorScheme.surface,
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = item.route == activeRoute;
          return FilledButton.tonalIcon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                item.route,
                (_) => false,
              );
            },
            icon: Icon(item.icon, size: 14),
            label: Text(item.label, style: const TextStyle(fontSize: 11)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: selected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          );
        },
        separatorBuilder: (_, index) => const SizedBox(width: 6),
        itemCount: items.length,
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.route, this.icon, this.label);

  final String route;
  final IconData icon;
  final String label;
}