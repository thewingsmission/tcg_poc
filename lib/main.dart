import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PoC Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF090B12),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter PoC Gallery')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose a PoC',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '1. Interactive 3D card with a shiny back\n2. Animated crack mask glow\n3. Holographic rainbow foil frame\n4. Immersive 3D layer card',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CardShowcaseScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('PoC 1: 3D Card'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CrackGlowScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('PoC 2: Crack Glow'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const FoilFrameScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('PoC 3: Foil Frame'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ImmersiveCardScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('PoC 4: Immersive 3D Card'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardShowcaseScreen extends StatefulWidget {
  const CardShowcaseScreen({super.key});

  @override
  State<CardShowcaseScreen> createState() => _CardShowcaseScreenState();
}

class _CardShowcaseScreenState extends State<CardShowcaseScreen>
    with SingleTickerProviderStateMixin {
  static const String _cardAsset = 'image/white tiger card.png';
  static const double _fallbackAspectRatio = 0.7;
  static const double _maxTilt = 0.38;

  late final AnimationController _shineController;
  double _aspectRatio = _fallbackAspectRatio;
  double _rotateX = 0;
  double _rotateY = 0;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _loadAspectRatio();
  }

  Future<void> _loadAspectRatio() async {
    final ByteData data = await rootBundle.load(_cardAsset);
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
      data.buffer.asUint8List(),
    );
    final ui.ImageDescriptor descriptor = await ui.ImageDescriptor.encoded(
      buffer,
    );
    final double aspectRatio = descriptor.width / descriptor.height;

    if (mounted) {
      setState(() {
        _aspectRatio = aspectRatio;
      });
    }
  }

  void _updateTilt(Offset localPosition, Size size) {
    final double dx = ((localPosition.dx / size.width) * 2 - 1).clamp(
      -1.0,
      1.0,
    );
    final double dy = ((localPosition.dy / size.height) * 2 - 1).clamp(
      -1.0,
      1.0,
    );

    setState(() {
      _rotateY = dx * _maxTilt;
      _rotateX = -dy * _maxTilt;
    });
  }

  void _resetTilt() {
    setState(() {
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PoC 1: 3D Card')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double frontWidth = math.min(
              constraints.maxWidth * 0.72,
              320,
            );
            final double frontHeight = frontWidth / _aspectRatio;
            final double backWidth = frontWidth + 34;
            final double backHeight = backWidth / _aspectRatio;
            final Size interactiveSize = Size(backWidth, backHeight);

            return Center(
              child: GestureDetector(
                onPanDown: (details) =>
                    _updateTilt(details.localPosition, interactiveSize),
                onPanUpdate: (details) =>
                    _updateTilt(details.localPosition, interactiveSize),
                onPanEnd: (_) => _resetTilt(),
                onPanCancel: _resetTilt,
                child: AnimatedBuilder(
                  animation: _shineController,
                  builder: (context, child) {
                    final Matrix4 transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.0014)
                      ..rotateX(_rotateX)
                      ..rotateY(_rotateY);

                    return Transform(
                      alignment: Alignment.center,
                      transform: transform,
                      child: child,
                    );
                  },
                  child: _CardScene(
                    frontWidth: frontWidth,
                    frontHeight: frontHeight,
                    backWidth: backWidth,
                    backHeight: backHeight,
                    aspectRatio: _aspectRatio,
                    rotateX: _rotateX,
                    rotateY: _rotateY,
                    shimmerProgress: _shineController.value,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CardScene extends StatelessWidget {
  const _CardScene({
    required this.frontWidth,
    required this.frontHeight,
    required this.backWidth,
    required this.backHeight,
    required this.aspectRatio,
    required this.rotateX,
    required this.rotateY,
    required this.shimmerProgress,
  });

  final double frontWidth;
  final double frontHeight;
  final double backWidth;
  final double backHeight;
  final double aspectRatio;
  final double rotateX;
  final double rotateY;
  final double shimmerProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: backWidth,
      height: backHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(backWidth, backHeight),
            painter: _CardBackPainter(
              shimmerProgress: shimmerProgress,
              rotateX: rotateX,
              rotateY: rotateY,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: frontWidth,
              height: frontHeight,
              child: Image.asset(
                'image/white tiger card.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBackPainter extends CustomPainter {
  const _CardBackPainter({
    required this.shimmerProgress,
    required this.rotateX,
    required this.rotateY,
  });

  final double shimmerProgress;
  final double rotateX;
  final double rotateY;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(28),
    );

    canvas.drawRRect(rrect, Paint()..color = Colors.white);

    canvas.save();
    canvas.clipRRect(rrect);

    final Rect rect = Offset.zero & size;
    final double dxShift = rotateY * size.width * 0.35;
    final double dyShift = rotateX * size.height * 0.35;
    final double sweep = (shimmerProgress * 2 - 1) * size.width;
    final double cycle = shimmerProgress * math.pi * 2;

    final LinearGradient rainbowBase = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [
        Color(0x80FF8FCF),
        Color(0x905EC7FF),
        Color(0x90FFF38A),
        Color(0x8072FFD7),
        Color(0x90D8A8FF),
        Color(0x70FFFFFF),
      ],
      stops: const [0.0, 0.18, 0.38, 0.6, 0.82, 1.0],
      transform: GradientRotation(0.3 + rotateY * 1.15 - rotateX * 0.55),
    );
    canvas.drawRect(
      rect.shift(Offset(dxShift, dyShift)),
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = rainbowBase.createShader(rect.inflate(size.width * 0.22)),
    );

    final SweepGradient foilSweep = SweepGradient(
      colors: const [
        Color(0x00FFFFFF),
        Color(0x90FF8AE2),
        Color(0x906DEBFF),
        Color(0x90FFF59A),
        Color(0x9079FFD8),
        Color(0x90D2A2FF),
        Color(0x00FFFFFF),
      ],
      stops: const [0.0, 0.12, 0.28, 0.46, 0.64, 0.82, 1.0],
      transform: GradientRotation(cycle * 0.35 + rotateY * 0.9),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.overlay
        ..shader = foilSweep.createShader(
          rect
              .inflate(size.width * 0.08)
              .shift(Offset(dxShift * 0.5, dyShift * 0.5)),
        ),
    );

    final Rect shimmerRect = Rect.fromLTWH(
      sweep - size.width * 0.45 + dxShift,
      -size.height * 0.15 + dyShift,
      size.width * 0.5,
      size.height * 1.3,
    );
    final LinearGradient shimmer = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0x00FFFFFF),
        Color(0xA0FFFDE7),
        Color(0xD4FF8AD6),
        Color(0xAA75E7FF),
        Color(0x00FFFFFF),
      ],
      stops: const [0.0, 0.2, 0.45, 0.7, 1.0],
      transform: GradientRotation(-0.55 + rotateY * 0.8),
    );
    canvas.drawRect(
      shimmerRect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = shimmer.createShader(shimmerRect),
    );

    final Rect shimmerRectB = Rect.fromLTWH(
      size.width * 0.28 - sweep * 0.35 - dxShift * 0.5,
      -size.height * 0.1 + dyShift * 0.3,
      size.width * 0.22,
      size.height * 1.2,
    );
    final LinearGradient shimmerB = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0x00FFFFFF),
        Color(0x66A6F3FF),
        Color(0xA0FFF6B7),
        Color(0x00FFFFFF),
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
      transform: GradientRotation(0.4 - rotateY * 0.7),
    );
    canvas.drawRect(
      shimmerRectB,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = shimmerB.createShader(shimmerRectB),
    );

    for (int i = 0; i < 18; i++) {
      final double px =
          ((math.sin(i * 1.73) * 0.5 + 0.5) * size.width) + dxShift * 0.45;
      final double py =
          ((math.cos(i * 2.41) * 0.5 + 0.5) * size.height) + dyShift * 0.45;
      final double blink = (math.sin(cycle * 2.4 + i * 0.85) + 1) / 2;
      final double radius = 2.0 + blink * 7.0;

      final List<Color> sparklePalette = <Color>[
        const Color(0xFFFFE082),
        const Color(0xFF7FDBFF),
        const Color(0xFFFF9ED1),
      ];
      final Color sparkleColor = sparklePalette[i % sparklePalette.length]
          .withValues(alpha: 0.18 + blink * 0.38);
      final Rect sparkleBounds = Rect.fromCircle(
        center: Offset(px, py),
        radius: radius * 2.3,
      );

      canvas.drawCircle(
        Offset(px, py),
        radius,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = ui.Gradient.radial(
            Offset(px, py),
            radius * 2.3,
            <Color>[
              sparkleColor,
              sparkleColor.withValues(alpha: sparkleColor.a * 0.35),
              sparkleColor.withValues(alpha: 0),
            ],
            const <double>[0.0, 0.45, 1.0],
          ),
      );

      canvas.drawRect(
        sparkleBounds,
        Paint()
          ..blendMode = BlendMode.screen
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.12 + blink * 0.18),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const <double>[0.0, 0.5, 1.0],
            transform: GradientRotation(0.85),
          ).createShader(sparkleBounds),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CardBackPainter oldDelegate) {
    return oldDelegate.shimmerProgress != shimmerProgress ||
        oldDelegate.rotateX != rotateX ||
        oldDelegate.rotateY != rotateY;
  }
}

class FoilFrameScreen extends StatefulWidget {
  const FoilFrameScreen({super.key});

  @override
  State<FoilFrameScreen> createState() => _FoilFrameScreenState();
}

class _FoilFrameScreenState extends State<FoilFrameScreen>
    with SingleTickerProviderStateMixin {
  static const String _cardAsset = 'image/white tiger card.png';
  static const double _fallbackAspectRatio = 0.7;
  static const double _maxTilt = 0.38;

  late final AnimationController _shineController;
  double _aspectRatio = _fallbackAspectRatio;
  double _rotateX = 0;
  double _rotateY = 0;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _loadAspectRatio();
  }

  Future<void> _loadAspectRatio() async {
    final ByteData data = await rootBundle.load(_cardAsset);
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
      data.buffer.asUint8List(),
    );
    final ui.ImageDescriptor descriptor = await ui.ImageDescriptor.encoded(
      buffer,
    );
    final double aspectRatio = descriptor.width / descriptor.height;

    if (mounted) {
      setState(() {
        _aspectRatio = aspectRatio;
      });
    }
  }

  void _updateTilt(Offset localPosition, Size size) {
    final double dx = ((localPosition.dx / size.width) * 2 - 1).clamp(
      -1.0,
      1.0,
    );
    final double dy = ((localPosition.dy / size.height) * 2 - 1).clamp(
      -1.0,
      1.0,
    );

    setState(() {
      _rotateY = dx * _maxTilt;
      _rotateX = -dy * _maxTilt;
    });
  }

  void _resetTilt() {
    setState(() {
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PoC 3: Foil Frame')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double frontWidth = math.min(
              constraints.maxWidth * 0.72,
              320,
            );
            final double frontHeight = frontWidth / _aspectRatio;
            final double backWidth = frontWidth + 40;
            final double backHeight = backWidth / _aspectRatio;
            final Size interactiveSize = Size(backWidth, backHeight);

            return Center(
              child: GestureDetector(
                onPanDown: (details) =>
                    _updateTilt(details.localPosition, interactiveSize),
                onPanUpdate: (details) =>
                    _updateTilt(details.localPosition, interactiveSize),
                onPanEnd: (_) => _resetTilt(),
                onPanCancel: _resetTilt,
                child: AnimatedBuilder(
                  animation: _shineController,
                  builder: (context, child) {
                    final Matrix4 transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.0014)
                      ..rotateX(_rotateX)
                      ..rotateY(_rotateY);

                    return Transform(
                      alignment: Alignment.center,
                      transform: transform,
                      child: child,
                    );
                  },
                  child: _FoilCardScene(
                    frontWidth: frontWidth,
                    frontHeight: frontHeight,
                    backWidth: backWidth,
                    backHeight: backHeight,
                    aspectRatio: _aspectRatio,
                    rotateX: _rotateX,
                    rotateY: _rotateY,
                    shimmerProgress: _shineController.value,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FoilCardScene extends StatelessWidget {
  const _FoilCardScene({
    required this.frontWidth,
    required this.frontHeight,
    required this.backWidth,
    required this.backHeight,
    required this.aspectRatio,
    required this.rotateX,
    required this.rotateY,
    required this.shimmerProgress,
  });

  final double frontWidth;
  final double frontHeight;
  final double backWidth;
  final double backHeight;
  final double aspectRatio;
  final double rotateX;
  final double rotateY;
  final double shimmerProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: backWidth,
      height: backHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(backWidth, backHeight),
            painter: _FoilFramePainter(
              shimmerProgress: shimmerProgress,
              rotateX: rotateX,
              rotateY: rotateY,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: frontWidth,
              height: frontHeight,
              child: Image.asset(
                'image/white tiger card.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoilFramePainter extends CustomPainter {
  const _FoilFramePainter({
    required this.shimmerProgress,
    required this.rotateX,
    required this.rotateY,
  });

  final double shimmerProgress;
  final double rotateX;
  final double rotateY;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(28),
    );

    canvas.save();
    canvas.clipRRect(rrect);

    final Rect rect = Offset.zero & size;
    final double cycle = shimmerProgress * math.pi * 2;

    // 1. Holographic Rainbow Base (Sweep Gradient)
    // Creates the vibrant rainbow colors that spin and shift with tilt
    final SweepGradient holoFoil = SweepGradient(
      center: Alignment(rotateY * 1.5, rotateX * 1.5),
      colors: const [
        Color(0xFFFF1493), // Deep Pink
        Color(0xFF00BFFF), // Deep Sky Blue
        Color(0xFFFFD700), // Gold
        Color(0xFF00FA9A), // Medium Spring Green
        Color(0xFF9400D3), // Dark Violet
        Color(0xFFFF1493), // Deep Pink
      ],
      stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      transform: GradientRotation(cycle * 0.5 + rotateY * 2.0),
    );
    canvas.drawRect(rect, Paint()..shader = holoFoil.createShader(rect));

    // 2. Dark Metallic Contrast (Multiply)
    // Adds the dark areas of the foil reflection so the brights pop
    final double glarePos = (rotateY - rotateX) * 2.5;
    final LinearGradient darkBands = LinearGradient(
      begin: Alignment(-2.0 + glarePos, -2.0 + glarePos),
      end: Alignment(2.0 + glarePos, 2.0 + glarePos),
      colors: const [
        Color(0xFFFFFFFF),
        Color(0xFF333333),
        Color(0xFFFFFFFF),
        Color(0xFF333333),
        Color(0xFFFFFFFF),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.multiply
        ..shader = darkBands.createShader(rect),
    );

    // 3. Sharp White Glare (Plus)
    // The main bright reflection that sweeps across the card
    final LinearGradient brightGlare = LinearGradient(
      begin: Alignment(-2.0 + glarePos, -2.0 + glarePos),
      end: Alignment(2.0 + glarePos, 2.0 + glarePos),
      colors: const [
        Color(0x00FFFFFF),
        Color(0x00FFFFFF),
        Color(0x88FFFFFF),
        Color(0xFFFFFFFF),
        Color(0x88FFFFFF),
        Color(0x00FFFFFF),
        Color(0x00FFFFFF),
      ],
      stops: const [0.0, 0.45, 0.48, 0.5, 0.52, 0.55, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = brightGlare.createShader(rect),
    );

    // 4. Secondary Glare (Opposite angle)
    final double glarePos2 = (rotateY + rotateX) * 2.5;
    final LinearGradient brightGlare2 = LinearGradient(
      begin: Alignment(2.0 - glarePos2, -2.0 - glarePos2),
      end: Alignment(-2.0 - glarePos2, 2.0 - glarePos2),
      colors: const [
        Color(0x00FFFFFF),
        Color(0x00FFFFFF),
        Color(0x44FFFFFF),
        Color(0xBBFFFFFF),
        Color(0x44FFFFFF),
        Color(0x00FFFFFF),
        Color(0x00FFFFFF),
      ],
      stops: const [0.0, 0.46, 0.49, 0.5, 0.51, 0.54, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = brightGlare2.createShader(rect),
    );

    // 5. Sparkles
    for (int i = 0; i < 30; i++) {
      // Use pseudo-random positions based on index
      final double px =
          ((math.sin(i * 1.73) * 0.5 + 0.5) * size.width) +
          rotateY * size.width * 1.5;
      final double py =
          ((math.cos(i * 2.41) * 0.5 + 0.5) * size.height) +
          rotateX * size.height * 1.5;

      // Wrap around bounds so they scroll infinitely when tilting
      final double wrappedPx = px % size.width;
      final double wrappedPy = py % size.height;

      final double blink = (math.sin(cycle * 3.0 + i * 1.2) + 1) / 2;
      final double radius = 1.5 + blink * 3.0;

      final Color sparkleColor = Colors.white.withValues(
        alpha: 0.4 + blink * 0.6,
      );

      // Center dot
      canvas.drawCircle(
        Offset(wrappedPx, wrappedPy),
        radius,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = ui.Gradient.radial(Offset(wrappedPx, wrappedPy), radius, [
            sparkleColor,
            sparkleColor.withValues(alpha: 0),
          ]),
      );

      // Horizontal flare
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(wrappedPx, wrappedPy),
          width: radius * 6,
          height: radius * 0.8,
        ),
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = ui.Gradient.radial(
            Offset(wrappedPx, wrappedPy),
            radius * 3,
            [
              Colors.white.withValues(alpha: blink),
              Colors.white.withValues(alpha: 0),
            ],
          ),
      );

      // Vertical flare
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(wrappedPx, wrappedPy),
          width: radius * 0.8,
          height: radius * 6,
        ),
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = ui.Gradient.radial(
            Offset(wrappedPx, wrappedPy),
            radius * 3,
            [
              Colors.white.withValues(alpha: blink),
              Colors.white.withValues(alpha: 0),
            ],
          ),
      );
    }

    // 6. Inner border
    canvas.drawRRect(
      rrect.deflate(1.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FoilFramePainter oldDelegate) {
    return oldDelegate.shimmerProgress != shimmerProgress ||
        oldDelegate.rotateX != rotateX ||
        oldDelegate.rotateY != rotateY;
  }
}

class ImmersiveCardScreen extends StatefulWidget {
  const ImmersiveCardScreen({super.key});

  @override
  State<ImmersiveCardScreen> createState() => _ImmersiveCardScreenState();
}

class _ImmersiveCardScreenState extends State<ImmersiveCardScreen> {
  static const double _aspectRatio = 1080 / 1920;
  static const double _maxTilt = 0.32;

  double _rotateX = 0;
  double _rotateY = 0;
  bool _showCardLayers = false;
  int _selectedFoilDesign = 0;
  bool _isInspectingDesign = false;

  void _updateTilt(Offset localPosition, Size size) {
    final double dx = ((localPosition.dx / size.width) * 2 - 1).clamp(
      -1.0,
      1.0,
    );
    final double dy = ((localPosition.dy / size.height) * 2 - 1).clamp(
      -1.0,
      1.0,
    );

    setState(() {
      _rotateY = dx * _maxTilt;
      _rotateX = -dy * _maxTilt;
    });
  }

  void _updateTiltFromLayoutPosition(
    Offset layoutPosition,
    Offset cardTopLeft,
    Size size,
  ) {
    _updateTilt(layoutPosition - cardTopLeft, size);
  }

  void _resetTilt() {
    setState(() {
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PoC 4: Immersive 3D Card')),
      body: SafeArea(
        child: _isInspectingDesign
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isInspectingDesign = false;
                              _resetTilt();
                            });
                          },
                          child: const Text('Back to designs'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () {
                              setState(() {
                                _showCardLayers = !_showCardLayers;
                              });
                            },
                            child: Text(
                              _showCardLayers
                                  ? 'Hide foreground card images'
                                  : 'Show foreground card images',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double cardWidth = math.min(
                          constraints.maxWidth * 0.76,
                          330,
                        );
                        final double cardHeight = cardWidth / _aspectRatio;
                        final Size cardSize = Size(cardWidth, cardHeight);
                        final Offset cardTopLeft = Offset(
                          (constraints.maxWidth - cardWidth) / 2,
                          (constraints.maxHeight - cardHeight) / 2,
                        );

                        return ClipRect(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanDown: (details) =>
                                _updateTiltFromLayoutPosition(
                                  details.localPosition,
                                  cardTopLeft,
                                  cardSize,
                                ),
                            onPanUpdate: (details) =>
                                _updateTiltFromLayoutPosition(
                                  details.localPosition,
                                  cardTopLeft,
                                  cardSize,
                                ),
                            onPanEnd: (_) => _resetTilt(),
                            onPanCancel: _resetTilt,
                            child: Center(
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.0013)
                                  ..rotateX(_rotateX)
                                  ..rotateY(_rotateY),
                                child: RepaintBoundary(
                                  child: _ImmersiveCardScene(
                                    width: cardWidth,
                                    height: cardHeight,
                                    rotateX: _rotateX,
                                    rotateY: _rotateY,
                                    showCardLayers: _showCardLayers,
                                    foilDesign: _selectedFoilDesign,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose a foil base design',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _FoilDesignGrid(
                      selectedIndex: _selectedFoilDesign,
                      onSelected: (index) {
                        setState(() {
                          _selectedFoilDesign = index;
                          _isInspectingDesign = true;
                          _showCardLayers = false;
                          _resetTilt();
                        });
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ImmersiveCardScene extends StatelessWidget {
  const _ImmersiveCardScene({
    required this.width,
    required this.height,
    required this.rotateX,
    required this.rotateY,
    required this.showCardLayers,
    required this.foilDesign,
  });

  final double width;
  final double height;
  final double rotateX;
  final double rotateY;
  final bool showCardLayers;
  final int foilDesign;

  @override
  Widget build(BuildContext context) {
    final BorderRadius artBorderRadius = BorderRadius.circular(22);
    final Offset backgroundOffset = Offset(rotateY * -10, rotateX * 10);
    final Offset crackOffset = Offset(rotateY * 12, rotateX * -12);
    final Offset tigerOffset = Offset(rotateY * 24, rotateX * -24);
    const double foilBaseInset = 14;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ImmersiveRimPainter(
                  rotateX: rotateX,
                  rotateY: rotateY,
                  foilDesign: foilDesign,
                ),
              ),
            ),
          ),
          if (showCardLayers)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(foilBaseInset),
                child: ClipRRect(
                  borderRadius: artBorderRadius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.translate(
                        offset: backgroundOffset,
                        child: Transform.scale(
                          scale: 1.08,
                          child: Image.asset(
                            'image/white tiger card - background.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      CustomPaint(
                        painter: _ImmersiveAtmospherePainter(
                          rotateX: rotateX,
                          rotateY: rotateY,
                        ),
                      ),
                      Transform.translate(
                        offset: crackOffset,
                        child: Transform.scale(
                          scale: 1.04,
                          child: _FoilLayerImage(
                            asset: 'image/white tiger card - crack.png',
                            opacity: 0.95,
                            rotateX: rotateX,
                            rotateY: rotateY,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: tigerOffset,
                        child: Transform.scale(
                          scale: 1.03,
                          child: Image.asset(
                            'image/white tiger card - tiger.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FoilDesign {
  const _FoilDesign(this.name);

  final String name;
}

const List<_FoilDesign> _foilDesigns = [
  _FoilDesign('Rainbow'),
  _FoilDesign('Blazing Streak'),
  _FoilDesign('Cosmic Starlight'),
  _FoilDesign('Rings'),
  _FoilDesign('Prism Edge (New)'),
  _FoilDesign('Pastel Curtain (New)'),
  _FoilDesign('Blue Starfall (New)'),
];

class _FoilDesignGrid extends StatelessWidget {
  const _FoilDesignGrid({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _foilDesigns.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 10,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final bool selected = index == selectedIndex;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelected(index),
            child: Column(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white.withValues(alpha: 0.22),
                        width: selected ? 3 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomPaint(
                        painter: _FoilThumbnailPainter(foilDesign: index),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _foilDesigns[index].name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FoilThumbnailPainter extends CustomPainter {
  const _FoilThumbnailPainter({required this.foilDesign});

  final int foilDesign;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rounded = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(12),
    );

    canvas.save();
    canvas.clipRRect(rounded);
    _drawBase(canvas, rect);
    _drawSimplePattern(canvas, size);
    canvas.restore();
  }

  void _drawBase(Canvas canvas, Rect rect) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF1744),
            Color(0xFFFFEA00),
            Color(0xFF00E676),
            Color(0xFF00B0FF),
            Color(0xFFD500F9),
          ],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0x00FFFFFF), Color(0x99FFFFFF), Color(0x00FFFFFF)],
        ).createShader(rect),
    );
  }

  void _drawSimplePattern(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..blendMode = BlendMode.screen
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.34);
    final Paint fill = Paint()
      ..blendMode = BlendMode.screen
      ..color = Colors.white.withValues(alpha: 0.2);

    switch (foilDesign) {
      case 0:
        _drawRainbowThumbnailDetails(canvas, size);
      case 1:
        _drawBlazingStreakThumbnail(canvas, size);
      case 2:
        _drawCosmicStarlightThumbnail(canvas, size);
      case 3:
        _drawRainbowCurrentThumbnail(canvas, size);
      case 4:
        _drawReferenceRimThumbnail(canvas, size);
      case 5:
        _drawPastelCurtainThumbnail(canvas, size);
      case 6:
        _drawBlueStarfallThumbnail(canvas, size);
      case 7:
        canvas.drawCircle(
          Offset(size.width * 0.3, size.height * 0.3),
          size.width * 0.18,
          fill..color = Colors.white.withValues(alpha: 0.36),
        );
        canvas.drawLine(
          Offset(size.width * 0.3, size.height * 0.3),
          Offset(size.width, size.height),
          paint..strokeWidth = 4,
        );
      case 8:
        for (double y = 12; y < size.height; y += 14) {
          final Path p = Path()..moveTo(0, y);
          p.quadraticBezierTo(size.width * 0.5, y - 10, size.width, y);
          canvas.drawPath(p, paint);
        }
      case 9:
        for (double y = 12; y < size.height; y += 16) {
          for (double x = 0; x < size.width; x += 16) {
            canvas.drawArc(
              Rect.fromCircle(center: Offset(x, y), radius: 8),
              0,
              math.pi,
              false,
              paint,
            );
          }
        }
      case 10:
        canvas.drawCircle(
          Offset(size.width * 0.35, size.height * 0.35),
          size.width * 0.28,
          fill,
        );
        canvas.drawCircle(
          Offset(size.width * 0.66, size.height * 0.62),
          size.width * 0.22,
          fill,
        );
      case 11:
        final Path p = Path()
          ..moveTo(size.width * 0.55, 0)
          ..lineTo(size.width * 0.38, size.height * 0.38)
          ..lineTo(size.width * 0.58, size.height * 0.38)
          ..lineTo(size.width * 0.35, size.height);
        canvas.drawPath(p, paint..strokeWidth = 3);
      case 12:
        for (int i = 0; i < 9; i++) {
          canvas.drawCircle(
            Offset(
              size.width * ((i % 3) + 0.5) / 3,
              size.height * ((i ~/ 3) + 0.5) / 3,
            ),
            size.width * 0.12,
            fill,
          );
        }
      default:
        break;
    }
  }

  void _drawRainbowThumbnailDetails(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 14; i++) {
      final Offset center = Offset(
        (math.sin(i * 2.4) * 0.5 + 0.5) * size.width,
        (math.cos(i * 1.6) * 0.5 + 0.5) * size.height,
      );
      _drawRadiantFoilStar(canvas, center, 2.2 + (i % 4) * 0.8, 0.42);
    }
  }

  void _drawReferenceRimThumbnail(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A6CFF),
            Color(0xFFFF56BD),
            Color(0xFFFFEC6E),
            Color(0xFF46FFD7),
          ],
        ).createShader(rect),
    );

    final Paint shardPaint = Paint()..blendMode = BlendMode.screen;
    final List<Color> colors = const [
      Color(0xDDFF4EA3),
      Color(0xDD59D8FF),
      Color(0xDDFFE46B),
      Color(0xDD8CFFB5),
    ];
    double left = -size.width * 0.32;
    for (int i = 0; i < 9; i++) {
      final double width = size.width * (0.08 + (i % 5) * 0.032);
      final Path shard = Path()
        ..moveTo(left, size.height)
        ..lineTo(left + width, size.height)
        ..lineTo(left + size.width * (0.48 + (i % 3) * 0.05), 0)
        ..lineTo(left + size.width * (0.48 + (i % 3) * 0.05) - width, 0)
        ..close();
      shardPaint.color = colors[i % colors.length];
      canvas.drawPath(shard, shardPaint);
      left += width + size.width * (0.055 + (i % 4) * 0.022);
    }

    final Paint speckPaint = Paint()
      ..blendMode = BlendMode.screen
      ..color = Colors.white.withValues(alpha: 0.42);
    for (int i = 0; i < 24; i++) {
      final Offset p = Offset(
        (math.sin(i * 2.1) * 0.5 + 0.5) * size.width,
        (math.cos(i * 1.7) * 0.5 + 0.5) * size.height,
      );
      canvas.drawCircle(p, 0.8 + (i % 3) * 0.5, speckPaint);
    }

    final Paint scratchPaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.5);
    for (int i = 0; i < 8; i++) {
      final Offset start = Offset(
        size.width * (0.08 + i * 0.12),
        size.height * (0.18 + (i % 3) * 0.22),
      );
      canvas.drawLine(
        start,
        start + Offset(size.width * 0.18, -size.height * 0.14),
        scratchPaint,
      );
    }
  }

  void _drawVineGlowThumbnail(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            Color(0xFFE5FF48),
            Color(0xFF7DD51C),
            Color(0xFF24D9FF),
            Color(0xFFE66BFF),
          ],
          stops: [0.0, 0.48, 0.78, 1.0],
        ).createShader(rect),
    );

    final Paint ringPaint = Paint()
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final Offset center = Offset(size.width * 0.52, size.height * 0.5);
    for (int i = 0; i < 8; i++) {
      ringPaint.color = [
        Colors.white.withValues(alpha: 0.32),
        const Color(0xFF5EE7FF).withValues(alpha: 0.35),
        const Color(0xFFFF7AE2).withValues(alpha: 0.3),
        const Color(0xFFFFF176).withValues(alpha: 0.36),
      ][i % 4];
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: size.width * (0.42 + i * 0.13),
          height: size.height * (0.3 + i * 0.12),
        ),
        ringPaint,
      );
    }

    final Paint shinePaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.55);
    for (int i = 0; i < 6; i++) {
      final Offset start = Offset(
        size.width * (i / 5),
        size.height * (0.95 - i * 0.16),
      );
      canvas.drawLine(
        start,
        start + Offset(size.width * 0.28, -size.height * 0.34),
        shinePaint,
      );
    }
  }

  void _drawPastelCurtainThumbnail(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFEFA8FF),
            Color(0xFFFFFF5F),
            Color(0xFF8DFBFF),
            Color(0xFFFFB9E8),
            Color(0xFFFFFF69),
            Color(0xFF8EDBFF),
          ],
          stops: [0.0, 0.18, 0.36, 0.55, 0.75, 1.0],
        ).createShader(rect),
    );
    final Paint glowPaint = Paint()
      ..blendMode = BlendMode.screen
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      glowPaint
        ..strokeWidth = 2.2 + (i % 3) * 0.9
        ..color = Colors.white.withValues(alpha: 0.11);
      final double x = size.width * (i + 0.5) / 8;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + math.sin(i) * 8, size.height),
        glowPaint,
      );
    }
  }

  void _drawBlueStarfallThumbnail(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            Color(0xFF40E5FF),
            Color(0xFF0875E8),
            Color(0xFF1E43B8),
            Color(0xFF8B5BFF),
          ],
          stops: [0.0, 0.45, 0.78, 1.0],
        ).createShader(rect),
    );

    final Paint beamPaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round;
    final List<Color> colors = const [
      Color(0xCC5EECFF),
      Color(0xCCFFF176),
      Color(0xCCFF71CF),
      Color(0xCCFFFFFF),
    ];
    for (int i = 0; i < 10; i++) {
      beamPaint
        ..strokeWidth = 2.2 + (i % 3)
        ..color = colors[i % colors.length];
      final Offset start = Offset(
        -size.width * 0.25 + i * size.width * 0.15,
        size.height * (0.95 - (i % 6) * 0.18),
      );
      canvas.drawLine(
        start,
        start + Offset(size.width * 0.5, -size.height * 0.62),
        beamPaint,
      );
    }

    final Paint dustPaint = Paint()..blendMode = BlendMode.plus;
    for (int i = 0; i < 18; i++) {
      final Offset c = Offset(
        (math.sin(i * 2.2) * 0.5 + 0.5) * size.width,
        (math.cos(i * 1.6) * 0.5 + 0.5) * size.height,
      );
      _drawRadiantFoilStar(
        canvas,
        c,
        3.0 + (i % 3) * 1.2,
        0.35 + (i % 4) * 0.08,
      );
      for (int j = 0; j < 5; j++) {
        final double angle = i * 0.9 + j * 1.37;
        final double distance = 2.0 + (j % 4) * 1.6;
        dustPaint.color = Colors.white.withValues(alpha: 0.22 + j * 0.04);
        canvas.drawCircle(
          c + Offset(math.cos(angle), math.sin(angle)) * distance,
          0.35 + (j % 2) * 0.18,
          dustPaint,
        );
      }
    }
  }

  void _drawCosmicStarlightThumbnail(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.1, -0.05),
          radius: 1.0,
          colors: [
            Color(0xFF6F93CD),
            Color(0xFF243E70),
            Color(0xFF101C35),
            Color(0xFF050814),
          ],
          stops: [0.0, 0.38, 0.72, 1.0],
        ).createShader(rect),
    );

    final Paint nebulaPaint = Paint()
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.05),
        radius: 0.55,
        colors: [
          Colors.white.withValues(alpha: 0.26),
          const Color(0xFF8EC5FF).withValues(alpha: 0.18),
          const Color(0x00000000),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, nebulaPaint);

    final Paint dustPaint = Paint()..blendMode = BlendMode.plus;
    for (int i = 0; i < 120; i++) {
      final Offset p = Offset(
        (math.sin(i * 9.31) * 18473.3).abs() % size.width,
        (math.sin(i * 21.17) * 37591.7).abs() % size.height,
      );
      dustPaint.color = Colors.white.withValues(alpha: 0.26 + (i % 4) * 0.08);
      canvas.drawCircle(p, 0.32 + (i % 3) * 0.22, dustPaint);
    }

    final List<Offset> stars = [
      Offset(size.width * 0.45, size.height * 0.25),
      Offset(size.width * 0.62, size.height * 0.36),
      Offset(size.width * 0.28, size.height * 0.48),
      Offset(size.width * 0.78, size.height * 0.62),
    ];
    for (int i = 0; i < stars.length; i++) {
      _drawRadiantFoilStar(canvas, stars[i], 3.2 + i * 0.5, 0.62);
    }
  }

  void _drawRainbowCurrentThumbnail(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFF38F5FF),
            Color(0xFF325DFF),
            Color(0xFFAD48FF),
            Color(0xFFFF6FD8),
            Color(0xFFFFE66D),
          ],
        ).createShader(rect),
    );

    final Paint streakPaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round;
    final List<Color> streakColors = const [
      Color(0xDD7FFFFF),
      Color(0xDDFFF176),
      Color(0xDDFF7AE2),
      Color(0xDDFFFFFF),
    ];
    for (int i = 0; i < 12; i++) {
      streakPaint
        ..strokeWidth = 3 + (i % 4)
        ..color = streakColors[i % streakColors.length];
      final Offset start = Offset(
        -size.width * 0.2 + i * size.width * 0.12,
        size.height * (0.95 - (i % 5) * 0.16),
      );
      canvas.drawLine(
        start,
        start + Offset(size.width * 0.45, -size.height * 0.62),
        streakPaint,
      );
    }

    final Paint arcPaint = Paint()
      ..blendMode = BlendMode.plus
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.58);
    canvas.drawArc(
      Rect.fromLTWH(
        -size.width * 0.2,
        -size.height * 0.04,
        size.width * 0.82,
        size.height * 0.52,
      ),
      0.45,
      3.9,
      false,
      arcPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.46,
        size.height * 0.02,
        size.width * 0.68,
        size.height * 0.48,
      ),
      2.4,
      3.2,
      false,
      arcPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        -size.width * 0.12,
        size.height * 0.54,
        size.width * 1.05,
        size.height * 0.46,
      ),
      3.3,
      2.8,
      false,
      arcPaint,
    );
  }

  void _drawMusicPearlThumbnail(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            Color(0xFFF8FFFF),
            Color(0xFFEFFFF2),
            Color(0xFF69F5FF),
            Color(0xFFFF83DA),
            Color(0xFFFFEC77),
          ],
          stops: [0.0, 0.48, 0.72, 0.88, 1.0],
        ).createShader(rect),
    );

    final Paint trailPaint = Paint()
      ..blendMode = BlendMode.plus
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4
      ..color = Colors.white.withValues(alpha: 0.56);
    for (int i = 0; i < 4; i++) {
      final Path path = Path()
        ..moveTo(-size.width * 0.1, size.height * (0.18 + i * 0.18))
        ..cubicTo(
          size.width * 0.25,
          size.height * (0.02 + i * 0.18),
          size.width * 0.75,
          size.height * (0.34 + i * 0.08),
          size.width * 1.1,
          size.height * (0.1 + i * 0.22),
        );
      canvas.drawPath(path, trailPaint);
    }

    final Paint bubblePaint = Paint()
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.45);
    for (int i = 0; i < 7; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (0.1 + (i % 4) * 0.25),
          size.height * (0.18 + (i ~/ 4) * 0.58 + (i % 2) * 0.13),
        ),
        size.width * (0.045 + (i % 3) * 0.018),
        bubblePaint,
      );
    }

    final Paint notePaint = Paint()
      ..blendMode = BlendMode.plus
      ..color = const Color(0xFFFF86D9).withValues(alpha: 0.8);
    _drawMusicNote(
      canvas,
      Offset(size.width * 0.2, size.height * 0.35),
      size.width * 0.06,
      notePaint,
    );
    _drawMusicNote(
      canvas,
      Offset(size.width * 0.72, size.height * 0.28),
      size.width * 0.055,
      notePaint,
    );
    _drawTrebleClef(
      canvas,
      Offset(size.width * 0.82, size.height * 0.62),
      size.width * 0.08,
      notePaint,
    );
  }

  void _drawBlazingStreakThumbnail(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            Color(0xFFFFF176),
            Color(0xFFFF7A1A),
            Color(0xFFFF4081),
            Color(0xFF24D9FF),
          ],
          stops: [0.0, 0.45, 0.75, 1.0],
        ).createShader(rect),
    );

    final Paint streakPaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round;
    final List<Color> colors = const [
      Color(0xDDFFF176),
      Color(0xCCFF6D00),
      Color(0xCC40C4FF),
      Color(0xCCFF5BC8),
    ];
    for (int i = 0; i < 9; i++) {
      streakPaint
        ..strokeWidth = 3 + (i % 3)
        ..color = colors[i % colors.length];
      final Offset start = Offset(
        -size.width * 0.15 + i * size.width * 0.16,
        size.height * (0.9 - (i % 4) * 0.2),
      );
      canvas.drawLine(
        start,
        start + Offset(size.width * 0.5, -size.height * 0.55),
        streakPaint,
      );
    }
  }

  void _drawMiniHex(Canvas canvas, Offset center, double radius, Paint paint) {
    final Path path = Path();
    for (int i = 0; i < 6; i++) {
      final Offset point =
          center +
          Offset(math.cos(i * math.pi / 3), math.sin(i * math.pi / 3)) * radius;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FoilThumbnailPainter oldDelegate) {
    return oldDelegate.foilDesign != foilDesign;
  }
}

class _FoilLayerImage extends StatelessWidget {
  const _FoilLayerImage({
    required this.asset,
    required this.opacity,
    required this.rotateX,
    required this.rotateY,
  });

  final String asset;
  final double opacity;
  final double rotateX;
  final double rotateY;

  @override
  Widget build(BuildContext context) {
    final double angleResponse = math.sin(rotateY * 10.0 - rotateX * 7.0);
    final double glowStrength =
        math.max(0.0, angleResponse).clamp(0.0, 1.0) * 0.8;
    final double hotSpotStrength = math.pow(glowStrength, 1.8).toDouble();
    final Alignment glowBegin = Alignment(
      -1.1 + rotateY * 3.0,
      -0.9 - rotateX * 2.2,
    );
    final Alignment glowEnd = Alignment(
      1.1 + rotateY * 3.0,
      0.9 - rotateX * 2.2,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: opacity,
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: 7 + glowStrength * 10,
            sigmaY: 7 + glowStrength * 10,
          ),
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            color: const Color(
              0xFFFFC928,
            ).withValues(alpha: glowStrength * 0.62),
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: glowBegin,
              end: glowEnd,
              colors: <Color>[
                const Color(0x00FFFFFF),
                Color(0xFFFFF176).withValues(alpha: 0.08 + glowStrength * 0.32),
                Color(
                  0xFFFFFDE7,
                ).withValues(alpha: 0.16 + hotSpotStrength * 0.72),
                Color(0xFFFFB300).withValues(alpha: glowStrength * 0.34),
                const Color(0x00FFFFFF),
              ],
              stops: const <double>[0.0, 0.34, 0.5, 0.64, 1.0],
            ).createShader(bounds);
          },
          child: Opacity(
            opacity: hotSpotStrength * 0.55,
            child: Image.asset(asset, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}

void _drawRadiantFoilStar(
  Canvas canvas,
  Offset center,
  double radius,
  double alpha,
) {
  final Rect glowRect = Rect.fromCircle(center: center, radius: radius * 3.8);
  final Rect coreRect = Rect.fromCircle(center: center, radius: radius * 0.82);
  canvas.drawCircle(
    center,
    radius * 3.8,
    Paint()
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: alpha * 0.34),
          const Color(0xFFBFDFFF).withValues(alpha: alpha * 0.16),
          const Color(0x00000000),
        ],
        stops: const [0.0, 0.38, 1.0],
      ).createShader(glowRect),
  );

  for (int i = 0; i < 12; i++) {
    final double angle = i * math.pi / 6;
    final double length = radius * (i.isEven ? 3.6 : 1.9);
    final double width = i.isEven ? 1.2 : 0.65;
    final Offset direction = Offset(math.cos(angle), math.sin(angle));
    final Offset start = center - direction * (length * 0.12);
    final Offset end = center + direction * length;
    canvas.drawLine(
      start,
      end,
      Paint()
        ..blendMode = BlendMode.plus
        ..strokeCap = StrokeCap.round
        ..strokeWidth = width
        ..shader = ui.Gradient.linear(
          start,
          end,
          [
            Colors.white.withValues(alpha: alpha * (i.isEven ? 0.58 : 0.34)),
            Colors.white.withValues(alpha: alpha * 0.12),
            const Color(0x00FFFFFF),
          ],
          const [0.0, 0.45, 1.0],
        ),
    );
  }

  canvas.drawCircle(
    center,
    radius * 0.82,
    Paint()
      ..blendMode = BlendMode.plus
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: alpha),
          Colors.white.withValues(alpha: alpha * 0.45),
          const Color(0x00FFFFFF),
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(coreRect),
  );
}

void _drawMusicNote(Canvas canvas, Offset origin, double scale, Paint paint) {
  final Path note = Path()
    ..addOval(
      Rect.fromCenter(center: origin, width: scale * 1.15, height: scale * 0.8),
    )
    ..moveTo(origin.dx + scale * 0.48, origin.dy)
    ..lineTo(origin.dx + scale * 0.48, origin.dy - scale * 2.4)
    ..quadraticBezierTo(
      origin.dx + scale * 1.35,
      origin.dy - scale * 2.1,
      origin.dx + scale * 1.38,
      origin.dy - scale * 1.3,
    )
    ..lineTo(origin.dx + scale * 1.12, origin.dy - scale * 1.3)
    ..quadraticBezierTo(
      origin.dx + scale,
      origin.dy - scale * 1.82,
      origin.dx + scale * 0.48,
      origin.dy - scale * 1.95,
    );
  canvas.drawPath(note, paint);
}

void _drawTrebleClef(Canvas canvas, Offset origin, double scale, Paint paint) {
  final Path clef = Path()
    ..moveTo(origin.dx, origin.dy + scale * 1.7)
    ..cubicTo(
      origin.dx - scale * 0.9,
      origin.dy + scale * 1.2,
      origin.dx - scale * 0.5,
      origin.dy + scale * 0.35,
      origin.dx + scale * 0.08,
      origin.dy + scale * 0.5,
    )
    ..cubicTo(
      origin.dx + scale * 1.1,
      origin.dy + scale * 0.76,
      origin.dx + scale * 0.75,
      origin.dy + scale * 2.0,
      origin.dx - scale * 0.1,
      origin.dy + scale * 1.65,
    )
    ..cubicTo(
      origin.dx - scale * 0.78,
      origin.dy + scale * 1.38,
      origin.dx - scale * 0.42,
      origin.dy + scale * 0.44,
      origin.dx + scale * 0.16,
      origin.dy - scale * 0.3,
    )
    ..cubicTo(
      origin.dx + scale * 0.88,
      origin.dy - scale * 1.22,
      origin.dx + scale * 0.25,
      origin.dy - scale * 2.0,
      origin.dx - scale * 0.2,
      origin.dy - scale * 1.28,
    )
    ..cubicTo(
      origin.dx - scale * 0.55,
      origin.dy - scale * 0.74,
      origin.dx - scale * 0.15,
      origin.dy - scale * 0.15,
      origin.dx + scale * 0.5,
      origin.dy + scale * 0.1,
    );
  canvas.drawPath(
    clef,
    Paint()
      ..blendMode = paint.blendMode
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = scale * 0.26
      ..color = paint.color
      ..maskFilter = paint.maskFilter,
  );
}

class _ImmersiveAtmospherePainter extends CustomPainter {
  const _ImmersiveAtmospherePainter({
    required this.rotateX,
    required this.rotateY,
  });

  final double rotateX;
  final double rotateY;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final RadialGradient footGlow = RadialGradient(
      center: Alignment(0.16 + rotateY * 0.45, 0.74 + rotateX * 0.35),
      radius: 0.55,
      colors: [
        const Color(0xFFFFF8E1).withValues(alpha: 0.56),
        const Color(0xFFFFD54F).withValues(alpha: 0.29),
        const Color(0x00FFD54F),
      ],
      stops: const [0.0, 0.32, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = footGlow.createShader(rect),
    );

    final LinearGradient skyGlare = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        const Color(0x00FFFFFF),
        Colors.white.withValues(alpha: 0.14),
        const Color(0x00FFFFFF),
      ],
      stops: const [0.0, 0.48, 1.0],
      transform: GradientRotation(rotateY * 0.5 - rotateX * 0.35),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = skyGlare.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _ImmersiveAtmospherePainter oldDelegate) {
    return oldDelegate.rotateX != rotateX || oldDelegate.rotateY != rotateY;
  }
}

class _ImmersiveRimPainter extends CustomPainter {
  const _ImmersiveRimPainter({
    required this.rotateX,
    required this.rotateY,
    required this.foilDesign,
  });

  final double rotateX;
  final double rotateY;
  final int foilDesign;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect outer = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(28),
    );
    final Path rimPath = Path()..addRRect(outer);

    final double glare = rotateY * 1.8 - rotateX * 1.1;

    void drawRainbowBase() {
      canvas.drawPath(
        rimPath,
        Paint()
          ..shader = SweepGradient(
            center: Alignment.center,
            colors: const [
              Color(0xFFFF1744),
              Color(0xFFFFEA00),
              Color(0xFF00E676),
              Color(0xFF00B0FF),
              Color(0xFFD500F9),
              Color(0xFFFF1744),
            ],
            stops: const [0.0, 0.18, 0.36, 0.56, 0.78, 1.0],
            transform: GradientRotation(glare),
          ).createShader(rect.inflate(size.width * 0.3)),
      );
    }

    drawRainbowBase();

    switch (foilDesign) {
      case 0:
        _drawRainbowDetails(canvas, size, glare);
      case 1:
        _drawBlazingStreak(canvas, size, glare);
      case 2:
        _drawCosmicStarlight(canvas, size, glare);
      case 3:
        _drawRainbowCurrent(canvas, size, glare);
      case 4:
        _drawPrismEdgeNew(canvas, size, glare);
      case 5:
        _drawPastelCurtainNew(canvas, size, glare);
      case 6:
        _drawBlueStarfallNew(canvas, size, glare);
      case 7:
        _drawComet(canvas, size, glare);
      case 8:
        _drawWaves(canvas, size, glare);
      case 9:
        _drawScales(canvas, size, glare);
      case 10:
        _drawNebula(canvas, size, glare);
      case 11:
        _drawLightning(canvas, size, glare);
      case 12:
        _drawPearl(canvas, size, glare);
      default:
        break;
    }

    if (foilDesign != 5) {
      canvas.drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = LinearGradient(
            begin: Alignment(-1.4 + glare, -1),
            end: Alignment(1.4 + glare, 1),
            colors: const [
              Color(0x00FFFFFF),
              Color(0x00FFFFFF),
              Color(0x66FFFFFF),
              Color(0x00FFFFFF),
              Color(0x00FFFFFF),
              Color(0x99FFFFFF),
              Color(0x00FFFFFF),
              Color(0x00FFFFFF),
              Color(0x66FFFFFF),
              Color(0x00FFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: const [
              0.0,
              0.29,
              0.33,
              0.37,
              0.47,
              0.5,
              0.53,
              0.63,
              0.67,
              0.71,
              1.0,
            ],
          ).createShader(rect),
      );
    }

    final Path maskPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect.inflate(size.width * 0.8)),
      rimPath,
    );
    canvas.drawPath(maskPath, Paint()..color = const Color(0xFF090B12));

    canvas.drawRRect(
      outer.deflate(1.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _ImmersiveRimPainter oldDelegate) {
    return oldDelegate.rotateX != rotateX ||
        oldDelegate.rotateY != rotateY ||
        oldDelegate.foilDesign != foilDesign;
  }

  void _drawRainbowDetails(Canvas canvas, Size size, double glare) {
    final Paint grainPaint = Paint()
      ..blendMode = BlendMode.plus
      ..color = Colors.white.withValues(alpha: 0.22);
    for (int i = 0; i < 90; i++) {
      final Offset point = Offset(
        (math.sin(i * 3.17) * 0.5 + 0.5) * size.width + glare * 15,
        (math.cos(i * 2.03) * 0.5 + 0.5) * size.height,
      );
      canvas.drawCircle(point, 0.45 + (i % 4) * 0.12, grainPaint);
    }

    final Paint starPaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.56);
    final Paint starCenterPaint = Paint()
      ..blendMode = BlendMode.plus
      ..color = Colors.white.withValues(alpha: 0.5);
    for (int i = 0; i < 26; i++) {
      final Offset center = Offset(
        (math.sin(i * 2.41) * 0.5 + 0.5) * size.width + glare * 15,
        (math.cos(i * 1.69) * 0.5 + 0.5) * size.height,
      );
      final double radius = 3 + (i % 5);
      canvas.drawCircle(center, radius * 0.42, starCenterPaint);
      canvas.drawLine(
        center - Offset(radius, 0),
        center + Offset(radius, 0),
        starPaint,
      );
      canvas.drawLine(
        center - Offset(0, radius),
        center + Offset(0, radius),
        starPaint,
      );
      canvas.drawLine(
        center - Offset(radius * 0.55, radius * 0.55),
        center + Offset(radius * 0.55, radius * 0.55),
        starPaint..color = Colors.white.withValues(alpha: 0.34),
      );
    }
  }

  void _drawReferenceRim(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;
    final Rect shaderBounds = rect.inflate(size.width * 0.3);

    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A6CFF),
            Color(0xFFFF56BD),
            Color(0xFFFFF176),
            Color(0xFF46FFD7),
          ],
        ).createShader(shaderBounds),
    );

    final Paint shardPaint = Paint()..blendMode = BlendMode.plus;
    final List<Color> shardColors = const [
      Color(0xDDFF3EA5),
      Color(0xDD78E6FF),
      Color(0xDDFFF176),
      Color(0xDD7DFFB2),
      Color(0xDDB388FF),
    ];
    double left = -size.width * 0.55;
    for (int i = 0; i < 26; i++) {
      final double width = size.width * (0.028 + (i % 7) * 0.014);
      final double bandResponse = math.max(0.0, math.sin(i * 0.73));
      final Path shard = Path()
        ..moveTo(left, size.height * 1.08)
        ..lineTo(left + width, size.height * 1.08)
        ..lineTo(left + size.width * 0.62, -size.height * 0.08)
        ..lineTo(left + size.width * 0.62 - width, -size.height * 0.08)
        ..close();
      shardPaint.shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          shardColors[i % shardColors.length].withValues(alpha: 0.2),
          shardColors[i % shardColors.length],
          Colors.white.withValues(alpha: 0.18 + bandResponse * 0.22),
          shardColors[(i + 1) % shardColors.length].withValues(alpha: 0.55),
        ],
        stops: const [0.0, 0.4, 0.58, 1.0],
      ).createShader(shaderBounds);
      canvas.drawPath(shard, shardPaint);
      shardPaint.shader = null;
      if (bandResponse > 0) {
        canvas.drawPath(
          shard,
          Paint()
            ..blendMode = BlendMode.plus
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
            ..shader = LinearGradient(
              begin: Alignment(-1 + glare, -1),
              end: Alignment(1 + glare, 1),
              colors: [
                const Color(0x00FFFFFF),
                Colors.white.withValues(alpha: 0.68 * bandResponse),
                const Color(0x00FFFFFF),
              ],
            ).createShader(shaderBounds),
        );
      }
      left += width + size.width * (0.025 + (i % 5) * 0.012);
    }

    final Paint darkShardPaint = Paint()
      ..blendMode = BlendMode.screen
      ..color = Colors.white.withValues(alpha: 0.04);
    left = -size.width * 0.24;
    for (int i = 0; i < 16; i++) {
      final double width = size.width * (0.02 + (i % 5) * 0.01);
      final Path shard = Path()
        ..moveTo(left, size.height)
        ..lineTo(left + width, size.height)
        ..lineTo(left + size.width * (0.18 + (i % 4) * 0.02), 0)
        ..lineTo(left + size.width * (0.18 + (i % 4) * 0.02) - width, 0)
        ..close();
      canvas.drawPath(shard, darkShardPaint);
      left += width + size.width * (0.055 + (i % 4) * 0.018);
    }

    final Paint scratchPaint = Paint()
      ..blendMode = BlendMode.screen
      ..strokeWidth = 1.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8)
      ..color = Colors.white.withValues(alpha: 0.38);
    for (int i = 0; i < 72; i++) {
      final Offset start = Offset(
        (math.sin(i * 2.17) * 0.5 + 0.5) * size.width,
        (math.cos(i * 1.43) * 0.5 + 0.5) * size.height,
      );
      final Offset end =
          start +
          Offset(
            size.width * (0.05 + (i % 3) * 0.025),
            -size.height * (0.025 + (i % 4) * 0.012),
          );
      canvas.drawLine(start, end, scratchPaint);
    }

    final Paint edgeGlowPaint = Paint()
      ..blendMode = BlendMode.screen
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [Color(0x00FFFFFF), Color(0x88FFFFFF), Color(0x00FFFFFF)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(shaderBounds);
    canvas.drawRect(rect, edgeGlowPaint);
  }

  void _drawVineGlow(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = const RadialGradient(
          center: Alignment.topLeft,
          radius: 2.5,
          colors: [
            Color(0xFFE9FF4A),
            Color(0xFF92DE1E),
            Color(0xFF2DD4FF),
            Color(0xFFFF62D0),
            Color(0xFF6050A8),
          ],
          stops: [0.0, 0.48, 0.72, 0.9, 1.0],
        ).createShader(rect),
    );

    final Offset center = Offset(
      size.width * 0.52 + glare * 15,
      size.height * 0.5,
    );
    final Paint ringPaint = Paint()
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    final List<Color> ringColors = [
      Colors.white.withValues(alpha: 0.28),
      const Color(0xFF5EE7FF).withValues(alpha: 0.34),
      const Color(0xFFFF7AE2).withValues(alpha: 0.3),
      const Color(0xFFFFF176).withValues(alpha: 0.38),
      const Color(0xFF93FF6A).withValues(alpha: 0.3),
    ];
    for (int i = 0; i < 18; i++) {
      ringPaint
        ..strokeWidth = 9 + (i % 5) * 2.1
        ..color = ringColors[i % ringColors.length];
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: size.width * (0.18 + i * 0.073),
          height: size.height * (0.13 + i * 0.061),
        ),
        ringPaint,
      );
    }

    final Paint prismGlowPaint = Paint()
      ..blendMode = BlendMode.screen
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final Paint prismCorePaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round;
    final List<Color> colors = const [
      Color(0xBBFFFFFF),
      Color(0xAAFFF176),
      Color(0xAA5EE7FF),
      Color(0xAAFF7AE2),
    ];
    for (int i = 0; i < 18; i++) {
      final Offset start = Offset(
        -size.width * 0.12 + i * size.width * 0.075,
        size.height * (0.96 - (i % 8) * 0.13),
      );
      final Offset end = start + Offset(size.width * 0.2, -size.height * 0.34);
      prismGlowPaint
        ..strokeWidth = 6 + (i % 4) * 1.2
        ..color = colors[i % colors.length].withValues(alpha: 0.22);
      canvas.drawLine(start, end, prismGlowPaint);
      prismCorePaint
        ..strokeWidth = 1.1 + (i % 3) * 0.35
        ..shader = ui.Gradient.linear(
          start,
          end,
          [
            colors[i % colors.length].withValues(alpha: 0.05),
            colors[i % colors.length].withValues(alpha: 0.65),
            const Color(0x00FFFFFF),
          ],
          const [0.0, 0.42, 1.0],
        );
      canvas.drawLine(start, end, prismCorePaint);
      prismCorePaint.shader = null;
    }

    for (int i = 0; i < 34; i++) {
      final Offset center = Offset(
        (math.sin(i * 2.3) * 0.5 + 0.5) * size.width,
        (math.cos(i * 1.7) * 0.5 + 0.5) * size.height,
      );
      _drawRadiantFoilStar(canvas, center, 2.5 + (i % 4), 0.45);
    }
  }

  void _drawPastelCurtain(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFA8FF),
            Color(0xFFFFFF6A),
            Color(0xFF9BFFFF),
            Color(0xFFFFB6E8),
            Color(0xFFFFF36D),
            Color(0xFF8BD8FF),
            Color(0xFFD5A4FF),
          ],
          stops: [0.0, 0.14, 0.3, 0.48, 0.66, 0.84, 1.0],
        ).createShader(rect),
    );

    final Paint bandPaint = Paint()
      ..blendMode = BlendMode.screen
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 18; i++) {
      final double x = size.width * (i + 0.5) / 18 + glare * 15;
      bandPaint
        ..strokeWidth = 1.4 + (i % 4) * 0.55
        ..color = [
          Colors.white.withValues(alpha: 0.035),
          const Color(0xFFFFFF8D).withValues(alpha: 0.06),
          const Color(0xFF8DFFFF).withValues(alpha: 0.055),
          const Color(0xFFFF9FE4).withValues(alpha: 0.05),
        ][i % 4];
      canvas.drawLine(Offset(x, -20), Offset(x, size.height + 20), bandPaint);
    }

    final Paint whiteBandPaint = Paint()..blendMode = BlendMode.screen;
    final List<double> bandXs = [-0.15, 0.35, 0.75];
    final List<double> bandWidths = [0.28, 0.32, 0.25];
    final List<List<Color>> bandColors = const [
      [
        Color(0x00FFFFFF),
        Color(0x99FFFFFF),
        Color(0xBBFFF176),
        Color(0x667DFFFF),
        Color(0x00FFFFFF),
      ],
      [
        Color(0x00FFFFFF),
        Color(0x887DFFFF),
        Color(0xEEFFFFFF),
        Color(0x88FF8FDE),
        Color(0x00FFFFFF),
      ],
      [
        Color(0x00FFFFFF),
        Color(0x88FF8FDE),
        Color(0xDDFFFFFF),
        Color(0x88FFF176),
        Color(0x00FFFFFF),
      ],
    ];
    for (int i = 0; i < 3; i++) {
      final double x = size.width * bandXs[i];
      final double bandWidth = size.width * bandWidths[i];
      final Path band = Path()
        ..moveTo(x, size.height * 1.08)
        ..lineTo(x + bandWidth, size.height * 1.08)
        ..lineTo(x + bandWidth + size.width * 0.58, -size.height * 0.08)
        ..lineTo(x + size.width * 0.58, -size.height * 0.08)
        ..close();
      whiteBandPaint.shader = ui.Gradient.linear(
        Offset(x, size.height),
        Offset(x + bandWidth, size.height),
        bandColors[i],
        const [0.0, 0.22, 0.5, 0.78, 1.0],
      );
      canvas.drawPath(band, whiteBandPaint);
    }
    whiteBandPaint.shader = null;

    final Paint texturePaint = Paint()
      ..blendMode = BlendMode.overlay
      ..color = Colors.white.withValues(alpha: 0.12);
    for (int i = 0; i < 180; i++) {
      final Offset point = Offset(
        (math.sin(i * 12.13) * 43758.5453).abs() % size.width,
        (math.sin(i * 51.71) * 19341.37).abs() % size.height,
      );
      canvas.drawCircle(point, 0.35, texturePaint);
    }

    final Paint glarePaint = Paint()
      ..blendMode = BlendMode.plus
      ..shader = LinearGradient(
        begin: Alignment(-1.2 + glare, -1),
        end: Alignment(1.2 + glare, 1),
        colors: const [Color(0x00FFFFFF), Color(0x22FFFFFF), Color(0x00FFFFFF)],
      ).createShader(rect);
    canvas.drawRect(rect, glarePaint);
  }

  void _drawBlueStarfall(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = const RadialGradient(
          center: Alignment.topLeft,
          radius: 2.5,
          colors: [
            Color(0xFF4DF3FF),
            Color(0xFF0B8DF6),
            Color(0xFF1546C7),
            Color(0xFF6F56E8),
            Color(0xFFFF65C7),
          ],
          stops: [0.0, 0.38, 0.68, 0.88, 1.0],
        ).createShader(rect),
    );

    final Paint grainPaint = Paint()
      ..blendMode = BlendMode.plus
      ..color = Colors.white.withValues(alpha: 0.2);
    for (int i = 0; i < 520; i++) {
      final Offset point = Offset(
        (math.sin(i * 14.73) * 53421.13).abs() % size.width,
        (math.sin(i * 63.31) * 24817.77).abs() % size.height,
      );
      canvas.drawCircle(point, 0.28 + (i % 5) * 0.1, grainPaint);
    }

    final Paint beamPaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round;
    final List<Color> beamColors = const [
      Color(0xE65EECFF),
      Color(0xE6FFF176),
      Color(0xD9FF71CF),
      Color(0xD9FFFFFF),
      Color(0xCC5C8DFF),
    ];
    for (int i = 0; i < 28; i++) {
      final double response = 0.5;
      final Offset start = Offset(
        -size.width * 0.28 + i * size.width * 0.058 + glare * 24,
        size.height * (1.02 - (i % 11) * 0.094),
      );
      final Offset direction = Offset(
        size.width * (0.32 + (i % 4) * 0.05),
        -size.height * (0.42 + (i % 3) * 0.07),
      );
      beamPaint
        ..strokeWidth = 1.7 + (i % 5) * 1.25
        ..color = beamColors[i % beamColors.length].withValues(
          alpha: 0.42 + response * 0.5,
        );
      canvas.drawLine(start, start + direction, beamPaint);

      if (response > 0.45) {
        beamPaint
          ..strokeWidth = 0.9
          ..color = Colors.white.withValues(alpha: response * 0.75);
        canvas.drawLine(start, start + direction, beamPaint);
      }
    }

    final Paint dustPaint = Paint()..blendMode = BlendMode.plus;
    for (int i = 0; i < 32; i++) {
      final Offset center = Offset(
        (math.sin(i * 2.71) * 0.5 + 0.5) * size.width + glare * 15,
        (math.cos(i * 1.93) * 0.5 + 0.5) * size.height,
      );
      final double scale = 5.0 + (i % 5) * 1.6;
      final double alpha = 0.45 + math.max(0.0, math.sin(i * 0.44)) * 0.35;
      _drawRadiantFoilStar(canvas, center, scale, alpha);

      for (int j = 0; j < 11; j++) {
        final double angle = i * 0.57 + j * 0.83 + glare * 0.4;
        final double distance = scale * (0.8 + (j % 5) * 0.35);
        dustPaint.color = Colors.white.withValues(alpha: 0.1 + (j % 4) * 0.035);
        canvas.drawCircle(
          center + Offset(math.cos(angle), math.sin(angle)) * distance,
          0.35 + (j % 3) * 0.18,
          dustPaint,
        );
      }
    }

    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = LinearGradient(
          begin: Alignment(-1.2 + glare, -1),
          end: Alignment(1.2 + glare, 1),
          colors: const [
            Color(0x00FFFFFF),
            Color(0x66FFFFFF),
            Color(0x00FFFFFF),
          ],
        ).createShader(rect),
    );
  }

  void _drawCosmicStarlight(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = const RadialGradient(
          center: Alignment.topLeft,
          radius: 2.5,
          colors: [
            Color(0xFF7FA7E8),
            Color(0xFF2C4E89),
            Color(0xFF14284F),
            Color(0xFF070D20),
            Color(0xFF02040D),
          ],
          stops: [0.0, 0.28, 0.58, 0.82, 1.0],
        ).createShader(rect),
    );

    final List<Offset> nebulaCenters = [
      Offset(size.width * 0.42, size.height * 0.34),
      Offset(size.width * 0.24, size.height * 0.55),
      Offset(size.width * 0.68, size.height * 0.22),
    ];
    final List<Color> nebulaColors = const [
      Color(0xFFBBD8FF),
      Color(0xFF6EA8FF),
      Color(0xFFFFE2A4),
    ];
    for (int i = 0; i < nebulaCenters.length; i++) {
      final Rect nebulaRect = Rect.fromCircle(
        center: nebulaCenters[i],
        radius: size.width * (0.22 + i * 0.04),
      );
      canvas.drawCircle(
        nebulaCenters[i],
        size.width * (0.22 + i * 0.04),
        Paint()
          ..blendMode = BlendMode.screen
          ..shader = RadialGradient(
            colors: [
              nebulaColors[i].withValues(alpha: 0.22),
              nebulaColors[i].withValues(alpha: 0.08),
              const Color(0x00000000),
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(nebulaRect),
      );
    }

    final Paint dustPaint = Paint()..blendMode = BlendMode.plus;
    for (int i = 0; i < 720; i++) {
      final Offset p = Offset(
        (math.sin(i * 8.91) * 21347.17).abs() % size.width,
        (math.sin(i * 37.43) * 51491.31).abs() % size.height,
      );
      final double twinkle = 0.55 + math.max(0.0, math.sin(i * 0.37)) * 0.45;
      dustPaint.color = (i % 11 == 0 ? const Color(0xFFFFE9A6) : Colors.white)
          .withValues(alpha: (0.14 + (i % 5) * 0.045) * twinkle);
      canvas.drawCircle(p, 0.35 + (i % 4) * 0.16, dustPaint);
    }

    final List<Offset> starCenters = [
      Offset(size.width * 0.42, size.height * 0.23),
      Offset(size.width * 0.55, size.height * 0.34),
      Offset(size.width * 0.32, size.height * 0.42),
      Offset(size.width * 0.72, size.height * 0.52),
      Offset(size.width * 0.18, size.height * 0.62),
      Offset(size.width * 0.84, size.height * 0.28),
    ];
    for (int i = 0; i < starCenters.length; i++) {
      final double pulse = 0.55 + math.max(0.0, math.sin(i * 0.8)) * 0.38;
      _drawRadiantFoilStar(canvas, starCenters[i], 6.5 + (i % 3) * 2.0, pulse);
      for (int j = 0; j < 18; j++) {
        final double angle = j * 0.71 + i * 1.1;
        final double distance = 10 + (j % 6) * 4.2;
        dustPaint.color = Colors.white.withValues(alpha: 0.1 + (j % 4) * 0.04);
        canvas.drawCircle(
          starCenters[i] + Offset(math.cos(angle), math.sin(angle)) * distance,
          0.4 + (j % 3) * 0.18,
          dustPaint,
        );
      }
    }

    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = LinearGradient(
          begin: Alignment(-1 + glare * 0.5, -1),
          end: Alignment(1 + glare * 0.5, 1),
          colors: const [
            Color(0x00FFFFFF),
            Color(0x2295C7FF),
            Color(0x00FFFFFF),
          ],
        ).createShader(rect),
    );
  }

  void _drawBlazingStreak(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = RadialGradient(
          center: Alignment(0.12 + rotateY * 0.5, 0.08 + rotateX * 0.4),
          radius: 2.5,
          colors: const [
            Color(0xFFFFF6A5),
            Color(0xFFFF8A1C),
            Color(0xFFFF4EA3),
            Color(0xFF3EDCFF),
            Color(0xFF5C5B9E),
          ],
          stops: const [0.0, 0.36, 0.62, 0.84, 1.0],
        ).createShader(rect),
    );

    final Paint streakPaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round;
    final List<Color> streakColors = const [
      Color(0xF0FFF176),
      Color(0xE6FF6D00),
      Color(0xD940C4FF),
      Color(0xD9FF5BC8),
      Color(0xD969FFB8),
    ];
    for (int i = 0; i < 28; i++) {
      final double x = -size.width * 0.22 + i * size.width * 0.052 + glare * 24;
      final double y = size.height * (0.94 - (i % 9) * 0.105);
      final Offset start = Offset(x, y);
      final Offset direction = Offset(
        size.width * (0.34 + (i % 4) * 0.045),
        -size.height * (0.34 + (i % 3) * 0.06),
      );
      for (int segment = 0; segment < 4; segment++) {
        final Offset a = start + direction * (segment / 4);
        final Offset b = start + direction * ((segment + 1) / 4);
        streakPaint
          ..strokeWidth = 3.2 + (i % 4) * 1.2
          ..color = streakColors[(i + segment) % streakColors.length];
        canvas.drawLine(a, b, streakPaint);
      }
      streakPaint
        ..strokeWidth = 1.2 + (i % 3) * 0.4
        ..color = Colors.white.withValues(alpha: 0.35);
      canvas.drawLine(start, start + direction, streakPaint);
    }

    final Paint grainPaint = Paint()
      ..blendMode = BlendMode.plus
      ..color = const Color(0xFFFFF59D).withValues(alpha: 0.28);
    for (int i = 0; i < 320; i++) {
      final Offset point = Offset(
        (math.sin(i * 12.9898) * 43758.5453).abs() % size.width,
        (math.sin(i * 78.233) * 24634.6345).abs() % size.height,
      );
      canvas.drawCircle(point, 0.35 + (i % 5) * 0.12, grainPaint);
    }

    final Paint scratchPaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.44);
    for (int i = 0; i < 76; i++) {
      final Offset start = Offset(
        (math.sin(i * 1.91) * 0.5 + 0.5) * size.width,
        (math.cos(i * 1.31) * 0.5 + 0.5) * size.height,
      );
      canvas.drawLine(
        start,
        start + Offset(size.width * 0.04, -size.height * 0.035),
        scratchPaint,
      );
    }

    final Paint starPaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.58);
    for (int i = 0; i < 22; i++) {
      final Offset center = Offset(
        (math.sin(i * 5.31) * 0.5 + 0.5) * size.width,
        (math.cos(i * 4.17) * 0.5 + 0.5) * size.height,
      );
      final double radius = 3 + (i % 4);
      canvas.drawLine(
        center - Offset(radius, 0),
        center + Offset(radius, 0),
        starPaint,
      );
      canvas.drawLine(
        center - Offset(0, radius),
        center + Offset(0, radius),
        starPaint,
      );
    }
  }

  void _drawStarburst(Canvas canvas, Size size, double glare) {
    final Offset center = Offset(
      size.width * (0.5 + rotateY),
      size.height * (0.45 + rotateX),
    );
    final Paint paint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeWidth = 1.8
      ..color = Colors.white.withValues(alpha: 0.16);
    for (int i = 0; i < 28; i++) {
      final double a = i * math.pi / 14 + glare;
      canvas.drawLine(
        center,
        center + Offset(math.cos(a), math.sin(a)) * size.longestSide,
        paint,
      );
    }
  }

  void _drawClouds(Canvas canvas, Size size, double glare) {
    final Paint paint = Paint()..blendMode = BlendMode.screen;
    for (int i = 0; i < 16; i++) {
      final Offset c = Offset(
        (math.sin(i * 1.7) * 0.5 + 0.5) * size.width + glare * 15,
        (math.cos(i * 1.2) * 0.5 + 0.5) * size.height,
      );
      paint.shader = ui.Gradient.radial(c, size.width * 0.22, [
        Colors.white.withValues(alpha: 0.12),
        Colors.white.withValues(alpha: 0),
      ]);
      canvas.drawCircle(c, size.width * 0.22, paint);
    }
  }

  void _drawDiagonalLines(Canvas canvas, Rect rect, double glare) {
    final Paint paint = Paint()
      ..blendMode = BlendMode.screen
      ..strokeWidth = 2.2
      ..color = Colors.white.withValues(alpha: 0.12);
    for (double x = -rect.height; x < rect.width + rect.height; x += 18) {
      canvas.drawLine(
        Offset(x + glare * 20, rect.height),
        Offset(x + rect.height + glare * 20, 0),
        paint,
      );
    }
  }

  void _drawAurora(Canvas canvas, Rect rect, double glare) {
    final Paint paint = Paint()
      ..blendMode = BlendMode.plus
      ..shader = LinearGradient(
        begin: Alignment(-1 + glare, -1),
        end: Alignment(1 + glare, 1),
        colors: const [
          Color(0x0014FFEC),
          Color(0x8014FFEC),
          Color(0x80F062FF),
          Color(0x00FFFFFF),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawRings(Canvas canvas, Size size, double glare) {
    final Offset c = Offset(size.width * 0.5, size.height * 0.5);
    final Paint paint = Paint()
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.16);
    for (double r = 24; r < size.longestSide; r += 24) {
      canvas.drawCircle(
        c + Offset(rotateY * 30, rotateX * 30),
        r + glare * 5,
        paint,
      );
    }
  }

  void _drawRainbowCurrent(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = LinearGradient(
          begin: Alignment(-0.9 + rotateY * 0.35, 1),
          end: Alignment(0.9 + rotateY * 0.35, -1),
          colors: const [
            Color(0xFF35F7FF),
            Color(0xFF2869FF),
            Color(0xFF8D39FF),
            Color(0xFFFF59CF),
            Color(0xFFFFE86B),
            Color(0xFF54FFF0),
          ],
          stops: [0.0, 0.2, 0.42, 0.62, 0.8, 1.0],
        ).createShader(rect),
    );

    final Paint dustPaint = Paint()..blendMode = BlendMode.plus;
    for (int i = 0; i < 520; i++) {
      final Offset point = Offset(
        (math.sin(i * 12.27) * 32517.3).abs() % size.width,
        (math.sin(i * 39.71) * 21977.9).abs() % size.height,
      );
      dustPaint.color = (i % 9 == 0 ? const Color(0xFFFFE978) : Colors.white)
          .withValues(alpha: 0.12 + (i % 5) * 0.035);
      canvas.drawCircle(point, 0.3 + (i % 4) * 0.16, dustPaint);
    }

    final Paint streakPaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round;
    final List<Color> streakColors = const [
      Color(0xDD75FFFF),
      Color(0xDDFFF176),
      Color(0xDDFF72D2),
      Color(0xDDFFFFFF),
      Color(0xCC46A5FF),
    ];
    for (int i = 0; i < 24; i++) {
      final double response = 0.5;
      final Offset start = Offset(
        -size.width * 0.2 + i * size.width * 0.07 + glare * 18,
        size.height * (1.02 - (i % 9) * 0.115),
      );
      final Offset end =
          start +
          Offset(size.width * 0.4, -size.height * (0.52 + (i % 4) * 0.05));
      streakPaint
        ..strokeWidth = 4 + (i % 5) * 1.6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..color = streakColors[i % streakColors.length].withValues(
          alpha: 0.12 + response * 0.18,
        );
      canvas.drawLine(start, end, streakPaint);
      streakPaint
        ..strokeWidth = 1.1 + (i % 3) * 0.4
        ..maskFilter = null
        ..shader = ui.Gradient.linear(
          start,
          end,
          [
            const Color(0x00FFFFFF),
            streakColors[i % streakColors.length].withValues(alpha: 0.72),
            const Color(0x00FFFFFF),
          ],
          const [0.0, 0.45, 1.0],
        );
      canvas.drawLine(start, end, streakPaint);
      streakPaint.shader = null;
    }

    _drawEnergyArc(
      canvas,
      Rect.fromLTWH(
        -size.width * 0.25,
        -size.height * 0.08,
        size.width * 0.86,
        size.height * 0.54,
      ),
      0.5 + glare * 0.2,
      3.75,
      glare,
    );
    _drawEnergyArc(
      canvas,
      Rect.fromLTWH(
        size.width * 0.48,
        size.height * 0.02,
        size.width * 0.68,
        size.height * 0.5,
      ),
      2.45 + glare * 0.15,
      3.3,
      glare + 0.6,
    );
    _drawEnergyArc(
      canvas,
      Rect.fromLTWH(
        -size.width * 0.14,
        size.height * 0.56,
        size.width * 1.08,
        size.height * 0.46,
      ),
      3.25 - glare * 0.1,
      2.85,
      glare + 1.2,
    );

    final List<Offset> stars = [
      Offset(size.width * 0.18, size.height * 0.2),
      Offset(size.width * 0.82, size.height * 0.48),
      Offset(size.width * 0.24, size.height * 0.82),
      Offset(size.width * 0.58, size.height * 0.72),
    ];
    for (int i = 0; i < stars.length; i++) {
      _drawRadiantFoilStar(canvas, stars[i], 5.5 + (i % 2) * 1.4, 0.48);
    }
  }

  void _drawEnergyArc(
    Canvas canvas,
    Rect oval,
    double startAngle,
    double sweepAngle,
    double glare,
  ) {
    final Paint glowPaint = Paint()
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..shader = SweepGradient(
        transform: GradientRotation(glare),
        colors: const [
          Color(0x0048FFFF),
          Color(0x886EFFFF),
          Color(0xAAFFFFFF),
          Color(0x8848FFFF),
          Color(0x00FFFFFF),
        ],
      ).createShader(oval);
    canvas.drawArc(oval, startAngle, sweepAngle, false, glowPaint);

    final Paint corePaint = Paint()
      ..blendMode = BlendMode.plus
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2
      ..shader = SweepGradient(
        transform: GradientRotation(glare * 1.4),
        colors: const [
          Color(0x00FFFFFF),
          Color(0xCCFFFFFF),
          Color(0xFFBFFFFF),
          Color(0x99FFFFFF),
          Color(0x00FFFFFF),
        ],
      ).createShader(oval);
    canvas.drawArc(oval, startAngle, sweepAngle, false, corePaint);
  }

  void _drawMusicPearl(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 2.5,
          colors: [
            Color(0xFFFAFFFF),
            Color(0xFFF3FFF7),
            Color(0xFFDDF6FF),
            Color(0xFF62E8FF),
            Color(0xFFFF8DDB),
            Color(0xFFFFEC7A),
          ],
          stops: [0.0, 0.38, 0.58, 0.76, 0.9, 1.0],
        ).createShader(rect),
    );

    final Paint pearlPaint = Paint()
      ..blendMode = BlendMode.screen
      ..color = Colors.white.withValues(alpha: 0.14);
    for (int i = 0; i < 120; i++) {
      final Offset c = Offset(
        (math.sin(i * 7.19) * 21547.37).abs() % size.width,
        (math.sin(i * 23.41) * 17491.79).abs() % size.height,
      );
      canvas.drawCircle(c, 3.5 + (i % 5) * 2.2, pearlPaint);
    }

    final Paint dustPaint = Paint()..blendMode = BlendMode.plus;
    for (int i = 0; i < 360; i++) {
      final Offset p = Offset(
        (math.sin(i * 11.27) * 31717.13).abs() % size.width,
        (math.sin(i * 42.73) * 22771.91).abs() % size.height,
      );
      dustPaint.color = (i % 6 == 0 ? const Color(0xFFFFE56F) : Colors.white)
          .withValues(alpha: 0.12 + (i % 4) * 0.04);
      canvas.drawCircle(p, 0.35 + (i % 3) * 0.18, dustPaint);
    }

    final Paint trailGlow = Paint()
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 13
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..color = Colors.white.withValues(alpha: 0.18);
    final Paint trailCore = Paint()
      ..blendMode = BlendMode.plus
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.2;
    for (int i = 0; i < 6; i++) {
      final Path path = Path()
        ..moveTo(-size.width * 0.12, size.height * (0.14 + i * 0.15))
        ..cubicTo(
          size.width * 0.2,
          size.height * (-0.02 + i * 0.17),
          size.width * 0.76,
          size.height * (0.28 + i * 0.1),
          size.width * 1.1,
          size.height * (0.08 + i * 0.18),
        );
      canvas.drawPath(path, trailGlow);
      trailCore.shader = LinearGradient(
        begin: Alignment(-1 + glare * 0.4, -1),
        end: Alignment(1 + glare * 0.4, 1),
        colors: const [
          Color(0x00FFFFFF),
          Color(0xDFFFFFFF),
          Color(0xAAFF8FDE),
          Color(0x00FFFFFF),
        ],
        stops: [0.0, 0.42, 0.62, 1.0],
      ).createShader(rect);
      canvas.drawPath(path, trailCore);
      trailCore.shader = null;
    }

    final Paint bubblePaint = Paint()
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 16; i++) {
      final Offset c = Offset(
        size.width * (0.05 + (i % 5) * 0.22 + math.sin(i) * 0.02),
        size.height * (0.12 + (i ~/ 5) * 0.32 + math.cos(i) * 0.04),
      );
      bubblePaint
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.28);
      canvas.drawCircle(c, size.width * (0.035 + (i % 4) * 0.012), bubblePaint);
      canvas.drawCircle(
        c - Offset(size.width * 0.012, size.width * 0.012),
        size.width * 0.007,
        Paint()
          ..blendMode = BlendMode.plus
          ..color = Colors.white.withValues(alpha: 0.45),
      );
    }

    final Paint notePaint = Paint()
      ..blendMode = BlendMode.plus
      ..color = const Color(0xFFFF8FDE).withValues(alpha: 0.74);
    final Paint noteGlowPaint = Paint()
      ..blendMode = BlendMode.screen
      ..color = const Color(0xFFFF8FDE).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final List<Offset> notes = [
      Offset(size.width * 0.18, size.height * 0.32),
      Offset(size.width * 0.72, size.height * 0.22),
      Offset(size.width * 0.9, size.height * 0.7),
      Offset(size.width * 0.08, size.height * 0.78),
    ];
    for (int i = 0; i < notes.length; i++) {
      _drawMusicNote(
        canvas,
        notes[i],
        size.width * (0.045 + (i % 2) * 0.012),
        noteGlowPaint,
      );
      _drawMusicNote(
        canvas,
        notes[i],
        size.width * (0.045 + (i % 2) * 0.012),
        notePaint,
      );
    }
    _drawTrebleClef(
      canvas,
      Offset(size.width * 0.86, size.height * 0.43),
      size.width * 0.09,
      noteGlowPaint,
    );
    _drawTrebleClef(
      canvas,
      Offset(size.width * 0.86, size.height * 0.43),
      size.width * 0.09,
      notePaint,
    );

    for (int i = 0; i < 18; i++) {
      final Offset c = Offset(
        (math.sin(i * 2.4 + glare) * 0.5 + 0.5) * size.width,
        (math.cos(i * 1.8 - glare) * 0.5 + 0.5) * size.height,
      );
      _drawRadiantFoilStar(canvas, c, 3.6 + (i % 4) * 0.9, 0.42);
    }
  }

  void _drawPrismGrid(Canvas canvas, Size size, double glare) {
    final Paint paint = Paint()
      ..blendMode = BlendMode.overlay
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.18);
    for (double x = 0; x < size.width; x += 18) {
      canvas.drawLine(
        Offset(x + glare * 8, 0),
        Offset(x + glare * 8, size.height),
        paint,
      );
    }
    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(
        Offset(0, y - glare * 8),
        Offset(size.width, y - glare * 8),
        paint,
      );
    }
  }

  void _drawComet(Canvas canvas, Size size, double glare) {
    final Offset c = Offset(
      size.width * (0.2 + rotateY),
      size.height * (0.25 + rotateX),
    );
    canvas.drawCircle(
      c,
      size.width * 0.18,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = ui.Gradient.radial(c, size.width * 0.25, [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0),
        ]),
    );
  }

  void _drawWaves(Canvas canvas, Size size, double glare) {
    final Paint paint = Paint()
      ..blendMode = BlendMode.screen
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.14);
    for (double y = 0; y < size.height; y += 18) {
      final Path path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width; x += 12) {
        path.lineTo(x, y + math.sin(x * 0.05) * 7 + glare * 15);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawScales(Canvas canvas, Size size, double glare) {
    final Paint paint = Paint()
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.14);
    for (double y = 0; y < size.height; y += 18) {
      for (double x = 0; x < size.width; x += 18) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset(x, y), radius: 10),
          0,
          math.pi,
          false,
          paint,
        );
      }
    }
  }

  void _drawNebula(Canvas canvas, Size size, double glare) {
    _drawClouds(canvas, size, glare);
    _drawStarburst(canvas, size, glare * 0.3);
  }

  void _drawLightning(Canvas canvas, Size size, double glare) {
    final Paint paint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.24);
    for (int i = 0; i < 6; i++) {
      final Path p = Path()..moveTo(size.width * (i + 0.5) / 6, 0);
      for (int j = 1; j < 7; j++) {
        p.lineTo(
          size.width * (i + 0.5) / 6 + math.sin(j + i) * 18 + glare * 15,
          size.height * j / 6,
        );
      }
      canvas.drawPath(p, paint);
    }
  }

  void _drawPearl(Canvas canvas, Size size, double glare) {
    final Paint paint = Paint()..blendMode = BlendMode.screen;
    for (int i = 0; i < 30; i++) {
      final Offset c = Offset(
        (i % 5 + 0.5) * size.width / 5,
        (i ~/ 5 + 0.5) * size.height / 6,
      );
      paint.shader = ui.Gradient.radial(c, 16 + glare.abs() * 4, [
        Colors.white.withValues(alpha: 0.16),
        Colors.white.withValues(alpha: 0),
      ]);
      canvas.drawCircle(c, 20, paint);
    }
  }

  void _drawShards(Canvas canvas, Size size, double glare) {
    final Paint paint = Paint()
      ..blendMode = BlendMode.screen
      ..color = Colors.white.withValues(alpha: 0.16);
    for (int i = 0; i < 18; i++) {
      final Offset c = Offset(
        (math.sin(i * 2.0) * 0.5 + 0.5) * size.width,
        (math.cos(i * 1.5) * 0.5 + 0.5) * size.height,
      );
      final Path p = Path()
        ..moveTo(c.dx, c.dy - 18)
        ..lineTo(c.dx + 12 + glare * 4, c.dy)
        ..lineTo(c.dx, c.dy + 18)
        ..lineTo(c.dx - 12 - glare * 4, c.dy)
        ..close();
      canvas.drawPath(p, paint);
    }
  }

  void _drawHex(Canvas canvas, Size size, double glare) {
    final Paint paint = Paint()
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.15);
    for (double y = 0; y < size.height; y += 28) {
      for (double x = 0; x < size.width; x += 24) {
        final Offset c = Offset(x + ((y ~/ 28).isOdd ? 12 : 0), y);
        final Path p = Path();
        for (int i = 0; i < 6; i++) {
          final Offset pt =
              c +
              Offset(math.cos(i * math.pi / 3), math.sin(i * math.pi / 3)) *
                  10 +
              Offset(glare * 5, glare * 5);
          if (i == 0) {
            p.moveTo(pt.dx, pt.dy);
          } else {
            p.lineTo(pt.dx, pt.dy);
          }
        }
        p.close();
        canvas.drawPath(p, paint);
      }
    }
  }

  void _drawSunray(Canvas canvas, Size size, double glare) {
    _drawStarburst(canvas, size, glare + math.pi * 0.25);
  }

  void _drawVortex(Canvas canvas, Size size, double glare) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    final Paint paint = Paint()
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = Colors.white.withValues(alpha: 0.16);
    for (int i = 0; i < 7; i++) {
      final Path p = Path()..moveTo(c.dx, c.dy);
      for (double t = 0; t < math.pi * 3; t += 0.25) {
        final double r = 7 * t + i * 7;
        p.lineTo(c.dx + math.cos(t) * r + glare * 15, c.dy + math.sin(t) * r);
      }
      canvas.drawPath(p, paint);
    }
  }

  void _drawMist(Canvas canvas, Size size, double glare) {
    _drawClouds(canvas, size, glare * 0.4);
    _drawWaves(canvas, size, glare * 0.6);
  }

  void _drawPrismEdgeNew(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = RadialGradient(
          center: Alignment(rotateY * 0.5, rotateX * 0.5),
          radius: 2.5,
          colors: const [
            Color(0xFF4A6CFF),
            Color(0xFFFF56BD),
            Color(0xFFFFF176),
            Color(0xFF46FFD7),
            Color(0xFF4A6CFF),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(rect),
    );

    final Paint shardPaint = Paint()..blendMode = BlendMode.plus;
    final List<Color> shardColors = const [
      Color(0xDDFF3EA5),
      Color(0xDD78E6FF),
      Color(0xDDFFF176),
      Color(0xDD7DFFB2),
      Color(0xDDB388FF),
    ];
    double left = -size.width * 0.55;
    for (int i = 0; i < 26; i++) {
      final double width = size.width * (0.028 + (i % 7) * 0.014);
      final double bandResponse = math.max(0.0, math.sin(i * 0.73));
      final Path shard = Path()
        ..moveTo(left, size.height * 1.08)
        ..lineTo(left + width, size.height * 1.08)
        ..lineTo(left + size.width * 0.62, -size.height * 0.08)
        ..lineTo(left + size.width * 0.62 - width, -size.height * 0.08)
        ..close();
      shardPaint.shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          shardColors[i % shardColors.length].withValues(alpha: 0.2),
          shardColors[i % shardColors.length],
          Colors.white.withValues(alpha: 0.18 + bandResponse * 0.22),
          shardColors[(i + 1) % shardColors.length].withValues(alpha: 0.55),
        ],
        stops: const [0.0, 0.4, 0.58, 1.0],
      ).createShader(rect);
      canvas.drawPath(shard, shardPaint);
      shardPaint.shader = null;
      if (bandResponse > 0) {
        canvas.drawPath(
          shard,
          Paint()
            ..blendMode = BlendMode.plus
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
            ..shader = LinearGradient(
              begin: Alignment(-1 + glare, -1),
              end: Alignment(1 + glare, 1),
              colors: [
                const Color(0x00FFFFFF),
                Colors.white.withValues(alpha: 0.68 * bandResponse),
                const Color(0x00FFFFFF),
              ],
            ).createShader(rect),
        );
      }
      left += width + size.width * (0.025 + (i % 5) * 0.012);
    }
  }

  void _drawVineGlowNew(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = RadialGradient(
          center: Alignment(rotateY * 0.3, rotateX * 0.3),
          radius: 2.5,
          colors: const [
            Color(0xFFE9FF4A),
            Color(0xFF92DE1E),
            Color(0xFF2DD4FF),
            Color(0xFFFF62D0),
            Color(0xFF6050A8),
          ],
          stops: const [0.0, 0.48, 0.72, 0.9, 1.0],
        ).createShader(rect),
    );
    final Offset center = Offset(size.width * 0.52, size.height * 0.5);
    final Paint ringPaint = Paint()
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke;
    final List<Color> ringColors = [
      Colors.white.withValues(alpha: 0.28),
      const Color(0xFF5EE7FF).withValues(alpha: 0.34),
      const Color(0xFFFF7AE2).withValues(alpha: 0.3),
      const Color(0xFFFFF176).withValues(alpha: 0.38),
      const Color(0xFF93FF6A).withValues(alpha: 0.3),
    ];
    for (int i = 0; i < 18; i++) {
      ringPaint
        ..strokeWidth = 4.0 + (i % 5) * 1.5
        ..color = ringColors[i % ringColors.length];
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: size.width * (0.18 + i * 0.073),
          height: size.height * (0.13 + i * 0.061),
        ),
        ringPaint,
      );
    }
  }

  void _drawPastelCurtainNew(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = RadialGradient(
          center: Alignment(rotateY * 0.4, rotateX * 0.4),
          radius: 2.5,
          colors: const [
            Color(0xFFEFA8FF),
            Color(0xFFFFFF6A),
            Color(0xFF9BFFFF),
            Color(0xFFFFB6E8),
            Color(0xFFFFF36D),
            Color(0xFF8BD8FF),
            Color(0xFFD5A4FF),
          ],
          stops: const [0.0, 0.14, 0.3, 0.48, 0.66, 0.84, 1.0],
        ).createShader(rect),
    );
    final Paint whiteBandPaint = Paint()..blendMode = BlendMode.screen;
    final List<double> bandXs = [-0.15, 0.35, 0.75];
    final List<double> bandWidths = [0.28, 0.32, 0.25];
    for (int i = 0; i < 3; i++) {
      final double x = size.width * bandXs[i];
      final double bandWidth = size.width * bandWidths[i];
      final Path band = Path()
        ..moveTo(x, size.height * 1.08)
        ..lineTo(x + bandWidth, size.height * 1.08)
        ..lineTo(x + bandWidth + size.width * 0.58, -size.height * 0.08)
        ..lineTo(x + size.width * 0.58, -size.height * 0.08)
        ..close();
      whiteBandPaint.color = Colors.white.withValues(alpha: 0.6);
      canvas.drawPath(band, whiteBandPaint);
    }
  }

  void _drawBlueStarfallNew(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = RadialGradient(
          center: Alignment(0.08 + rotateY * 0.4, -0.05 + rotateX * 0.4),
          radius: 2.5,
          colors: const [
            Color(0xFF4DF3FF),
            Color(0xFF0B8DF6),
            Color(0xFF1546C7),
            Color(0xFF6F56E8),
            Color(0xFFFF65C7),
          ],
          stops: const [0.0, 0.38, 0.68, 0.88, 1.0],
        ).createShader(rect),
    );
    final Paint beamPaint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round;
    final List<Color> beamColors = const [
      Color(0xE65EECFF),
      Color(0xE6FFF176),
      Color(0xD9FF71CF),
      Color(0xD9FFFFFF),
      Color(0xCC5C8DFF),
    ];
    for (int i = 0; i < 28; i++) {
      final double response = 0.5;
      final Offset start = Offset(
        -size.width * 0.28 + i * size.width * 0.058,
        size.height * (1.05 - (i % 7) * 0.12),
      );
      final Offset direction = Offset(
        size.width * (0.22 + (i % 3) * 0.05),
        -size.height * (0.4 + (i % 4) * 0.08),
      );
      beamPaint
        ..strokeWidth = 1.8 + (i % 5) * 0.8
        ..color = beamColors[i % beamColors.length].withValues(
          alpha: 0.18 + response * 0.2,
        );
      canvas.drawLine(start, start + direction, beamPaint);
    }
  }

  void _drawMusicPearlNew(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = RadialGradient(
          center: Alignment(rotateY * 0.2, rotateX * 0.2),
          radius: 2.5,
          colors: const [
            Color(0xFFFAFFFF),
            Color(0xFFF3FFF7),
            Color(0xFFDDF6FF),
            Color(0xFF62E8FF),
            Color(0xFFFF8DDB),
            Color(0xFFFFEC7A),
          ],
          stops: const [0.0, 0.38, 0.58, 0.76, 0.9, 1.0],
        ).createShader(rect),
    );
    final Paint pearlPaint = Paint()
      ..blendMode = BlendMode.overlay
      ..color = Colors.white.withValues(alpha: 0.6);
    for (int i = 0; i < 24; i++) {
      final double x = (math.sin(i * 12.3) * 0.5 + 0.5) * size.width;
      final double y = (math.cos(i * 8.9) * 0.5 + 0.5) * size.height;
      final double r = 12.0 + (i % 6) * 4.0;
      canvas.drawCircle(Offset(x, y), r, pearlPaint);
    }
  }

  void _drawVineGlowFixed(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = RadialGradient(
          center: Alignment(rotateY * 0.3, rotateX * 0.3),
          radius: 2.5,
          colors: const [
            Color(0xFFE9FF4A),
            Color(0xFF92DE1E),
            Color(0xFF2DD4FF),
            Color(0xFFFF62D0),
            Color(0xFF6050A8),
          ],
          stops: const [0.0, 0.48, 0.72, 0.9, 1.0],
        ).createShader(rect.inflate(size.width * 0.3)),
    );
    final Offset center = Offset(size.width * 0.52, size.height * 0.5);
    final Paint ringPaint = Paint()
      ..blendMode = BlendMode.screen
      ..style = PaintingStyle.stroke;
    final List<Color> ringColors = [
      Colors.white.withValues(alpha: 0.28),
      const Color(0xFF5EE7FF).withValues(alpha: 0.34),
      const Color(0xFFFF7AE2).withValues(alpha: 0.3),
      const Color(0xFFFFF176).withValues(alpha: 0.38),
      const Color(0xFF93FF6A).withValues(alpha: 0.3),
    ];
    for (int i = 0; i < 28; i++) {
      ringPaint
        ..strokeWidth = 4.0 + (i % 5) * 1.5
        ..color = ringColors[i % ringColors.length];
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(glare * 20, rotateX * 12),
          width: size.width * (0.18 + i * 0.1),
          height: size.height * (0.13 + i * 0.09),
        ),
        ringPaint,
      );
    }
  }

  void _drawMusicPearlFixed(Canvas canvas, Size size, double glare) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = RadialGradient(
          center: Alignment(rotateY * 0.2, rotateX * 0.2),
          radius: 2.5,
          colors: const [
            Color(0xFFFAFFFF),
            Color(0xFFF3FFF7),
            Color(0xFFDDF6FF),
            Color(0xFF62E8FF),
            Color(0xFFFF8DDB),
            Color(0xFFFFEC7A),
          ],
          stops: const [0.0, 0.38, 0.58, 0.76, 0.9, 1.0],
        ).createShader(rect.inflate(size.width * 0.3)),
    );
    final Paint pearlPaint = Paint()
      ..blendMode = BlendMode.overlay
      ..color = Colors.white.withValues(alpha: 0.6);
    for (int i = 0; i < 36; i++) {
      final double x =
          (math.sin(i * 12.3) * 0.9 + 0.5) * size.width + glare * 24;
      final double y =
          (math.cos(i * 8.9) * 0.9 + 0.5) * size.height + rotateX * 12;
      final double r = 12.0 + (i % 6) * 4.0;
      canvas.drawCircle(Offset(x, y), r, pearlPaint);
    }
  }
}

class CrackGlowScreen extends StatefulWidget {
  const CrackGlowScreen({super.key});

  @override
  State<CrackGlowScreen> createState() => _CrackGlowScreenState();
}

class _CrackGlowScreenState extends State<CrackGlowScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowOpacity = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color baseYellow = Color(0xFFFFD54F);
    const Color sharpYellow = Color(0xFFFFEA00);

    return Scaffold(
      appBar: AppBar(title: const Text('PoC 2: Crack Glow')),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double size = math.min(constraints.maxWidth, 420);

                return SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _TintedMask(
                        color: baseYellow.withValues(alpha: 0.75),
                        glowBlur: 0,
                        size: size,
                      ),
                      AnimatedBuilder(
                        animation: _glowOpacity,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _glowOpacity.value,
                            child: child,
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _TintedMask(
                              color: sharpYellow.withValues(alpha: 0.95),
                              glowBlur: 22,
                              size: size,
                            ),
                            _TintedMask(
                              color: sharpYellow,
                              glowBlur: 0,
                              size: size,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TintedMask extends StatelessWidget {
  const _TintedMask({
    required this.color,
    required this.glowBlur,
    required this.size,
  });

  final Color color;
  final double glowBlur;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget child = Image.asset(
      'image/mask.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.high,
    );

    if (glowBlur > 0) {
      child = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: glowBlur, sigmaY: glowBlur),
        child: child,
      );
    }

    return child;
  }
}
