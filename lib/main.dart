// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

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
            {DateTime(2023, 1, 2): 2},
            {DateTime(2023, 1, 3): 6},
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
          cellSize: 16.0,
          padding: const EdgeInsets.all(4.0),
        ),
      ),
    );
  }
}

class Heatmap extends StatefulWidget {
  final List<Map<DateTime, int>> data;
  final Map<int, Color> colorSet;
  final double cellSize;
  final EdgeInsets padding;
  final Color? defaultColor;

  const Heatmap({
    super.key,
    required this.data,
    required this.colorSet,
    this.cellSize = 16.0,
    this.padding = const EdgeInsets.all(0.0),
    this.defaultColor,
  });

  @override
  _HeatmapState createState() => _HeatmapState();
}

class _HeatmapState extends State<Heatmap> {
  DateTime? _selectedDate;
  late OverlayEntry _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: widget.padding,
        child: GestureDetector(
          onLongPress: () {
            // PopupMenuを表示
            _showPopupMenu(context);
          },
          onLongPressUp: () {
            if (_overlayEntry.mounted) {
              _overlayEntry.remove();
            }
          },
          child: SizedBox(
            height: (widget.cellSize * 7) + widget.padding.vertical,
            child: CustomPaint(
              painter: HeatmapPainter(
                  data: widget.data,
                  colorSet: widget.colorSet,
                  cellSize: widget.cellSize,
                  onTapCell: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }),
              size: Size(
                  widget.cellSize * (365 ~/ 7) + widget.padding.horizontal,
                  (widget.cellSize * 7) + widget.padding.vertical),
            ),
          ),
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    if (_selectedDate == null) return;

    var overlay = Overlay.of(context);
    var overlayPosition = OverlayEntry(
      builder: (context) => Positioned(
        top: 140, // 位置は適切に調整してください。
        left: MediaQuery.sizeOf(context).width * 0.4, // 位置は適切に調整してください。
        child: Material(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _selectedDate!.toLocal().toIso8601String().split('T').first,
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayPosition);
    _overlayEntry = overlayPosition;
  }
}

class HeatmapPainter extends CustomPainter {
  final List<Map<DateTime, int>> data;
  final Map<int, Color> colorSet;
  final double cellSize;
  final void Function(DateTime date)? onTapCell;
  final Color? defaultColor;

  HeatmapPainter({
    this.data = const [],
    this.colorSet = const {},
    this.cellSize = 16.0,
    this.onTapCell,
    this.defaultColor,
  });

  @override
  bool? hitTest(Offset position) {
    // セルの位置を計算
    int week = (position.dx ~/ cellSize).toInt();
    int day = (position.dy ~/ cellSize).toInt();

    DateTime selectedDate = DateTime(DateTime.now().year, 1, 1)
        .add(Duration(days: (week * 7) + day));
    onTapCell!(selectedDate);

    return super.hitTest(position);
  }

  Color _getColorFromSet(int value) {
    List<int> thresholds = colorSet.keys.toList()..sort();
    for (var threshold in thresholds) {
      if (value <= threshold) return colorSet[threshold]!;
    }
    return defaultColor ?? Colors.grey[300]!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double borderThickness = 0.5;
    DateTime currentYearStartDate = DateTime(DateTime.now().year, 1, 1);

    for (int week = 0; week < (365 ~/ 7); week++) {
      for (int day = 0; day < 7; day++) {
        double x = week * cellSize;
        double y = day * cellSize;

        Map<DateTime, int>? matchingData = data.firstWhere(
            (item) => item.containsKey(
                currentYearStartDate.add(Duration(days: (week * 7) + day))),
            orElse: () => {});

        Color cellColor = Colors.grey[300]!;
        if (matchingData.isNotEmpty) {
          int value = matchingData.values.first;
          cellColor = _getColorFromSet(value);
        }

        canvas.drawRect(
          Rect.fromPoints(
            Offset(x, y),
            Offset(
                x + cellSize - borderThickness, y + cellSize - borderThickness),
          ),
          Paint()..color = cellColor,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
