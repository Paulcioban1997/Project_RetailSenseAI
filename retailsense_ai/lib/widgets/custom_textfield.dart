import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
	const CustomTextField({
		super.key,
		required this.controller,
		required this.label,
		this.keyboardType,
		this.maxLines = 1,
		this.obscureText = false,
	});

	final TextEditingController controller;
	final String label;
	final TextInputType? keyboardType;
	final int maxLines;
	final bool obscureText;

	@override
	Widget build(BuildContext context) {
		return TextField(
			controller: controller,
			keyboardType: keyboardType,
			maxLines: maxLines,
			obscureText: obscureText,
			decoration: InputDecoration(labelText: label),
		);
	}
}
