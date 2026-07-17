class PrevisionRequest {
	final List<double> recentWeeklyNItems;
	final int horizonDays;

	PrevisionRequest({
		required this.recentWeeklyNItems,
		required this.horizonDays,
	});

	Map<String, dynamic> toJson() {
		return {
			'recent_weekly_n_items': recentWeeklyNItems,
			'horizon_days': horizonDays,
		};
	}
}
