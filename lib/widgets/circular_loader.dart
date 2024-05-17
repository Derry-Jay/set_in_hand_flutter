import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:set_in_hand/helpers/helper.dart';

class CircularLoader extends StatefulWidget {
  final Color color;
  final Duration duration;
  final LoaderType? loaderType;
  final double? heightFactor, widthFactor, sizeFactor;

  const CircularLoader(
      {Key? key,
      this.sizeFactor,
      this.loaderType,
      this.widthFactor,
      this.heightFactor,
      required this.color,
      required this.duration})
      : super(key: key);

  @override
  CircularLoaderState createState() => CircularLoaderState();
}

class CircularLoaderState extends State<CircularLoader>
    with SingleTickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? animationController;
  Helper get hp => Helper.of(context);
  double get length =>
      hp.radius / (widget.sizeFactor ?? (hp.factor * 8.388608));
  // Timer? tm;

  void refreshIfMounted() {
    if (mounted) setState(() {});
  }

  void moveForwardIfMounted() async {
    if (mounted && animationController != null) {
      await animationController!.forward();
    }
  }

  void getData() {
    animationController =
        AnimationController(duration: widget.duration, vsync: this);
    CurvedAnimation curve =
        CurvedAnimation(parent: animationController!, curve: Curves.easeOut);
    animation = Tween<double>(
            begin: hp.height / (widget.heightFactor ?? hp.factor), end: 0)
        .animate(curve)
      ..drive(AlignmentGeometryTween())
      ..addListener(refreshIfMounted)
      ..addStatusListener(listenAnimationStatus);
  }

  void listenAnimationStatus(AnimationStatus status) {
    if ((status == AnimationStatus.dismissed ||
            status == AnimationStatus.completed) &&
        mounted) {
      dispose();
    }
  }

  void assignState() async {
    await Future.delayed(Duration.zero, getData);
  }

  @override
  Widget build(BuildContext context) {
    final opacity = animation == null
        ? 1.0
        : (animation!.value > 100.0 ? 1.0 : animation!.value / 100);
    Widget lc;
    switch (widget.loaderType) {
      case LoaderType.chasingDots:
        lc = SpinKitChasingDots(
            color: widget.color, duration: widget.duration, size: length);
        break;
      case LoaderType.circle:
        lc = SpinKitCircle(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.ring:
        lc = SpinKitRing(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.cubeGrid:
        lc = SpinKitCubeGrid(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.dancingSquare:
        lc = SpinKitDancingSquare(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.doubleBounce:
        lc = SpinKitDoubleBounce(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.dualRing:
        lc = SpinKitDualRing(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.fadingCircle:
        lc = SpinKitFadingCircle(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.fadingCube:
        lc = SpinKitFadingCube(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.fadingFour:
        lc = SpinKitFadingFour(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.fadingGrid:
        lc = SpinKitFadingGrid(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.foldingCube:
        lc = SpinKitFoldingCube(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.hourGlass:
        lc = SpinKitHourGlass(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.pouringHourGlass:
        lc = SpinKitPouringHourGlass(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.pouringHourGlassRefined:
        lc = SpinKitPouringHourGlassRefined(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.pulse:
        lc = SpinKitPulse(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.pumpingHeart:
        lc = SpinKitPumpingHeart(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.ripple:
        lc = SpinKitRipple(
            color: widget.color, duration: widget.duration, size: length);
        break;
      case LoaderType.rotatingCircle:
        lc = SpinKitRotatingCircle(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.rotatingPlain:
        lc = SpinKitRotatingPlain(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.spinningCircle:
        lc = SpinKitSpinningCircle(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.spinningLines:
        lc = SpinKitSpinningLines(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.squareCircle:
        lc = SpinKitSquareCircle(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.threeBounce:
        lc = SpinKitThreeBounce(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.wanderingCubes:
        lc = SpinKitWanderingCubes(
            color: widget.color, duration: widget.duration, size: length);
        break;
      case LoaderType.wave:
        lc = SpinKitWave(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.normal:
      default:
        lc = CircularProgressIndicator(color: widget.color);
        break;
    }
    return AnimatedOpacity(
        opacity: opacity,
        duration: widget.duration,
        child: Center(
            heightFactor: widget.heightFactor,
            widthFactor: widget.widthFactor,
            child: lc));
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    moveForwardIfMounted();
  }

  @override
  void initState() {
    super.initState();
    assignState();
  }

  @override
  void dispose() {
    log(animationController);
    if (animationController != null && mounted) {
      animationController!.dispose();
    }
    // if (tm != null) tm!.cancel();
    log(animation);
    if (animation != null && mounted) {
      animation!.removeListener(refreshIfMounted);
      animation!.removeStatusListener(listenAnimationStatus);
    }
    super.dispose();
  }
}
