import 'package:flutter/material.dart';
import 'package:sap_pi/utils/constants.dart';
import 'package:sap_pi/utils/palette.dart';

class CustomListTile extends StatelessWidget {
  final String titleText;
  final String subtitleText;
  final Widget trailingIcon;
  final VoidCallback? onIconPressed;

  const CustomListTile({
    super.key,
    required this.titleText,
    this.subtitleText = '',
    this.trailingIcon = const Icon(Icons.add),
    this.onIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      shadowColor: Palette.primary,
      elevation: 2,
      child: ListTile(
        iconColor: Palette.primary,
        title: Text(
          titleText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Constants.mediumFontSize,
          ),
        ),
        subtitle: subtitleText.isNotEmpty
            ? Text(
                subtitleText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Constants.smallFontSize,
                ),
              )
            : null,
        trailing: SizedBox(
          width: 50,
          height: 50,
          child: IconButton(
            icon: trailingIcon,
            onPressed: onIconPressed,
          ),
        ),
        style: ListTileStyle.list,
      ),
    );
  }
}
