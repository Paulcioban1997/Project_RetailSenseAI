import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
	const DashboardCard({
		super.key,
		required this.title,
		required this.subtitle,
		required this.icon,
		required this.onTap,
	});

	final String title;
	final String subtitle;
	final IconData icon;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return Card(
			child: InkWell(
				borderRadius: BorderRadius.circular(12),
				onTap: onTap,
				child: Padding(
					padding: const EdgeInsets.all(16),
					child: Row(
						children: [
							Icon(icon, size: 30),
							const SizedBox(width: 12),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(title, style: Theme.of(context).textTheme.titleMedium),
										const SizedBox(height: 4),
										Text(
											subtitle,
											style: Theme.of(context).textTheme.bodySmall,
										),
									],
								),
							),
							const Icon(Icons.chevron_right),
						],
					),
				),
			),
		);
	}
}
