import 'dart:math';

class LocalInferenceService {
  static Map<String, dynamic> predict(
    String path,
    Map<String, dynamic> body,
  ) {
    if (path == '/predict/demand') {
      return _predictDemand(body);
    }
    if (path == '/predict/weekly-demand') {
      return _predictWeeklyDemand(body);
    }
    if (path == '/predict/price') {
      return _predictPrice(body);
    }
    if (path == '/predict/bad-review') {
      return _predictBadReview(body);
    }
    if (path == '/segment/customer') {
      return _segmentCustomer(body);
    }
    if (path == '/detect/anomaly') {
      return _detectAnomaly(body);
    }
    if (path == '/predict/sentiment') {
      return _predictSentiment(body);
    }
    if (path == '/recommend/products') {
      return _recommendProducts(body);
    }
    if (path.startsWith('/generate/data')) {
      return _generateData(path);
    }

    throw Exception('Unsupported local route: $path');
  }

  static Map<String, dynamic> _predictDemand(Map<String, dynamic> body) {
    final totalPrice = _toDouble(body['total_price']);
    final paymentValue = _toDouble(body['payment_value']);
    final maxInstallments = _toDouble(body['max_installments']);
    final deliveryDays = _toDouble(body['delivery_days']);
    final delayDays = _toDouble(body['delay_days']);

    var score = 1.0;
    score += totalPrice / 220.0;
    score += paymentValue / 300.0;
    score += maxInstallments > 1 ? 0.6 : 0.0;
    score += deliveryDays > 6 ? -0.25 : 0.15;
    score += delayDays > 0 ? -0.4 : 0.2;

    final predicted = _round2(score.clamp(1.0, 20.0));
    return {'predicted_n_items': predicted};
  }

  static Map<String, dynamic> _predictPrice(Map<String, dynamic> body) {
    final freight = _toDouble(body['freight_value']);
    final weight = _toDouble(body['product_weight_g']);
    final length = _toDouble(body['product_length_cm']);
    final height = _toDouble(body['product_height_cm']);
    final width = _toDouble(body['product_width_cm']);
    final photos = _toDouble(body['product_photos_qty']);

    final volumeFactor = (length * height * width) / 10000.0;
    var price = 20.0 + freight;
    price += weight / 180.0;
    price += volumeFactor * 0.8;
    price += photos * 1.4;

    final predicted = _round2(price.clamp(5.0, 5000.0));
    return {'predicted_price': predicted};
  }

  static Map<String, dynamic> _predictWeeklyDemand(Map<String, dynamic> body) {
    final values = (body['recent_weekly_n_items'] as List?)
            ?.map((e) => _toDouble(e))
            .toList() ??
        <double>[];
    final horizonDays = _toInt(body['horizon_days']).clamp(7, 14);

    if (values.length < 14) {
      throw Exception('Il faut au moins 14 valeurs hebdomadaires.');
    }

    final lookBack = values.sublist(values.length - 14);
    final mean = lookBack.reduce((a, b) => a + b) / lookBack.length;
    final trend = (lookBack.last - lookBack.first) / (lookBack.length - 1);
    final week1 = _round2((mean + trend * 2).clamp(0.0, 1000000.0));
    final week2 = _round2((mean + trend * 4).clamp(0.0, 1000000.0));

    return {
      'horizon_days': horizonDays,
      'predicted_week_1_n_items': week1,
      if (horizonDays > 7) 'predicted_week_2_n_items': week2,
      'model_used': 'local_heuristic_weekly',
    };
  }

  static Map<String, dynamic> _predictBadReview(Map<String, dynamic> body) {
    final delayDays = _toDouble(body['delay_days']);
    final deliveryDays = _toDouble(body['delivery_days']);
    final freight = _toDouble(body['total_freight']);
    final nItems = _toDouble(body['n_items']);

    var risk = 0;
    if (delayDays > 2) risk += 2;
    if (deliveryDays > 10) risk += 1;
    if (freight > 70) risk += 1;
    if (nItems > 5) risk += 1;

    return {'bad_review_prediction': risk >= 2 ? 1 : 0};
  }

  static Map<String, dynamic> _segmentCustomer(Map<String, dynamic> body) {
    final recency = _toInt(body['recency']);
    final frequency = _toInt(body['frequency']);
    final monetary = _toDouble(body['monetary']);

    if (monetary >= 1200 && frequency >= 8 && recency <= 30) {
      return {'segment': 0, 'segment_name': 'Clients VIP'};
    }
    if (frequency >= 4 && recency <= 90) {
      return {'segment': 1, 'segment_name': 'Clients fidèles'};
    }
    if (recency <= 60 && frequency <= 3) {
      return {'segment': 2, 'segment_name': 'Clients récents'};
    }
    return {'segment': 3, 'segment_name': 'Clients dormants'};
  }

  static Map<String, dynamic> _detectAnomaly(Map<String, dynamic> body) {
    final delayDays = _toDouble(body['delay_days']);
    final badReview = _toDouble(body['bad_review']);
    final reviewScore = _toDouble(body['review_score']);
    final freight = _toDouble(body['total_freight']);
    final nItems = _toDouble(body['n_items']);

    final reconstructionError = _round4(
      (delayDays.abs() * 0.22) +
          (badReview * 0.45) +
          ((5.0 - reviewScore).clamp(0.0, 5.0) * 0.12) +
          (freight / 220.0) +
          (nItems / 18.0),
    );

    const threshold = 1.2;
    final isAnomaly = reconstructionError > threshold;
    final riskLevel = reconstructionError > 1.8
        ? 'High'
        : reconstructionError > threshold
            ? 'Medium'
            : 'Low';

    return {
      'is_anomaly': isAnomaly,
      'status': isAnomaly ? 'Anomalie detectee' : 'Comportement normal',
      'risk_level': riskLevel,
      'reconstruction_error': reconstructionError,
      'threshold': threshold,
    };
  }

  static Map<String, dynamic> _predictSentiment(Map<String, dynamic> body) {
    final text = (body['text'] ?? '').toString().toLowerCase();

    const positiveWords = <String>[
      'excellent',
      'parfait',
      'super',
      'genial',
      'génial',
      'rapide',
      'good',
      'great',
      'love',
      'satisfait',
      'recommande',
    ];
    const negativeWords = <String>[
      'nul',
      'mauvais',
      'horrible',
      'retard',
      'casse',
      'cassé',
      'arnaque',
      'bad',
      'worst',
      'late',
      'slow',
      'decu',
      'déçu',
    ];

    var score = 0;
    for (final w in positiveWords) {
      if (text.contains(w)) score += 1;
    }
    for (final w in negativeWords) {
      if (text.contains(w)) score -= 1;
    }

    if (score >= 2) {
      return {'review_score': 5, 'label': 'Positive'};
    }
    if (score == 1) {
      return {'review_score': 4, 'label': 'Positive'};
    }
    if (score == 0) {
      return {'review_score': 3, 'label': 'Neutral'};
    }
    if (score <= -2) {
      return {'review_score': 1, 'label': 'Negative'};
    }
    return {'review_score': 2, 'label': 'Negative'};
  }

  static Map<String, dynamic> _recommendProducts(Map<String, dynamic> body) {
    final productId = (body['product_id'] ?? '').toString();
    if (productId.trim().isEmpty) {
      return {
        'product_id': null,
        'recommended_products': <String>[],
        'message': 'Aucun produit source fourni.',
      };
    }

    final seed = productId.hashCode.abs() % 1000;
    final recs = List<String>.generate(
      5,
      (i) => 'REC-${seed + (i + 1) * 7}',
    );

    return {
      'product_id': productId,
      'recommended_products': recs,
      'message': 'Recommandations generees localement.',
    };
  }

  static Map<String, dynamic> _generateData(String path) {
    final count = _extractCount(path).clamp(1, 200);
    final rows = <Map<String, dynamic>>[];

    for (var i = 0; i < count; i++) {
      final price = _round2(15 + i * 2.35 + sin(i / 2) * 3);
      final freight = _round2(4 + (i % 7) * 1.25);
      rows.add({
        'synthetic_id': i + 1,
        'total_price': price,
        'total_freight': freight,
        'n_items': (i % 5) + 1,
        'purchase_month': ((i % 12) + 1),
      });
    }

    return {
      'message': '$count lignes synthetiques generees (mode local).',
      'generated_data': rows,
    };
  }

  static int _extractCount(String path) {
    final query = Uri.parse(path).queryParameters;
    return int.tryParse(query['count'] ?? '1') ?? 1;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _round2(double value) =>
      double.parse(value.toStringAsFixed(2));

  static double _round4(double value) =>
      double.parse(value.toStringAsFixed(4));
}
