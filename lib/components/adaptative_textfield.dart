import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptativeTextField extends StatelessWidget {
  Function(String)? onSubmitted;
  TextEditingController? controller;
  TextInputType? keyboardType = TextInputType.text;
  String? labelText;

  AdaptativeTextField(
      {Key? key,
      required this.onSubmitted,
      required this.controller,
      required this.keyboardType,
      required this.labelText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CupertinoTextField(
              controller: controller,
              keyboardType: keyboardType,
              onSubmitted: onSubmitted,
              placeholder: labelText!,
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 12,
              ),
            ),
          )
        : TextField(
            controller: controller,
            keyboardType: keyboardType,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              labelText: labelText!,
            ),
          );
  }
}
