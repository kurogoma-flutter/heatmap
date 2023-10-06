// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:heatmap/heatmap.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("GitHub Heatmap")),
        body: Heatmap(
          data: [
            // テストデータ
            {DateTime(2023, 1, 1): 1},
            {DateTime(2022, 1, 2): 2},
            {DateTime(2022, 1, 3): 6},
            {DateTime(2023, 1, 4): 3},
            {DateTime(2023, 1, 5): 4},
            // 3月中旬データ
            {DateTime(2023, 3, 1): 1},
            {DateTime(2023, 3, 2): 2},
            {DateTime(2023, 3, 3): 3},
            {DateTime(2023, 3, 4): 4},
            {DateTime(2023, 3, 5): 5},
            {DateTime(2022, 3, 6): 1},
            {DateTime(2022, 3, 7): 2},
            {DateTime(2022, 3, 8): 3},
            {DateTime(2022, 3, 9): 4},
            {DateTime(2022, 3, 10): 5},
            // 5月データ
            {DateTime(2023, 5, 1): 5},
            {DateTime(2023, 5, 2): 4},
            {DateTime(2023, 5, 3): 4},
            {DateTime(2023, 5, 4): 9},
            {DateTime(2023, 5, 5): 6},
            // 8月データ
            {DateTime(2023, 8, 1): 5},
            {DateTime(2023, 8, 2): 10},
            {DateTime(2023, 8, 3): 11},
            {DateTime(2023, 8, 4): 4},
            // 12月データ
            {DateTime(2023, 12, 1): 1},
            {DateTime(2023, 12, 2): 10},
            {DateTime(2023, 12, 3): 4},
            {DateTime(2023, 12, 4): 10},
            // ... 他のデータ
          ],
          colorSet: const {
            1: Color(0xFFD7ECBF),
            3: Color(0xFFB3E778),
            5: Color(0xFF239C27),
            10: Color(0xFF027C06),
          },
          cellSize: 14,
          targetYear: 2022,
        ),
      ),
    );
  }
}
