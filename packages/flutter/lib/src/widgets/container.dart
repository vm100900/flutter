import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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

class Container extends StatelessWidget {
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
  })  : assert(margin == null || margin.isNonNegative),
        assert(padding == null || padding.isNonNegative),
        assert(decoration == null || decoration.debugAssertIsValid()),
        assert(constraints == null || constraints.debugAssertIsValid()),
        constraints =
            (width != null || height != null)
                ? constraints?.tighten(width: width, height: height) ??
                    BoxConstraints.tightFor(width: width, height: height)
                : constraints;

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

  @override
  Widget build(BuildContext context) {
    Widget? current = child;

    if (child == null) {
      return ContainerWithImage(context: context);
    }

    return ContainerWithImage(context: context);
  }
}

class ContainerWithImage extends StatelessWidget {
  const ContainerWithImage({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final imageProvider = AssetImage('assets/your_image.png');

    return CustomPaint(
      painter: ContainerPainter(imageProvider),
      child: Container(
        padding: EdgeInsets.all(20.0),
        alignment: Alignment.center,
        child: Text('Image Container with Canvas Paint'),
      ),
    );
  }
}

class ContainerPainter extends CustomPainter {
  final ImageProvider imageProvider;

  ContainerPainter(this.imageProvider);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.blue;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
    final ImageListener listener = (ImageInfo info, bool sync) {
      canvas.drawImage(info.image, Offset(50, 50), paint);
    };
    stream.addListener(listener);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
