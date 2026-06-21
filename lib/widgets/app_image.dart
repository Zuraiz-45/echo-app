import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// A premium, self-contained Shimmer loading effect that shifts a linear gradient.
class ShimmerPlaceholder extends StatefulWidget {
  final double? width;
  final double? height;
  final bool isCircular;
  final double borderRadius;

  const ShimmerPlaceholder({
    Key? key,
    this.width,
    this.height,
    this.isCircular = false,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [
                0.1,
                0.3,
                0.4,
              ],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: baseColor,
              shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: widget.isCircular
                  ? null
                  : BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double w = bounds.width;
    return Matrix4.translationValues(w * (slidePercent - 0.5) * 2, 0.0, 0.0);
  }
}

/// Reusable AppImage widget that accepts a Base64 string or an HTTP network URL,
/// providing loading shimmer and fallback icons in both circular (avatar)
/// and rectangular (card) formats.
class AppImage extends StatefulWidget {
  final String? imageData;
  final bool isCircular;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData? fallbackIcon;

  const AppImage({
    Key? key,
    required this.imageData,
    this.isCircular = false,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 20.0,
    this.fallbackIcon,
  }) : super(key: key);

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  Future<Uint8List?>? _decodeFuture;

  @override
  void initState() {
    super.initState();
    _decodeFuture = _initDecode();
  }

  @override
  void didUpdateWidget(covariant AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageData != widget.imageData) {
      setState(() {
        _decodeFuture = _initDecode();
      });
    }
  }

  Future<Uint8List?> _initDecode() async {
    final data = widget.imageData;
    if (data == null || data.trim().isEmpty) return null;

    // Check if it's a network URL
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return null;
    }

    // Delay decode slightly to allow layout and build to register loading state
    await Future<void>.delayed(Duration.zero);
    return _decodeBase64(data);
  }

  Uint8List? _decodeBase64(String base64Str) {
    try {
      String cleanStr = base64Str.trim();
      if (cleanStr.contains(',')) {
        cleanStr = cleanStr.split(',').last;
      }
      cleanStr = cleanStr.replaceAll(RegExp(r'\s+'), '');
      return base64Decode(cleanStr);
    } catch (e) {
      debugPrint('AppImage: Error decoding base64 string: $e');
      return null;
    }
  }

  Widget _buildFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final iconColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: bgColor,
        shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: widget.isCircular ? null : BorderRadius.circular(widget.borderRadius),
      ),
      child: Center(
        child: Icon(
          widget.fallbackIcon ?? (widget.isCircular ? Icons.person : Icons.image_not_supported),
          color: iconColor,
          size: widget.isCircular ? (widget.width != null ? widget.width! * 0.5 : 24) : 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.imageData;

    // Empty or Null data fallback
    if (data == null || data.trim().isEmpty) {
      return _buildFallback(context);
    }

    Widget content;

    // Render network URL
    if (data.startsWith('http://') || data.startsWith('https://')) {
      content = Image.network(
        data,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return ShimmerPlaceholder(
            width: widget.width,
            height: widget.height,
            isCircular: widget.isCircular,
            borderRadius: widget.borderRadius,
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    } else {
      // Render Base64 decoded image asynchronously
      content = FutureBuilder<Uint8List?>(
        future: _decodeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerPlaceholder(
              width: widget.width,
              height: widget.height,
              isCircular: widget.isCircular,
              borderRadius: widget.borderRadius,
            );
          }

          final bytes = snapshot.data;
          if (bytes == null || bytes.isEmpty) {
            return _buildFallback(context);
          }

          return Image.memory(
            bytes,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) => _buildFallback(context),
          );
        },
      );
    }

    // Clip output to match the desired layout shape
    if (widget.isCircular) {
      return ClipOval(child: content);
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: content,
      );
    }
  }
}
