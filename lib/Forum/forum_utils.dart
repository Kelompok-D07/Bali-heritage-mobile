import 'package:flutter/material.dart';

TextSpan highlightText(String text, String query, {TextStyle? defaultStyle}) {
  if (query.isEmpty) {
    return TextSpan(text: text, style: defaultStyle ?? const TextStyle(color: Colors.black));
  }

  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();
  final spans = <TextSpan>[];

  int start = 0;
  int index = 0;

  while (true) {
    index = lowerText.indexOf(lowerQuery, start);
    if (index < 0) {
      // tidak ditemukan
      spans.add(TextSpan(
        text: text.substring(start),
        style: defaultStyle ?? const TextStyle(color: Colors.black),
      ));
      break;
    }

    // teks sebelum query
    if (index > start) {
      spans.add(TextSpan(
        text: text.substring(start, index),
        style: defaultStyle ?? const TextStyle(color: Colors.black),
      ));
    }

    // query yang di-highlight
    spans.add(TextSpan(
      text: text.substring(index, index + query.length),
      style: defaultStyle?.copyWith(
        backgroundColor: Colors.yellow,
        fontWeight: FontWeight.bold,
      ) ??
          const TextStyle(
            color: Colors.black,
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
    ));

    start = index + query.length;
    if (start >= text.length) break;
  }

  return TextSpan(children: spans);
}
