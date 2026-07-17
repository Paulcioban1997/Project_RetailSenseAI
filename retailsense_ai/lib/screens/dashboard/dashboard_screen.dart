import 'package:flutter/material.dart';

import '../../app/localization/app_i18n.dart';
import '../../routes/route_names.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'RetailSense AI',
      showBackToHome: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1100;
          final featureCards = [
            _FeatureItem(
              title: 'Bad Review',
              subtitle: 'Prediction du risque avis negatif',
              icon: Icons.fact_check_outlined,
              route: RouteNames.badReview,
            ),
            _FeatureItem(
              title: 'Demand',
              subtitle: 'Prediction demande commande',
              icon: Icons.shopping_cart_outlined,
              route: RouteNames.demand,
            ),
            _FeatureItem(
              title: 'Weekly Demand',
              subtitle: 'Prevision 7 a 14 jours',
              icon: Icons.show_chart_outlined,
              route: RouteNames.weeklyDemand,
            ),
            _FeatureItem(
              title: 'Price',
              subtitle: 'Estimation prix produit',
              icon: Icons.sell_outlined,
              route: RouteNames.price,
            ),
            _FeatureItem(
              title: 'Anomaly',
              subtitle: 'Detection transaction anormale',
              icon: Icons.warning_amber_outlined,
              route: RouteNames.anomaly,
            ),
            _FeatureItem(
              title: 'Sentiment',
              subtitle: 'Analyse avis client',
              icon: Icons.sentiment_satisfied_alt_outlined,
              route: RouteNames.sentiment,
            ),
          ];

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(isWide ? 28 : 16, 20, isWide ? 28 : 16, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.32),
                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.20),
                          Theme.of(context).colorScheme.surface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isWide ? 32 : 20),
                      child: isWide
                          ? Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppI18n.t(context, 'home_banner_title'),
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        AppI18n.t(context, 'home_welcome'),
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        AppI18n.t(context, 'home_description'),
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                      const SizedBox(height: 20),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        children: [
                                          FilledButton(
                                            onPressed: () => Navigator.pushNamed(context, RouteNames.demand),
                                            child: const Text('Start analytics'),
                                          ),
                                          OutlinedButton(
                                            onPressed: () => Navigator.pushNamed(context, RouteNames.sentiment),
                                            child: const Text('Test sentiment'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 4,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/images/retailsense_banner.jpeg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppI18n.t(context, 'home_banner_title'),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppI18n.t(context, 'home_welcome'),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppI18n.t(context, 'home_description'),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 18),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.asset(
                                    'assets/images/retailsense_banner.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Quick access',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 3 : 1,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: isWide ? 2.9 : 3.4,
                    ),
                    itemCount: featureCards.length,
                    itemBuilder: (context, index) {
                      final item = featureCards[index];
                      return DashboardCard(
                        title: item.title,
                        subtitle: item.subtitle,
                        icon: item.icon,
                        onTap: () => Navigator.pushNamed(context, item.route),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      AppI18n.t(context, 'home_footer'),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}
