import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.coverBase64,
    required this.coverUrl,
    this.width = 56,
    this.height = 78,
    this.radius = 10,
  });

  final String coverBase64;
  final String coverUrl;
  final double width;
  final double height;
  final double radius;

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.background,
      child: Icon(Icons.menu_book,
          color: AppColors.textLight, size: width * 0.42),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (coverBase64.isNotEmpty) {
      child = Image.memory(
        base64Decode(coverBase64),
        width: width,
        height: height,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else if (coverUrl.isNotEmpty) {
      child = Image.network(
        coverUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      child = _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );
  }
}