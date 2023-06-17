import 'package:flutter/material.dart';
import 'package:sap_pi/utils/constants.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final AppBar? appBar;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.colors = const [
      Color(0xFF3BBDB1),
      Color(0xFFEFEFEF),
    ],
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: colors,
              begin: begin,
              end: end,
              stops: const [
                0.01,
                0.6,
              ]),
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: appBar?.title,
            actions: appBar?.actions,
            titleTextStyle: const TextStyle(
              fontSize: Constants.mediumFontSize,
              fontFamily: 'Montserrat',
            ),
          ),
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.only(top: 50.0, right: 16.0, left: 16.0),
            child: body,
          ),
        ),
      ),
    );
  }
}
