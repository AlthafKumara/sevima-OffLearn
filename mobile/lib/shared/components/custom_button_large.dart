import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';

class CustomButtonLarge {
  CustomButtonLarge._();

  static Widget primarylarge({
    final void Function()? onPressed,
    final String? text,
    final Widget? prefixicon,
    final Widget? suffixicon,
    final bool? isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        backgroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColor.Primary600;
          }
          if (states.contains(WidgetState.disabled)) {
            return AppColor.Neutral250;
          }
          return AppColor.Primary500;
        }),
        foregroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColor.Neutral400;
          }
          return AppColor.Neutral100;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixicon != null)
            SizedBox(width: 24.w, height: 24.w, child: prefixicon),

          if (isLoading == true)
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.Neutral100,
              ),
            ),
          if (isLoading == false)
            if (text != null)
              Text(
                text,
                style: AppTextStyle.body2(
                  color: AppColor.Neutral100,
                  fontWeight: AppTextStyle.semiBold,
                ),
              ),
          if (suffixicon != null)
            SizedBox(width: 24.w, height: 24.w, child: suffixicon),
        ],
      ),
    );
  }

  static Widget outlinelarge({
    final void Function()? onPressed,
    final String? text,
    final Widget? prefixicon,
    final Widget? suffixicon,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColor.Neutral300),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        backgroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColor.Neutral250;
          }
          return AppColor.Neutral200;
        }),
        foregroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColor.Neutral400;
          }
          return AppColor.Neutral900;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixicon != null)
            SizedBox(width: 24.w, height: 24.w, child: prefixicon),
          if (prefixicon != null && text != null) SizedBox(width: 8.w),
          if (text != null)
            Text(
              text,
              style: AppTextStyle.body2(fontWeight: AppTextStyle.semiBold),
            ),
          if (text != null && suffixicon != null) SizedBox(width: 8.w),
          if (suffixicon != null)
            SizedBox(width: 24.w, height: 24.w, child: suffixicon),
        ],
      ),
    );
  }
}
