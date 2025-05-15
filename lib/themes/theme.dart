import 'package:flutter/material.dart';
import 'package:travel_notebook/themes/constants.dart';

class GlobalThemData {
  static final Color _lightFocusColor = kBlackColor.withValues(alpha: 0.12);

  static ThemeData lightThemeData =
      themeData(lightColorScheme, _lightFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      canvasColor: colorScheme.surface,
      scaffoldBackgroundColor: colorScheme.surface,
      highlightColor: kTransparentColor,
      focusColor: focusColor,
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
      ),
      textTheme: TextTheme(
        headlineSmall: boldTextStyle,
        headlineMedium: boldTextStyle,
        headlineLarge: boldTextStyle,
        titleLarge: boldTextStyle,
        titleMedium: boldTextStyle,
        titleSmall: boldTextStyle.copyWith(color: kGreyColor.shade800),
        labelLarge: labelTextStyle.copyWith(fontSize: 15),
        labelMedium: labelTextStyle,
        labelSmall: labelTextStyle,
      ),
      iconButtonTheme: iconButtonTheme,
      textButtonTheme: textButtonTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
    );
  }

  static const TextStyle boldTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    letterSpacing: .6,
  );

  static const TextStyle labelTextStyle = TextStyle(
    letterSpacing: .6,
    color: kGreyColor,
  );

  static IconButtonThemeData iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      padding: const EdgeInsets.all(kPadding / 4),
      foregroundColor: kSecondaryColor,
      backgroundColor: kGreyColor.shade200,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
    ),
  );

  static TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: kGreyColor.shade200, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: kPadding),
      foregroundColor: kSecondaryColor,
      backgroundColor: kGreyColor.shade100,
      textStyle: const TextStyle(letterSpacing: 1, fontWeight: FontWeight.w500),
    ),
  );

  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: kWhiteColor,
      backgroundColor: kPrimaryColor,
      padding: const EdgeInsets.symmetric(
          horizontal: kPadding, vertical: kHalfPadding),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kPadding / 4)),
      ),
    ),
  );

  static OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(
        width: 1.0,
        color: kGreyColor.shade500,
      ),
    ),
  );

  static const floatingActionButtonTheme = FloatingActionButtonThemeData(
    foregroundColor: kWhiteColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(40),
      ),
    ),
  );

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: kPrimaryColor,
    onPrimary: kBlackColor,
    secondary: kWhiteColor, //Color(0xFFEFF3F3),
    onSecondary: kSecondaryColor,
    error: kRedColor,
    onError: kWhiteColor,
    surface: kWhiteColor, //Color(0xFFFAFBFB),
    onSurface: kBlackColor, //Color(0xFF241E30),
    brightness: Brightness.light,
  );
}
