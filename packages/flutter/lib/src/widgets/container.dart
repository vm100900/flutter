import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart'; // Ensure you have this import for animations
import 'package:flutter/material.dart'; // For using Material design widgets

// DecoratedBox for the glassmorphism background effect
class DecoratedBox extends SingleChildRenderObjectWidget {
  const DecoratedBox({
    super.key,
    required this.decoration,
    this.position = DecorationPosition.background,
    super.child,
  });

  final Decoration decoration;
  final DecorationPosition position;

  @override
  RenderDecoratedBox createRenderObject(BuildContext context) {
    return RenderDecoratedBox(
      decoration: decoration,
      position: position,
      configuration: createLocalImageConfiguration(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderDecoratedBox renderObject) {
    renderObject
      ..decoration = decoration
      ..configuration = createLocalImageConfiguration(context)
      ..position = position;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final String label = switch (position) {
      DecorationPosition.background => 'bg',
      DecorationPosition.foreground => 'fg',
    };
    properties.add(
      EnumProperty<DecorationPosition>('position', position, level: DiagnosticLevel.hidden),
    );
    properties.add(DiagnosticsProperty<Decoration>(label, decoration));
  }
}

// Container with added glassmorphism effect and bobbing animation
class Container extends StatefulWidget {
  final Widget? child;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;
  final bool glassmorphism;
  final bool bob;

  Container({
    super.key,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.child,
    this.clipBehavior = Clip.none,
    this.glassmorphism = true,  // Default to glassmorphism being true
    this.bob = true,            // Default to bobbing effect being true
  }) : constraints =
            (width != null || height != null)
                ? constraints?.tighten(width: width, height: height) ??
                    BoxConstraints.tightFor(width: width, height: height)
                : constraints;

  @override
  _ContainerState createState() => _ContainerState();
}

class _ContainerState extends State<Container> with SingleTickerProviderStateMixin {
  late AnimationController _bobController;
  late Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();

    // If the bob effect is enabled, create an animation
    if (widget.bob) {
      _bobController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
        lowerBound: -10.0,
        upperBound: 10.0,
      )..repeat(reverse: true);

      _bobAnimation = Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(
        parent: _bobController,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    if (widget.bob) {
      _bobController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? current = widget.child;

    if (current == null && (widget.constraints == null || !widget.constraints!.isTight)) {
      current = LimitedBox(
        maxWidth: 0.0,
        maxHeight: 0.0,
        child: ConstrainedBox(constraints: const BoxConstraints.expand()),
      );
    } else if (widget.alignment != null) {
      current = Align(alignment: widget.alignment!, child: current);
    }

    // Apply padding if exists
    final EdgeInsetsGeometry? effectivePadding = widget.padding;
    if (effectivePadding != null) {
      current = Padding(padding: effectivePadding, child: current);
    }

    // Handle glassmorphism effect if enabled
    if (widget.glassmorphism) {
      current = DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1), // Transparent background with some opacity
          borderRadius: BorderRadius.circular(20),
          backdropFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
        ),
        child: current,
      );
    }

    // Apply the bobbing animation if enabled
    if (widget.bob) {
      current = AnimatedBuilder(
        animation: _bobAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bobAnimation.value), // Vertical bobbing effect
            child: child,
          );
        },
        child: current,
      );
    }

    // Handle other UI properties such as color, decoration, etc.
    if (widget.color != null) {
      current = ColoredBox(color: widget.color!, child: current);
    }

    if (widget.clipBehavior != Clip.none) {
      assert(widget.decoration != null);
      current = ClipPath(
        clipper: _DecorationClipper(
          textDirection: Directionality.maybeOf(context),
          decoration: widget.decoration!,
        ),
        clipBehavior: widget.clipBehavior,
        child: current,
      );
    }

    if (widget.decoration != null) {
      current = DecoratedBox(decoration: widget.decoration!, child: current);
    }

    if (widget.foregroundDecoration != null) {
      current = DecoratedBox(
        decoration: widget.foregroundDecoration!,
        position: DecorationPosition.foreground,
        child: current,
      );
    }

    if (widget.constraints != null) {
      current = ConstrainedBox(constraints: widget.constraints!, child: current);
    }

    if (widget.margin != null) {
      current = Padding(padding: widget.margin!, child: current);
    }

    if (widget.transform != null) {
      current = Transform(transform: widget.transform!, alignment: widget.transformAlignment, child: current);
    }

    return current!;
  }
}

class _DecorationClipper extends CustomClipper<Path> {
  _DecorationClipper({TextDirection? textDirection, required this.decoration})
      : textDirection = textDirection ?? TextDirection.ltr;

  final TextDirection textDirection;
  final Decoration decoration;

  @override
  Path getClip(Size size) {
    return decoration.getClipPath(Offset.zero & size, textDirection);
  }

  @override
  bool shouldReclip(_DecorationClipper oldClipper) {
    return oldClipper.decoration != decoration || oldClipper.textDirection != textDirection;
  }
}
