import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ChunkyCard - Container putih dengan border radius dan shadow
/// Style Duolingo: Soft shadows, rounded corners, clean white surface
class ChunkyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final double shadowOffset;

  const ChunkyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.backgroundColor,
    this.shadowOffset = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.neutral,
        borderRadius: BorderRadius.circular(borderRadius),
        // Shadow style Duolingo - subtle tapi visible
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralShadow,
            offset: Offset(0, shadowOffset),
            blurRadius: 0, // Sharp shadow seperti Duolingo
          ),
        ],
        border: Border.all(color: AppColors.neutralShadow, width: 2),
      ),
      child: child,
    );
  }
}

/// ChunkyCardOutlined - Versi dengan outline berwarna
class ChunkyCardOutlined extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color outlineColor;
  final Color? backgroundColor;

  const ChunkyCardOutlined({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.outlineColor = AppColors.primary,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.neutral,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: outlineColor, width: 3),
      ),
      child: child,
    );
  }
}
