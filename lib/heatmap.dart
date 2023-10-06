import 'package:flutter/material.dart';

/// `Heatmap` ウィジェットは日時データに基づいてヒートマップを表示します。
///
/// - [data]: ヒートマップのデータ。heat
/// - [colorSet]: 値ごとの色セット。
/// - [cellSize]: 各セルのサイズ。
/// - [defaultColor]: デフォルトのセル色。
/// - [targetYear]: ヒートマップの対象年。
///
class Heatmap extends StatefulWidget {
  final List<Map<DateTime, int>> data;
  final Map<int, Color> colorSet;
  final double cellSize;
  final Color? defaultColor;
  final int? targetYear;

  const Heatmap({
    super.key,
    required this.data,
    required this.colorSet,
    this.cellSize = 16.0,
    this.defaultColor,
    this.targetYear,
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
          height: (widget.cellSize * 7),
          child: CustomPaint(
            painter: HeatmapPainter(
                data: widget.data,
                colorSet: widget.colorSet,
                cellSize: widget.cellSize,
                targetYear: widget.targetYear,
                onTapCell: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                }),
            size: Size(widget.cellSize * (365 ~/ 7), (widget.cellSize * 7)),
          ),
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    if (_selectedDate == null) return;

    OverlayState overlay = Overlay.of(context);
    OverlayEntry overlayPosition = OverlayEntry(
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

/// `HeatmapPainter` クラスは、ヒートマップのカスタム描画を行います。
///
/// - [data]: ヒートマップのデータ。
/// - [colorSet]: 値ごとの色セット。
/// - [cellSize]: 各セルのサイズ。
/// - [onTapCell]: セルがタップされたときのコールバック。
/// - [defaultColor]: デフォルトのセル色。
/// - [targetYear]: ヒートマップの対象年。
///
class HeatmapPainter extends CustomPainter {
  HeatmapPainter({
    required this.data,
    this.colorSet = const {},
    this.cellSize = 16.0,
    this.onTapCell,
    this.defaultColor,
    this.targetYear,
  });

  final List<Map<DateTime, int>> data;
  final Map<int, Color> colorSet;
  final double cellSize;
  final void Function(DateTime date)? onTapCell;
  final Color? defaultColor;
  final int? targetYear;

  @override
  bool? hitTest(Offset position) {
    // セルの位置を計算
    int week = (position.dx ~/ cellSize).toInt();
    int day = (position.dy ~/ cellSize).toInt();

    int targetYearNumber = targetYear ?? DateTime.now().year;

    DateTime selectedDate =
        DateTime(targetYearNumber, 1, 1).add(Duration(days: (week * 7) + day));
    if (onTapCell != null) {
      onTapCell!(selectedDate);
    }

    return super.hitTest(position);
  }

  Color _getColorFromSet(int value) {
    List<int> thresholds = colorSet.keys.toList()..sort();
    for (final threshold in thresholds) {
      if (value <= threshold) return colorSet[threshold]!;
    }
    return defaultColor ?? Colors.grey[300]!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double borderThickness = 0.5;

    int targetYearNumber = targetYear ?? DateTime.now().year;

    DateTime currentYearStartDate = DateTime(targetYearNumber, 1, 1);

    // Filter data for the target year
    List<Map<DateTime, int>> filteredData = data
        .where((item) => item.keys.any((key) => key.year == targetYearNumber))
        .toList();

    for (int week = 0; week < (365 ~/ 7); week++) {
      for (int day = 0; day < 7; day++) {
        double x = week * cellSize;
        double y = day * cellSize;

        DateTime currentCellDate =
            currentYearStartDate.add(Duration(days: (week * 7) + day));

        Map<DateTime, int>? matchingData = filteredData.firstWhere(
            (item) =>
                item.keys.any((key) => key.isAtSameMomentAs(currentCellDate)),
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
              x + cellSize - borderThickness,
              y + cellSize - borderThickness,
            ),
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
