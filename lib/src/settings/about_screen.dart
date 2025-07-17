// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../style/palette.dart';
import 'custom_name_dialog.dart';
import 'settings.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  var _gap = SizedBox(height: 20.h);
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final palette = context.watch<Palette>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
        backgroundColor: palette.backgroundMain,
        title: Text(
          'About',
          style: TextStyle(fontSize: 28.sp, color: palette.textColor, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: palette.backgroundMain,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/ic_launcher.png'),
              width: 120.w,
              height: 120.w,
            ),
            SizedBox(height: 20.h),
            Text(
              "${_packageInfo.appName}",
              style: TextStyle(fontSize: 24.sp, color: palette.textColor, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Text(
              "Version: ${_packageInfo.version}",
              style: TextStyle(fontSize: 18.sp, color: palette.textColor.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}
