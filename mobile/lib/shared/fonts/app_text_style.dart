import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyle {
  AppTextStyle._();

  // FONT WEIGHT

  static FontWeight regular = FontWeight.w400;
  static FontWeight medium = FontWeight.w500;
  static FontWeight semiBold = FontWeight.w600;
  static FontWeight bold = FontWeight.w700;

  //  -------------------------------------- HEADING 1-------------------------------------
  static TextStyle heading1({Color? color}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 32.sp,
        height: 38 / 32.h,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // -------------------------------------- HEADING 2-------------------------------------

  static TextStyle heading2({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 28.sp,
        height: 34 / 28,
        fontWeight: fontWeight,
      ),
    );
  }

  // -------------------------------------- HEADING 3-------------------------------------

  static TextStyle heading3({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 24.sp,
        height: 28 / 24,
        fontWeight: fontWeight,
      ),
    );
  }

  // -------------------------------------- HEADING 4-------------------------------------

  static TextStyle heading4({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 20.sp,
        height: 24 / 20,
        fontWeight: fontWeight,
      ),
    );
  }

  // -------------------------------------- HEADING 5-------------------------------------

  static TextStyle heading5({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 18.sp,
        height: 22 / 18,
        fontWeight: fontWeight,
      ),
    );
  }

  // -------------------------------------- BODY 1-------------------------------------

  static TextStyle body1({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 16.sp,
        height: 18 / 16,
        fontWeight: fontWeight,
      ),
    );
  }

  // -------------------------------------- BODY 2-------------------------------------

  static TextStyle body2({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 14.sp,
        height: 16 / 14,
        fontWeight: fontWeight,
      ),
    );
  }

  // -------------------------------------- BODY 3-------------------------------------

  static TextStyle body3({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 12.sp,
        height: 14 / 12,
        fontWeight: fontWeight,
      ),
    );
  }

  // -------------------------------------- BODY 4-------------------------------------

  static TextStyle body4({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 10.sp,
        height: 12 / 10,
        fontWeight: fontWeight,
      ),
    );
  }

  // -------------------------------------- DESCRITPION 1-------------------------------------

  static TextStyle description1({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 16.sp,
        height: 20 / 16,
        fontWeight: fontWeight,
      ),
    );
  }

  // -------------------------------------- DESCRITPION 2-------------------------------------

  static TextStyle description2({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 14.sp,
        height: 20 / 14,
        fontWeight: fontWeight,
      ),
    );
  }

  // -------------------------------------- DESCRITPION 3-------------------------------------

  static TextStyle description3({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 12.sp,
        height: 16 / 12,
        fontWeight: fontWeight,
      ),
    );
  }

  // -------------------------------------- DESCRITPION 4-------------------------------------

  static TextStyle description4({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: 10.sp,
        height: 14 / 10,
        fontWeight: fontWeight,
      ),
    );
  }
}
