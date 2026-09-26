import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';

class CustomButtonMedium {
  CustomButtonMedium._();

  static Widget primaryMedium({
    final Color color = AppColor.Primary500,
    final void Function()? onPressed,
    final String text = "Button",
    final Widget? prefixicon,
    final Widget? suffixicon,
    final bool? isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 12.w),
        backgroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColor.Primary600;
          }
          if (states.contains(WidgetState.disabled)) {
            return AppColor.Neutral250;
          }
          return color;
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
            SizedBox(width: 20.w, height: 20.w, child: prefixicon),

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
            Text(
              text,
              style: AppTextStyle.body2(
                color: AppColor.Neutral100,
                fontWeight: AppTextStyle.semiBold,
              ),
            ),
          if (suffixicon != null)
            SizedBox(width: 20.w, height: 20.w, child: suffixicon),
        ],
      ),
    );
  }
}
