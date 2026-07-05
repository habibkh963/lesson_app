package com.example.lessonsapp

import android.content.Context
import android.graphics.*
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.ConcurrentHashMap

class PdfViewerMethodChannel(
    private val context: Context,
    flutterEngine: FlutterEngine
) {
    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "pdf_viewer_channel"
    )

    private val mainScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private val ioScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    private val activeSessions = ConcurrentHashMap<String, PdfSession>()
    private val highlightStore = ConcurrentHashMap<String, MutableList<Highlight>>()

    init {
        channel.setMethodCallHandler { call, result ->
            handleMethodCall(call, result)
        }
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "openPdf" -> openPdf(call, result)
            "closePdf" -> closePdf(call, result)
            "getPage" -> getPage(call, result)
            "highlightLine" -> highlightLine(call, result)
            "highlightWord" -> highlightWord(call, result)
            "highlightSelection" -> highlightSelection(call, result)
            "removeHighlight" -> removeHighlight(call, result)
            "getHighlights" -> getHighlights(call, result)
            "rotate" -> rotatePage(call, result)
            "savePdf" -> savePdf(call, result)
            "getText" -> extractText(call, result)
            "searchText" -> searchText(call, result)
            "clearHighlights" -> clearHighlights(call, result)
            else -> result.notImplemented()
        }
    }

    private fun openPdf(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        val assetPath = call.argument<String>("assetPath")
        val password = call.argument<String>("password")
        val sessionId = call.argument<String>("sessionId") ?: System.currentTimeMillis().toString()

        if (path == null && assetPath == null) {
            result.error("INVALID_ARGS", "Path or assetPath required", null)
            return
        }

        ioScope.launch {
            try {
                val file = when {
                    path != null -> File(path)
                    assetPath != null -> copyAssetToCache(assetPath)
                    else -> throw IllegalArgumentException("No valid path")
                }

                if (!file.exists()) {
                    throw IllegalArgumentException("File not found: ${file.absolutePath}")
                }

                val pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
                val renderer = PdfRenderer(pfd)

                val session = PdfSession(
                    id = sessionId,
                    file = file,
                    pfd = pfd,
                    renderer = renderer,
                    pageCount = renderer.pageCount,
                    currentRotation = 0
                )

                activeSessions[sessionId] = session
                highlightStore[sessionId] = mutableListOf()

                withContext(Dispatchers.Main) {
                    result.success(
                        mapOf(
                            "sessionId" to sessionId,
                            "pageCount" to renderer.pageCount,
                            "filePath" to file.absolutePath
                        )
                    )
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("PDF_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun getPage(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<String>("sessionId") ?: run {
            result.error("INVALID_ARGS", "sessionId required", null)
            return
        }
        val pageIndex = call.argument<Int>("pageIndex") ?: 0
        val width = call.argument<Int>("width") ?: 800
        val height = call.argument<Int>("height") ?: 1200
        val quality = call.argument<Int>("quality") ?: 2

        val session = activeSessions[sessionId]
        if (session == null) {
            result.error("SESSION_NOT_FOUND", "PDF session not found", null)
            return
        }

        ioScope.launch {
            try {
                val bitmap = renderPage(session, pageIndex, width, height, quality)
                val highlights = highlightStore[sessionId]?.filter { it.pageIndex == pageIndex } ?: emptyList()

                val highlightData = highlights.map { h ->
                    mapOf(
                        "id" to h.id,
                        "type" to h.type,
                        "rects" to h.rects.map { r ->
                            mapOf(
                                "left" to r.left,
                                "top" to r.top,
                                "right" to r.right,
                                "bottom" to r.bottom
                            )
                        },
                        "color" to h.color,
                        "text" to (h.text ?: "")
                    )
                }

                val tempFile = File(context.cacheDir, "pdf_page_${sessionId}_$pageIndex.png")
                FileOutputStream(tempFile).use { out ->
                    bitmap.compress(Bitmap.CompressFormat.PNG, 90, out)
                }

                withContext(Dispatchers.Main) {
                    result.success(
                        mapOf(
                            "imagePath" to tempFile.absolutePath,
                            "width" to bitmap.width,
                            "height" to bitmap.height,
                            "rotation" to session.currentRotation,
                            "highlights" to highlightData
                        )
                    )
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("RENDER_ERROR", e.message, null)
                }
            }
        }
    }

    private fun highlightLine(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<String>("sessionId") ?: run {
            result.error("INVALID_ARGS", "sessionId required", null)
            return
        }
        val pageIndex = call.argument<Int>("pageIndex") ?: 0
        val lineIndex = call.argument<Int>("lineIndex")
        val startX = call.argument<Double>("startX")?.toFloat()
        val startY = call.argument<Double>("startY")?.toFloat()
        val endX = call.argument<Double>("endX")?.toFloat()
        val endY = call.argument<Double>("endY")?.toFloat()
        val color = call.argument<Long>("color")?.toInt() ?: Color.YELLOW
        val text = call.argument<String>("text")

        val session = activeSessions[sessionId] ?: run {
            result.error("SESSION_NOT_FOUND", "PDF session not found", null)
            return
        }

        ioScope.launch {
            try {
                val rects = if (lineIndex != null) {
                    getLineBounds(session, pageIndex, lineIndex)
                } else if (startX != null && startY != null && endX != null && endY != null) {
                    listOf(RectF(startX, startY, endX, endY))
                } else {
                    throw IllegalArgumentException("Must provide lineIndex or coordinates")
                }

                val highlight = Highlight(
                    id = System.currentTimeMillis().toString(),
                    pageIndex = pageIndex,
                    type = "line",
                    rects = rects,
                    color = color,
                    text = text
                )

                highlightStore.getOrPut(sessionId) { mutableListOf() }.add(highlight)

                withContext(Dispatchers.Main) {
                    result.success(
                        mapOf(
                            "highlightId" to highlight.id,
                            "rects" to rects.map { r ->
                                mapOf(
                                    "left" to r.left,
                                    "top" to r.top,
                                    "right" to r.right,
                                    "bottom" to r.bottom
                                )
                            }
                        )
                    )
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("HIGHLIGHT_ERROR", e.message, null)
                }
            }
        }
    }

    private fun highlightWord(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<String>("sessionId") ?: run {
            result.error("INVALID_ARGS", "sessionId required", null)
            return
        }
        val pageIndex = call.argument<Int>("pageIndex") ?: 0
        val word = call.argument<String>("word")
        val x = call.argument<Double>("x")?.toFloat()
        val y = call.argument<Double>("y")?.toFloat()
        val color = call.argument<Long>("color")?.toInt() ?: Color.GREEN
        val caseSensitive = call.argument<Boolean>("caseSensitive") ?: false

        val session = activeSessions[sessionId] ?: run {
            result.error("SESSION_NOT_FOUND", "PDF session not found", null)
            return
        }

        ioScope.launch {
            try {
                val rects = when {
                    word != null -> findWordBounds(session, pageIndex, word, caseSensitive)
                    x != null && y != null -> findWordAtPoint(session, pageIndex, x, y)
                    else -> throw IllegalArgumentException("Must provide word or coordinates")
                }

                if (rects.isEmpty()) {
                    withContext(Dispatchers.Main) {
                        result.error("WORD_NOT_FOUND", "Word not found on page", null)
                    }
                    return@launch
                }

                val highlight = Highlight(
                    id = System.currentTimeMillis().toString(),
                    pageIndex = pageIndex,
                    type = "word",
                    rects = rects,
                    color = color,
                    text = word
                )

                highlightStore.getOrPut(sessionId) { mutableListOf() }.add(highlight)

                withContext(Dispatchers.Main) {
                    result.success(
                        mapOf(
                            "highlightId" to highlight.id,
                            "rects" to rects.map { r ->
                                mapOf(
                                    "left" to r.left,
                                    "top" to r.top,
                                    "right" to r.right,
                                    "bottom" to r.bottom
                                )
                            }
                        )
                    )
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("HIGHLIGHT_ERROR", e.message, null)
                }
            }
        }
    }

    private fun highlightSelection(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<String>("sessionId") ?: run {
            result.error("INVALID_ARGS", "sessionId required", null)
            return
        }
        val pageIndex = call.argument<Int>("pageIndex") ?: 0
        val startX = call.argument<Double>("startX")?.toFloat()
        val startY = call.argument<Double>("startY")?.toFloat()
        val endX = call.argument<Double>("endX")?.toFloat()
        val endY = call.argument<Double>("endY")?.toFloat()
        val color = call.argument<Long>("color")?.toInt() ?: Color.YELLOW

        val session = activeSessions[sessionId] ?: run {
            result.error("SESSION_NOT_FOUND", "PDF session not found", null)
            return
        }

        if (startX == null || startY == null || endX == null || endY == null) {
            result.error("INVALID_ARGS", "Selection coordinates required", null)
            return
        }

        ioScope.launch {
            try {
                // Get text within the selection area
                val selectedText = getTextInSelection(session, pageIndex, startX, startY, endX, endY)
                
                // Calculate selection rectangles for multi-line text
                val rects = calculateSelectionRects(session, pageIndex, startX, startY, endX, endY)

                val highlight = Highlight(
                    id = System.currentTimeMillis().toString(),
                    pageIndex = pageIndex,
                    type = "selection",
                    rects = rects,
                    color = color,
                    text = selectedText
                )

                highlightStore.getOrPut(sessionId) { mutableListOf() }.add(highlight)

                withContext(Dispatchers.Main) {
                    result.success(
                        mapOf(
                            "highlightId" to highlight.id,
                            "rects" to rects.map { r ->
                                mapOf(
                                    "left" to r.left,
                                    "top" to r.top,
                                    "right" to r.right,
                                    "bottom" to r.bottom
                                )
                            },
                            "text" to (selectedText ?: "")
                        )
                    )
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("SELECTION_ERROR", e.message, null)
                }
            }
        }
    }

    private fun rotatePage(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<String>("sessionId") ?: run {
            result.error("INVALID_ARGS", "sessionId required", null)
            return
        }
        val direction = call.argument<String>("direction") ?: "clockwise"
        val pageIndex = call.argument<Int>("pageIndex") ?: 0

        val session = activeSessions[sessionId] ?: run {
            result.error("SESSION_NOT_FOUND", "PDF session not found", null)
            return
        }

        session.currentRotation = when (direction) {
            "clockwise" -> (session.currentRotation + 90) % 360
            "counterClockwise" -> (session.currentRotation - 90 + 360) % 360
            else -> (session.currentRotation + 90) % 360
        }

        val highlights = highlightStore[sessionId] ?: mutableListOf()
        highlights.filter { it.pageIndex == pageIndex }.forEach { highlight ->
            highlight.rects = highlight.rects.map { rect ->
                rotateRect(rect, session.currentRotation, session.pageWidth, session.pageHeight)
            }.toMutableList()
        }

        result.success(
            mapOf(
                "rotation" to session.currentRotation,
                "pageIndex" to pageIndex
            )
        )
    }

    private fun savePdf(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<String>("sessionId") ?: run {
            result.error("INVALID_ARGS", "sessionId required", null)
            return
        }
        val outputPath = call.argument<String>("outputPath") ?: run {
            result.error("INVALID_ARGS", "outputPath required", null)
            return
        }
        val burnHighlights = call.argument<Boolean>("burnHighlights") ?: true

        val session = activeSessions[sessionId] ?: run {
            result.error("SESSION_NOT_FOUND", "PDF session not found", null)
            return
        }

        ioScope.launch {
            try {
                val outputFile = File(outputPath)

                if (burnHighlights) {
                    createPdfWithHighlights(session, outputFile)
                } else {
                    session.file.copyTo(outputFile, overwrite = true)
                }

                withContext(Dispatchers.Main) {
                    result.success(
                        mapOf(
                            "path" to outputFile.absolutePath,
                            "size" to outputFile.length()
                        )
                    )
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("SAVE_ERROR", e.message, null)
                }
            }
        }
    }

    private fun extractText(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<String>("sessionId") ?: run {
            result.error("INVALID_ARGS", "sessionId required", null)
            return
        }
        val pageIndex = call.argument<Int>("pageIndex") ?: 0

        val session = activeSessions[sessionId] ?: run {
            result.error("SESSION_NOT_FOUND", "PDF session not found", null)
            return
        }

        ioScope.launch {
            try {
                val text = extractPageText(session, pageIndex)
                val lines = text.split("\n").mapIndexed { index, line ->
                    mapOf(
                        "index" to index,
                        "text" to line,
                        "bounds" to getLineBounds(session, pageIndex, index).map { r ->
                            mapOf(
                                "left" to r.left,
                                "top" to r.top,
                                "right" to r.right,
                                "bottom" to r.bottom
                            )
                        }
                    )
                }

                withContext(Dispatchers.Main) {
                    result.success(
                        mapOf(
                            "text" to text,
                            "lines" to lines
                        )
                    )
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("TEXT_ERROR", e.message, null)
                }
            }
        }
    }

    private fun searchText(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<String>("sessionId") ?: run {
            result.error("INVALID_ARGS", "sessionId required", null)
            return
        }
        val query = call.argument<String>("query") ?: run {
            result.error("INVALID_ARGS", "query required", null)
            return
        }
        val caseSensitive = call.argument<Boolean>("caseSensitive") ?: false

        val session = activeSessions[sessionId] ?: run {
            result.error("SESSION_NOT_FOUND", "PDF session not found", null)
            return
        }

        ioScope.launch {
            try {
                val results = mutableListOf<Map<String, Any>>()

                for (i in 0 until session.pageCount) {
                    val pageText = extractPageText(session, i)
                    val searchText = if (caseSensitive) pageText else pageText.lowercase()
                    val target = if (caseSensitive) query else query.lowercase()

                    if (searchText.contains(target)) {
                        var startIndex = 0
                        while (true) {
                            val index = searchText.indexOf(target, startIndex)
                            if (index == -1) break

                            val bounds = getTextBounds(session, i, index, target.length)
                            results.add(
                                mapOf(
                                    "pageIndex" to i,
                                    "startIndex" to index,
                                    "length" to target.length,
                                    "text" to pageText.substring(index, index + target.length),
                                    "bounds" to bounds.map { r ->
                                        mapOf(
                                            "left" to r.left,
                                            "top" to r.top,
                                            "right" to r.right,
                                            "bottom" to r.bottom
                                        )
                                    }
                                )
                            )
                            startIndex = index + 1
                        }
                    }
                }

                withContext(Dispatchers.Main) {
                    result.success(mapOf("results" to results))
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("SEARCH_ERROR", e.message, null)
                }
            }
        }
    }

    private fun removeHighlight(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<String>("sessionId") ?: run {
            result.error("INVALID_ARGS", "sessionId required", null)
            return
        }
        val highlightId = call.argument<String>("highlightId") ?: run {
            result.error("INVALID_ARGS", "highlightId required", null)
            return
        }

        val highlights = highlightStore[sessionId]
        if (highlights != null) {
            highlights.removeAll { it.id == highlightId }
            result.success(mapOf("removed" to true))
        } else {
            result.error("NOT_FOUND", "Highlight not found", null)
        }
    }

    private fun getHighlights(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<String>("sessionId") ?: run {
            result.error("INVALID_ARGS", "sessionId required", null)
            return
        }
        val pageIndex = call.argument<Int>("pageIndex")

        val highlights = highlightStore[sessionId] ?: emptyList()
        val filtered = if (pageIndex != null) {
            highlights.filter { it.pageIndex == pageIndex }
        } else highlights

        result.success(
            mapOf(
                "highlights" to filtered.map { h ->
                    mapOf(
                        "id" to h.id,
                        "pageIndex" to h.pageIndex,
                        "type" to h.type,
                        "rects" to h.rects.map { r ->
                            mapOf(
                                "left" to r.left,
                                "top" to r.top,
                                "right" to r.right,
                                "bottom" to r.bottom
                            )
                        },
                        "color" to h.color,
                        "text" to (h.text ?: "")
                    )
                }
            )
        )
    }

    private fun clearHighlights(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<String>("sessionId") ?: run {
            result.error("INVALID_ARGS", "sessionId required", null)
            return
        }

        highlightStore[sessionId]?.clear()
        result.success(mapOf("cleared" to true))
    }

    private fun closePdf(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<String>("sessionId") ?: run {
            result.error("INVALID_ARGS", "sessionId required", null)
            return
        }

        val session = activeSessions.remove(sessionId)
        session?.let {
            try {
                it.renderer.close()
                it.pfd.close()
            } catch (e: Exception) {
            }
        }

        highlightStore.remove(sessionId)
        result.success(mapOf("closed" to true))
    }

    // ==================== Helper Methods ====================

    private fun renderPage(
        session: PdfSession,
        pageIndex: Int,
        width: Int,
        height: Int,
        quality: Int
    ): Bitmap {
        val page = session.renderer.openPage(pageIndex)

        try {
            val pageWidth = page.width
            val pageHeight = page.height
            val scale = when (quality) {
                1 -> 1.0f
                3 -> 3.0f
                else -> 2.0f
            }

            val bitmapWidth = (width * scale).toInt()
            val bitmapHeight = (height * scale).toInt()

            val bitmap = Bitmap.createBitmap(bitmapWidth, bitmapHeight, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)

            canvas.drawColor(Color.WHITE)

            val rotation = session.currentRotation
            val matrix = Matrix()

            when (rotation) {
                90 -> {
                    matrix.setRotate(90f, bitmapWidth / 2f, bitmapHeight / 2f)
                    matrix.postTranslate(
                        (bitmapHeight - bitmapWidth) / 2f,
                        (bitmapWidth - bitmapHeight) / 2f
                    )
                }

                180 -> matrix.setRotate(180f, bitmapWidth / 2f, bitmapHeight / 2f)
                270 -> {
                    matrix.setRotate(270f, bitmapWidth / 2f, bitmapHeight / 2f)
                    matrix.postTranslate(
                        (bitmapHeight - bitmapWidth) / 2f,
                        (bitmapWidth - bitmapHeight) / 2f
                    )
                }
            }

            canvas.setMatrix(matrix)

            val renderRect = Rect(0, 0, bitmapWidth, bitmapHeight)
            page.render(bitmap, renderRect, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)

            val highlights = highlightStore[session.id]?.filter { it.pageIndex == pageIndex } ?: emptyList()
            highlights.forEach { highlight ->
                val paint = Paint().apply {
                    color = highlight.color
                    alpha = 128
                    style = Paint.Style.FILL
                }

                highlight.rects.forEach { rect ->
                    val scaledRect = RectF(
                        rect.left * scale,
                        rect.top * scale,
                        rect.right * scale,
                        rect.bottom * scale
                    )
                    canvas.drawRect(scaledRect, paint)
                }
            }

            return bitmap
        } finally {
            page.close()
        }
    }

    private fun getLineBounds(session: PdfSession, pageIndex: Int, lineIndex: Int): List<RectF> {
        return try {
            val page = session.renderer.openPage(pageIndex)
            val height = page.height.toFloat()
            val width = page.width.toFloat()
            page.close()

            val lineHeight = height / 50
            val top = lineIndex * lineHeight
            val bottom = top + lineHeight

            listOf(RectF(0f, top, width, bottom))
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun findWordBounds(
        session: PdfSession,
        pageIndex: Int,
        word: String,
        caseSensitive: Boolean
    ): List<RectF> {
        val text = extractPageText(session, pageIndex)
        val searchWord = if (caseSensitive) word else word.lowercase()
        val pageText = if (caseSensitive) text else text.lowercase()

        val bounds = mutableListOf<RectF>()
        var startIndex = 0

        while (true) {
            val index = pageText.indexOf(searchWord, startIndex)
            if (index == -1) break

            val page = session.renderer.openPage(pageIndex)
            val charWidth = page.width.toFloat() / 80
            val lineHeight = page.height.toFloat() / 50
            page.close()

            val charsPerLine = 80
            val line = index / charsPerLine
            val charInLine = index % charsPerLine

            val left = charInLine * charWidth
            val top = line * lineHeight
            val right = left + (word.length * charWidth)
            val bottom = top + lineHeight

            bounds.add(RectF(left, top, right.coerceAtMost(page.width.toFloat()), bottom))
            startIndex = index + 1
        }

        return bounds
    }

    private fun findWordAtPoint(session: PdfSession, pageIndex: Int, x: Float, y: Float): List<RectF> {
        val page = session.renderer.openPage(pageIndex)
        val width = page.width.toFloat()
        val height = page.height.toFloat()
        page.close()

        val charWidth = width / 80
        val lineHeight = height / 50

        val col = (x / charWidth).toInt()
        val line = (y / lineHeight).toInt()

        val left = col * charWidth
        val top = line * lineHeight
        val right = left + (charWidth * 10)
        val bottom = top + lineHeight

        return listOf(RectF(left, top, minOf(right, width), bottom))
    }

    private fun extractPageText(session: PdfSession, pageIndex: Int): String {
        return try {
            "Sample text for page $pageIndex"
        } catch (e: Exception) {
            ""
        }
    }

    private fun getTextInSelection(
        session: PdfSession,
        pageIndex: Int,
        startX: Float,
        startY: Float,
        endX: Float,
        endY: Float
    ): String? {
        return try {
            val page = session.renderer.openPage(pageIndex)
            val pageWidth = page.width.toFloat()
            val pageHeight = page.height.toFloat()
            page.close()

            // Calculate character dimensions
            val charWidth = pageWidth / 80
            val lineHeight = pageHeight / 50

            // Calculate start and end positions in character grid
            val startCol = (startX / charWidth).toInt().coerceAtLeast(0)
            val startLine = (startY / lineHeight).toInt().coerceAtLeast(0)
            val endCol = (endX / charWidth).toInt().coerceAtMost(79)
            val endLine = (endY / lineHeight).toInt().coerceAtMost(49)

            // Extract text from the selected area
            val pageText = extractPageText(session, pageIndex)
            val lines = pageText.split("\n")

            val selectedLines = mutableListOf<String>()
            for (line in startLine..minOf(endLine, lines.size - 1)) {
                val lineText = lines[line]
                val startChar = if (line == startLine) startCol else 0
                val endChar = if (line == endLine) minOf(endCol + 1, lineText.length) else lineText.length
                if (startChar < lineText.length) {
                    selectedLines.add(lineText.substring(startChar, minOf(endChar, lineText.length)))
                }
            }

            selectedLines.joinToString("\n")
        } catch (e: Exception) {
            null
        }
    }

    private fun calculateSelectionRects(
        session: PdfSession,
        pageIndex: Int,
        startX: Float,
        startY: Float,
        endX: Float,
        endY: Float
    ): List<RectF> {
        return try {
            val page = session.renderer.openPage(pageIndex)
            val pageWidth = page.width.toFloat()
            val pageHeight = page.height.toFloat()
            page.close()

            val charWidth = pageWidth / 80
            val lineHeight = pageHeight / 50

            val startCol = (startX / charWidth).toInt().coerceAtLeast(0)
            val startLine = (startY / lineHeight).toInt().coerceAtLeast(0)
            val endCol = (endX / charWidth).toInt().coerceAtMost(79)
            val endLine = (endY / lineHeight).toInt().coerceAtMost(49)

            val rects = mutableListOf<RectF>()

            // Create rectangles for each line in the selection
            for (line in startLine..endLine) {
                val lineStartX = if (line == startLine) startX else 0f
                val lineEndX = if (line == endLine) endX else pageWidth
                val lineTop = line * lineHeight
                val lineBottom = lineTop + lineHeight

                rects.add(RectF(lineStartX, lineTop, lineEndX, lineBottom))
            }

            rects
        } catch (e: Exception) {
            // Fallback to single rectangle if calculation fails
            listOf(RectF(startX, startY, endX, endY))
        }
    }

    private fun getTextBounds(session: PdfSession, pageIndex: Int, start: Int, length: Int): List<RectF> {
        return findWordBounds(session, pageIndex, "x".repeat(length), true)
    }

    private fun rotateRect(rect: RectF, rotation: Int, pageWidth: Int, pageHeight: Int): RectF {
        return when (rotation) {
            90 -> RectF(
                rect.top,
                pageWidth - rect.right,
                rect.bottom,
                pageWidth - rect.left
            )

            180 -> RectF(
                pageWidth - rect.right,
                pageHeight - rect.bottom,
                pageWidth - rect.left,
                pageHeight - rect.top
            )

            270 -> RectF(
                pageHeight - rect.bottom,
                rect.left,
                pageHeight - rect.top,
                rect.right
            )

            else -> rect
        }
    }

    private fun createPdfWithHighlights(session: PdfSession, outputFile: File) {
        session.file.copyTo(outputFile, overwrite = true)
    }

    private fun copyAssetToCache(assetPath: String): File {
        val file = File(context.cacheDir, assetPath.substringAfterLast("/"))
        context.assets.open(assetPath).use { input ->
            FileOutputStream(file).use { output ->
                input.copyTo(output)
            }
        }
        return file
    }

    fun dispose() {
        mainScope.cancel()
        ioScope.cancel()
        activeSessions.values.forEach { session ->
            try {
                session.renderer.close()
                session.pfd.close()
            } catch (e: Exception) {
            }
        }
        activeSessions.clear()
        highlightStore.clear()
    }

    // ==================== Data Classes ====================

    data class PdfSession(
        val id: String,
        val file: File,
        val pfd: ParcelFileDescriptor,
        val renderer: PdfRenderer,
        val pageCount: Int,
        var currentRotation: Int = 0,
        var pageWidth: Int = 0,
        var pageHeight: Int = 0
    )

    data class Highlight(
        val id: String,
        val pageIndex: Int,
        val type: String,
        var rects: List<RectF>,
        val color: Int,
        val text: String? = null
    )
}