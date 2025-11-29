import 'package:flutter/material.dart';

abstract final class Dimens {
  const Dimens();

  // Spacing tokens (from design system)
  static const space1 = 4.0; // micro spacing
  static const space2 = 8.0; // tight spacing
  static const space3 = 12.0; // compact spacing (form field spacing)
  static const space4 =
      16.0; // default spacing (component padding, mobile margin)
  static const space5 = 20.0; // comfortable spacing (card padding)
  static const space6 = 24.0; // relaxed spacing
  static const space8 = 32.0; // section spacing, tablet gutter
  static const space10 = 40.0; // large spacing
  static const space12 = 48.0; // extra large spacing
  static const space16 = 64.0; // page margins (desktop)

  // Border radius
  static const borderRadiusMinimal = 2.0;
  static const borderRadiusSmall = 4.0;
  static const borderRadiusMedium = 8.0;
  static const borderRadiusCircle = 50.0;

  // Common patterns
  static const cardPadding = space5;
  static const sectionGap = space8;
  static const formFieldSpacing = space3;
  static const componentPadding = space4;

  /// Horizontal padding for screen edges
  double get paddingScreenHorizontal;

  /// Vertical padding for screen edges
  double get paddingScreenVertical;

  double get profilePictureSize;

  /// Horizontal symmetric padding for screen edges
  EdgeInsets get edgeInsetsScreenHorizontal =>
      EdgeInsets.symmetric(horizontal: paddingScreenHorizontal);

  /// Symmetric padding for screen edges
  EdgeInsets get edgeInsetsScreenSymmetric => EdgeInsets.symmetric(
    horizontal: paddingScreenHorizontal,
    vertical: paddingScreenVertical,
  );

  static const Dimens desktop = _DimensDesktop();
  static const Dimens mobile = _DimensMobile();

  /// Get dimensions definition based on screen size
  factory Dimens.of(BuildContext context) =>
      switch (MediaQuery.sizeOf(context).width) {
        >= 1200 => desktop,
        >= 768 && < 1200 => _DimensTablet(),
        _ => mobile,
      };
}

/// Mobile dimensions
final class _DimensMobile extends Dimens {
  @override
  final double paddingScreenHorizontal = Dimens.space4; // 16px

  @override
  final double paddingScreenVertical = Dimens.space4; // 16px

  @override
  final double profilePictureSize = 64.0;

  const _DimensMobile();
}

/// Desktop/Web dimensions
final class _DimensDesktop extends Dimens {
  @override
  final double paddingScreenHorizontal = Dimens.space16; // 64px

  @override
  final double paddingScreenVertical = Dimens.space16; // 64px

  @override
  final double profilePictureSize = 128.0;

  const _DimensDesktop();
}

final class _DimensTablet extends Dimens {
  @override
  final double paddingScreenHorizontal = Dimens.space8; // 32px

  @override
  final double paddingScreenVertical = Dimens.space8; // 32px

  @override
  final double profilePictureSize = 96.0;

  const _DimensTablet();
}
