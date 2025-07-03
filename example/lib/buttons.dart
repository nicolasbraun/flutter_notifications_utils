import 'package:flutter/material.dart';
import 'package:flutter_notifications_utils/flutter_notifications_utils.dart'
    show ClearByTagMode, FlutterNotificationsUtils;

class ClearByTagButton extends StatelessWidget {
  const ClearByTagButton({
    super.key,
    required this.tag,
    this.mode = ClearByTagMode.isEqual,
  });

  final String tag;
  final ClearByTagMode mode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () => FlutterNotificationsUtils.clearByTag(tag, mode: mode),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: Text("${mode.name} $tag"),
      ),
    );
  }
}
