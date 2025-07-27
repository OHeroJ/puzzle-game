import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget desktopBody;
  final Widget mobileBody;

  const ResponsiveWidget({
    super.key,
    required this.desktopBody,
    required this.mobileBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return desktopBody;
        } else {
          return mobileBody;
        }
      },
    );
  }
}