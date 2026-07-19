import 'package:flutter/material.dart';

import '../../routes/route_names.dart';
import '../../utils/colors.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LandingNav(isWide: isWide),
            _HeroSection(isWide: isWide),
            const _StatsSection(),
            _FeaturesSection(isWide: isWide),
            const _CtaSection(),
            const _LandingFooter(),
          ],
        ),
      ),
    );
  }
}

// ─── Navbar ──────────────────────────────────────────────────────────────────

class _LandingNav extends StatelessWidget {
  const _LandingNav({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 20,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'RetailSense AI',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.pushNamed(context, RouteNames.login),
            child: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWide ? 64 : 20, vertical: 32),
      padding: EdgeInsets.all(isWide ? 64 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.card.withValues(alpha: 0.6),
            AppColors.bg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: _HeroText()),
                const SizedBox(width: 48),
                Expanded(flex: 4, child: _HeroVisual()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroText(),
                const SizedBox(height: 32),
                _HeroVisual(),
              ],
            ),
    );
  }
}

class _HeroText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: const Text(
            'Propulsé par IA • Machine Learning • Deep Learning',
            style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Prédictions IA\npour le commerce\nde détail',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 44,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Analysez vos données de vente, détectez les anomalies, prédisez la demande et segmentez vos clients en temps réel grâce à des modèles de machine learning et deep learning.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            Builder(
              builder: (context) => FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                ),
                onPressed: () => Navigator.pushNamed(context, RouteNames.login),
                icon: const Icon(Icons.rocket_launch, size: 18),
                label: const Text('Accéder à la plateforme', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _MiniMetric(label: 'Score sentiment', value: '4.8 / 5', icon: Icons.sentiment_very_satisfied, color: Colors.greenAccent),
          const Divider(height: 24, color: Color(0xFF1A2A40)),
          _MiniMetric(label: 'Demande prévue (7j)', value: '1 847 unités', icon: Icons.show_chart, color: AppColors.primary),
          const Divider(height: 24, color: Color(0xFF1A2A40)),
          _MiniMetric(label: 'Anomalies détectées', value: '2 transactions', icon: Icons.warning_amber, color: Colors.orangeAccent),
          const Divider(height: 24, color: Color(0xFF1A2A40)),
          _MiniMetric(label: 'Prix estimé', value: r'$ 129.99', icon: Icons.sell, color: Colors.purpleAccent),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text(value, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stats ────────────────────────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWide ? 64 : 20, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 20,
        children: const [
          _StatItem(value: '8', label: 'Endpoints IA'),
          _StatItem(value: '6', label: 'Modèles ML / DL'),
          _StatItem(value: '100%', label: 'Fallback garanti'),
          _StatItem(value: 'Live', label: 'API Render'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Features ────────────────────────────────────────────────────────────────

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    const features = [
      _FeatureData(
        icon: Icons.fact_check_outlined,
        title: 'Prédiction avis négatif',
        description: 'Anticipez les mauvaises évaluations clients avant qu\'elles surviennent grâce à un modèle de classification.',
        color: Color(0xFFFF7043),
        route: RouteNames.badReview,
      ),
      _FeatureData(
        icon: Icons.shopping_cart_outlined,
        title: 'Prédiction de demande',
        description: 'Estimez le volume de commandes avec XGBoost sur la base des données historiques et des tendances.',
        color: Color(0xFF42A5F5),
        route: RouteNames.demand,
      ),
      _FeatureData(
        icon: Icons.show_chart_outlined,
        title: 'Prévision hebdomadaire',
        description: 'Prévoyez la demande sur 7 à 14 jours avec un réseau RNN entraîné sur vos séries temporelles.',
        color: Color(0xFF00C2FF),
        route: RouteNames.weeklyDemand,
      ),
      _FeatureData(
        icon: Icons.sell_outlined,
        title: 'Estimation du prix',
        description: 'Calculez le prix optimal d\'un produit à partir de ses caractéristiques avec un modèle de régression.',
        color: Color(0xFFAB47BC),
        route: RouteNames.price,
      ),
      _FeatureData(
        icon: Icons.warning_amber_outlined,
        title: 'Détection d\'anomalie',
        description: 'Identifiez les transactions suspectes ou inhabituelles avec un autoencodeur de détection d\'anomalies.',
        color: Color(0xFFFFCA28),
        route: RouteNames.anomaly,
      ),
      _FeatureData(
        icon: Icons.sentiment_satisfied_alt_outlined,
        title: 'Analyse de sentiment',
        description: 'Évaluez le sentiment des avis clients de 1 à 5 avec un modèle de traitement du langage naturel.',
        color: Color(0xFF66BB6A),
        route: RouteNames.sentiment,
      ),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWide ? 64 : 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Modules disponibles',
            style: TextStyle(color: AppColors.text, fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chaque module est accessible via l\'API REST déployée sur Render',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 3 : 1,
              childAspectRatio: isWide ? 1.2 : 3.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, i) => _FeatureCard(data: features[i]),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.route,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String route;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.data});
  final _FeatureData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            data.title,
            style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              data.description,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.5),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CTA ─────────────────────────────────────────────────────────────────────

class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWide ? 64 : 20, vertical: 16),
      padding: EdgeInsets.all(isWide ? 48 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.22),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'Prêt à tester la plateforme ?',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.text, fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Text(
            'Connectez-vous avec le compte de démonstration pour accéder à tous les modules.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: () => Navigator.pushNamed(context, RouteNames.login),
            icon: const Icon(Icons.login, size: 20),
            label: const Text('Accéder à la démo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _LandingFooter extends StatelessWidget {
  const _LandingFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '© 2026 RetailSense AI — PMC Solutions AI',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, RouteNames.login),
            child: const Text('Se connecter', style: TextStyle(color: AppColors.primary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
