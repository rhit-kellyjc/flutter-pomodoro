import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class BackgroundOption {
  final String name;
  final Color? color;
  final String? _imagePath;

  const BackgroundOption({
    required this.name,
    this.color,
    String? imagePath,
  }) : _imagePath = imagePath;

  String? get imagePath {
    if (_imagePath == null) return null;
    return kIsWeb ? 'assets/$_imagePath' : _imagePath;
  }
}
