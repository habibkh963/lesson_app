import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PdfViewerController {
  static const MethodChannel _channel = MethodChannel('pdf_viewer_channel');

  String? _sessionId;
  String? get sessionId => _sessionId;

  int _pageCount = 0;
  int get pageCount => _pageCount;

  int _currentRotation = 0;
  int get currentRotation => _currentRotation;

  final _highlightsController = StreamController<List<Highlight>>.broadcast();
  Stream<List<Highlight>> get highlightsStream => _highlightsController.stream;

  List<Highlight> _highlights = [];
  List<Highlight> get highlights => List.unmodifiable(_highlights);

  // Open PDF from file path or asset
  Future<void> openPdf({
    String? filePath,
    String? assetPath,
    String? password,
  }) async {
    final result = await _channel.invokeMethod('openPdf', {
      'path': filePath,
      'assetPath': assetPath,
      'password': password,
    });

    _sessionId = result['sessionId'] as String;
    _pageCount = result['pageCount'] as int;
  }

  // Get rendered page as image path
  Future<PageData> getPage({
    required int pageIndex,
    int width = 800,
    int height = 1200,
    int quality = 2,
  }) async {
    _ensureSession();

    final result = await _channel.invokeMethod('getPage', {
      'sessionId': _sessionId,
      'pageIndex': pageIndex,
      'width': width,
      'height': height,
      'quality': quality,
    });

    _currentRotation = result['rotation'] as int;
    final highlights =
        (result['highlights'] as List)
            .map((h) => Highlight.fromMap(h))
            .toList();
    _highlights = highlights;
    _highlightsController.add(highlights);

    return PageData(
      imagePath: result['imagePath'] as String,
      width: result['width'] as int,
      height: result['height'] as int,
      rotation: _currentRotation,
      highlights: highlights,
    );
  }

  // Highlight a line by index or coordinates
  Future<Highlight> highlightLine({
    required int pageIndex,
    int? lineIndex,
    double? startX,
    double? startY,
    double? endX,
    double? endY,
    Color color = Colors.yellow,
    String? text,
  }) async {
    _ensureSession();

    final result = await _channel.invokeMethod('highlightLine', {
      'sessionId': _sessionId,
      'pageIndex': pageIndex,
      'lineIndex': lineIndex,
      'startX': startX,
      'startY': startY,
      'endX': endX,
      'endY': endY,
      'color': color.value,
      'text': text,
    });

    final highlight = Highlight(
      id: result['highlightId'] as String,
      pageIndex: pageIndex,
      type: 'line',
      rects:
          (result['rects'] as List)
              .map(
                (r) => Rect.fromLTRB(
                  (r['left'] as num).toDouble(),
                  (r['top'] as num).toDouble(),
                  (r['right'] as num).toDouble(),
                  (r['bottom'] as num).toDouble(),
                ),
              )
              .toList(),
      color: color,
    );

    _highlights.add(highlight);
    _highlightsController.add(List.from(_highlights));
    return highlight;
  }

  // Highlight a word
  Future<Highlight> highlightWord({
    required int pageIndex,
    String? word,
    double? x,
    double? y,
    Color color = Colors.green,
    bool caseSensitive = false,
  }) async {
    _ensureSession();

    final result = await _channel.invokeMethod('highlightWord', {
      'sessionId': _sessionId,
      'pageIndex': pageIndex,
      'word': word,
      'x': x,
      'y': y,
      'color': color.value,
      'caseSensitive': caseSensitive,
    });

    final highlight = Highlight(
      id: result['highlightId'] as String,
      pageIndex: pageIndex,
      type: 'word',
      rects:
          (result['rects'] as List)
              .map(
                (r) => Rect.fromLTRB(
                  (r['left'] as num).toDouble(),
                  (r['top'] as num).toDouble(),
                  (r['right'] as num).toDouble(),
                  (r['bottom'] as num).toDouble(),
                ),
              )
              .toList(),
      color: color,
    );

    _highlights.add(highlight);
    _highlightsController.add(List.from(_highlights));
    return highlight;
  }

  // Highlight a selected area (from drag selection)
  Future<Highlight> highlightSelection({
    required int pageIndex,
    required double startX,
    required double startY,
    required double endX,
    required double endY,
    Color color = Colors.yellow,
  }) async {
    _ensureSession();

    final result = await _channel.invokeMethod('highlightSelection', {
      'sessionId': _sessionId,
      'pageIndex': pageIndex,
      'startX': startX,
      'startY': startY,
      'endX': endX,
      'endY': endY,
      'color': color.value,
    });

    final highlight = Highlight(
      id: result['highlightId'] as String,
      pageIndex: pageIndex,
      type: 'selection',
      rects:
          (result['rects'] as List)
              .map(
                (r) => Rect.fromLTRB(
                  (r['left'] as num).toDouble(),
                  (r['top'] as num).toDouble(),
                  (r['right'] as num).toDouble(),
                  (r['bottom'] as num).toDouble(),
                ),
              )
              .toList(),
      color: color,
      text: result['text'] as String?,
    );

    _highlights.add(highlight);
    _highlightsController.add(List.from(_highlights));
    return highlight;
  }

  // Rotate page (preserves line alignment)
  Future<int> rotate({required int pageIndex, bool clockwise = true}) async {
    _ensureSession();

    final result = await _channel.invokeMethod('rotate', {
      'sessionId': _sessionId,
      'pageIndex': pageIndex,
      'direction': clockwise ? 'clockwise' : 'counterClockwise',
    });

    _currentRotation = result['rotation'] as int;
    return _currentRotation;
  }

  // Save PDF with highlights
  Future<String> savePdf({
    required String outputPath,
    bool burnHighlights = true,
  }) async {
    _ensureSession();

    final result = await _channel.invokeMethod('savePdf', {
      'sessionId': _sessionId,
      'outputPath': outputPath,
      'burnHighlights': burnHighlights,
    });

    return result['path'] as String;
  }

  // Extract text from page
  Future<PageText> extractText({required int pageIndex}) async {
    _ensureSession();

    final result = await _channel.invokeMethod('getText', {
      'sessionId': _sessionId,
      'pageIndex': pageIndex,
    });

    return PageText(
      text: result['text'] as String,
      lines:
          (result['lines'] as List)
              .map(
                (l) => TextLine(
                  index: l['index'] as int,
                  text: l['text'] as String,
                  bounds:
                      (l['bounds'] as List)
                          .map(
                            (r) => Rect.fromLTRB(
                              (r['left'] as num).toDouble(),
                              (r['top'] as num).toDouble(),
                              (r['right'] as num).toDouble(),
                              (r['bottom'] as num).toDouble(),
                            ),
                          )
                          .toList(),
                ),
              )
              .toList(),
    );
  }

  // Search text across all pages
  Future<List<SearchResult>> searchText({
    required String query,
    bool caseSensitive = false,
  }) async {
    _ensureSession();

    final result = await _channel.invokeMethod('searchText', {
      'sessionId': _sessionId,
      'query': query,
      'caseSensitive': caseSensitive,
    });

    return (result['results'] as List)
        .map(
          (r) => SearchResult(
            pageIndex: r['pageIndex'] as int,
            startIndex: r['startIndex'] as int,
            length: r['length'] as int,
            text: r['text'] as String,
            bounds:
                (r['bounds'] as List)
                    .map(
                      (b) => Rect.fromLTRB(
                        (b['left'] as num).toDouble(),
                        (b['top'] as num).toDouble(),
                        (b['right'] as num).toDouble(),
                        (b['bottom'] as num).toDouble(),
                      ),
                    )
                    .toList(),
          ),
        )
        .toList();
  }

  // Remove specific highlight
  Future<void> removeHighlight(String highlightId) async {
    _ensureSession();

    await _channel.invokeMethod('removeHighlight', {
      'sessionId': _sessionId,
      'highlightId': highlightId,
    });

    _highlights.removeWhere((h) => h.id == highlightId);
    _highlightsController.add(List.from(_highlights));
  }

  // Get all highlights
  Future<List<Highlight>> getHighlights({int? pageIndex}) async {
    _ensureSession();

    final result = await _channel.invokeMethod('getHighlights', {
      'sessionId': _sessionId,
      'pageIndex': pageIndex,
    });

    return (result['highlights'] as List)
        .map((h) => Highlight.fromMap(h))
        .toList();
  }

  // Clear all highlights
  Future<void> clearHighlights() async {
    _ensureSession();

    await _channel.invokeMethod('clearHighlights', {'sessionId': _sessionId});

    _highlights.clear();
    _highlightsController.add([]);
  }

  // Close PDF
  Future<void> close() async {
    if (_sessionId != null) {
      await _channel.invokeMethod('closePdf', {'sessionId': _sessionId});
      _sessionId = null;
      _pageCount = 0;
      _currentRotation = 0;
      _highlights.clear();
      _highlightsController.add([]);
    }
  }

  void _ensureSession() {
    if (_sessionId == null)
      throw StateError('No PDF opened. Call openPdf() first.');
  }

  void dispose() {
    close();
    _highlightsController.close();
  }
}

// ==================== Data Models ====================

class PageData {
  final String imagePath;
  final int width;
  final int height;
  final int rotation;
  final List<Highlight> highlights;

  PageData({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.rotation,
    required this.highlights,
  });
}

class Highlight {
  final String id;
  final int pageIndex;
  final String type;
  final List<Rect> rects;
  final Color color;
  final String? text;

  Highlight({
    required this.id,
    required this.pageIndex,
    required this.type,
    required this.rects,
    required this.color,
    this.text,
  });

  factory Highlight.fromMap(Map<dynamic, dynamic> map) {
    return Highlight(
      id: map['id'] as String,
      pageIndex: map['pageIndex'] as int,
      type: map['type'] as String,
      rects:
          (map['rects'] as List)
              .map(
                (r) => Rect.fromLTRB(
                  (r['left'] as num).toDouble(),
                  (r['top'] as num).toDouble(),
                  (r['right'] as num).toDouble(),
                  (r['bottom'] as num).toDouble(),
                ),
              )
              .toList(),
      color: Color(map['color'] as int),
      text: map['text'] as String?,
    );
  }
}

class PageText {
  final String text;
  final List<TextLine> lines;

  PageText({required this.text, required this.lines});
}

class TextLine {
  final int index;
  final String text;
  final List<Rect> bounds;

  TextLine({required this.index, required this.text, required this.bounds});
}

class SearchResult {
  final int pageIndex;
  final int startIndex;
  final int length;
  final String text;
  final List<Rect> bounds;

  SearchResult({
    required this.pageIndex,
    required this.startIndex,
    required this.length,
    required this.text,
    required this.bounds,
  });
}

// ==================== Flutter Widget ====================

class PdfViewer extends StatefulWidget {
  final PdfViewerController controller;
  final int initialPage;
  final void Function(int pageIndex)? onPageChanged;
  final void Function(List<Highlight> highlights)? onHighlightsChanged;

  const PdfViewer({
    Key? key,
    required this.controller,
    this.initialPage = 0,
    this.onPageChanged,
    this.onHighlightsChanged,
  }) : super(key: key);

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  int _currentPage = 0;
  PageData? _pageData;
  bool _isLoading = false;
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  // Selection state
  Offset? _selectionStart;
  Offset? _selectionEnd;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _loadPage();

    widget.controller.highlightsStream.listen((highlights) {
      widget.onHighlightsChanged?.call(highlights);
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadPage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final data = await widget.controller.getPage(pageIndex: _currentPage);
      setState(() {
        _pageData = data;
        _isLoading = false;
      });
      widget.onPageChanged?.call(_currentPage);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading page: $e');
    }
  }

  Future<void> _rotate(bool clockwise) async {
    await widget.controller.rotate(
      pageIndex: _currentPage,
      clockwise: clockwise,
    );
    await _loadPage();
  }

  Future<void> _highlightAtTap(TapDownDetails details) async {
    final size = context.size;
    if (size == null || _pageData == null) return;

    // Convert tap position to PDF coordinates
    final x = (details.localPosition.dx / size.width) * _pageData!.width;
    final y = (details.localPosition.dy / size.height) * _pageData!.height;

    // Highlight word at tap position
    await widget.controller.highlightWord(pageIndex: _currentPage, x: x, y: y);

    await _loadPage(); // Reload to show highlight
  }

  void _onDragStart(DragStartDetails details) {
    final size = context.size;
    if (size == null || _pageData == null) return;

    setState(() {
      _selectionStart = details.localPosition;
      _selectionEnd = details.localPosition;
      _isSelecting = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isSelecting) return;

    setState(() {
      _selectionEnd = details.localPosition;
    });
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (!_isSelecting || _selectionStart == null || _selectionEnd == null) {
      setState(() {
        _isSelecting = false;
        _selectionStart = null;
        _selectionEnd = null;
      });
      return;
    }

    final size = context.size;
    if (size == null || _pageData == null) return;

    // Convert selection coordinates to PDF coordinates
    final startX = (_selectionStart!.dx / size.width) * _pageData!.width;
    final startY = (_selectionStart!.dy / size.height) * _pageData!.height;
    final endX = (_selectionEnd!.dx / size.width) * _pageData!.width;
    final endY = (_selectionEnd!.dy / size.height) * _pageData!.height;

    // Normalize coordinates (ensure startX < endX and startY < endY)
    final normalizedStartX = startX < endX ? startX : endX;
    final normalizedStartY = startY < endY ? startY : endY;
    final normalizedEndX = startX < endX ? endX : startX;
    final normalizedEndY = startY < endY ? endY : startY;

    // Highlight the selected area
    await widget.controller.highlightSelection(
      pageIndex: _currentPage,
      startX: normalizedStartX,
      startY: normalizedStartY,
      endX: normalizedEndX,
      endY: normalizedEndY,
    );

    setState(() {
      _isSelecting = false;
      _selectionStart = null;
      _selectionEnd = null;
    });

    await _loadPage(); // Reload to show highlight
  }

  Rect? _getSelectionRect() {
    if (_selectionStart == null || _selectionEnd == null) return null;

    final left =
        _selectionStart!.dx < _selectionEnd!.dx
            ? _selectionStart!.dx
            : _selectionEnd!.dx;
    final top =
        _selectionStart!.dy < _selectionEnd!.dy
            ? _selectionStart!.dy
            : _selectionEnd!.dy;
    final right =
        _selectionStart!.dx > _selectionEnd!.dx
            ? _selectionStart!.dx
            : _selectionEnd!.dx;
    final bottom =
        _selectionStart!.dy > _selectionEnd!.dy
            ? _selectionStart!.dy
            : _selectionEnd!.dy;

    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        _buildToolbar(),

        // PDF View
        Expanded(
          child: GestureDetector(
            onTapDown: _highlightAtTap,
            onDoubleTap:
                () => setState(() => _scale = _scale == 1.0 ? 2.0 : 1.0),
            onPanStart: _onDragStart,
            onPanUpdate: _onDragUpdate,
            onPanEnd: _onDragEnd,
            child: Stack(
              children: [
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  scaleFactor: _scale,
                  onInteractionUpdate: (details) {
                    _scale = details.scale;
                    _offset = details.focalPoint;
                  },
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _pageData != null
                          ? Image.file(
                            File(_pageData!.imagePath),
                            fit: BoxFit.contain,
                          )
                          : const Center(child: Text('No page loaded')),
                ),
                // Selection overlay
                if (_isSelecting && _getSelectionRect() != null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SelectionPainter(_getSelectionRect()!),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Page indicator
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Page ${_currentPage + 1} / ${widget.controller.pageCount}',
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed:
                _currentPage > 0
                    ? () => setState(() {
                      _currentPage--;
                      _loadPage();
                    })
                    : null,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_left),
            onPressed: () => _rotate(false),
          ),
          IconButton(
            icon: const Icon(Icons.rotate_right),
            onPressed: () => _rotate(true),
          ),
          IconButton(
            icon: const Icon(Icons.highlight),
            onPressed: () async {
              // Highlight current line
              await widget.controller.highlightLine(
                pageIndex: _currentPage,
                lineIndex: 0,
              );
              await _loadPage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final path = await widget.controller.savePdf(
                outputPath: '/path/to/output.pdf',
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Saved to $path')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed:
                _currentPage < widget.controller.pageCount - 1
                    ? () => setState(() {
                      _currentPage++;
                      _loadPage();
                    })
                    : null,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// ==================== Selection Painter ====================

class SelectionPainter extends CustomPainter {
  final Rect selectionRect;

  SelectionPainter(this.selectionRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.yellow.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    canvas.drawRect(selectionRect, paint);
    canvas.drawRect(selectionRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! SelectionPainter ||
        oldDelegate.selectionRect != selectionRect;
  }
}
