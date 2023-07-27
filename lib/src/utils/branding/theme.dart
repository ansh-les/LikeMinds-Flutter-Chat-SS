import 'package:likeminds_chat_ss_fl/src/utils/branding/lm_branding.dart';
import 'package:likeminds_chat_ss_fl/src/utils/branding/lm_fonts.dart';
import 'package:likeminds_chat_ss_fl/src/utils/imports.dart';

class LMTheme {
  static Color get headerColor => LMBranding.instance.headerColor;
  static Color get buttonColor => LMBranding.instance.buttonColor;
  static Color get textLinkColor => LMBranding.instance.textLinkColor;
  static LMFonts get fonts => LMBranding.instance.fonts;
  static TextStyle get regular => LMFonts.instance.regular;
  static TextStyle get bold => LMFonts.instance.bold;
  static TextStyle get medium => LMFonts.instance.medium;
}
