import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:set_in_hand/helpers/helper.dart';
import 'package:set_in_hand/widgets/empty_widget.dart';

List<CameraDescription> cameras = [];

class CameraPreviewScreen extends StatefulWidget {
  const CameraPreviewScreen({Key? key}) : super(key: key);

  @override
  CameraPreviewScreenState createState() => CameraPreviewScreenState();
}

class CameraPreviewScreenState extends State<CameraPreviewScreen> {
  CameraController? controller;
  Helper get hp => Helper.of(context);

  @override
  void initState() {
    super.initState();
    setcontroller();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (controller?.value.isInitialized ?? false)
        ? Stack(alignment: Alignment.bottomCenter, children: <Widget>[
            AspectRatio(
                aspectRatio: controller?.value.aspectRatio ?? hp.aspectRatio,
                child: CameraPreview(controller!)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                // color: Colors.red,
                onPressed: () {},
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ])
        : const EmptyWidget();
  }

  void setcontroller() async {
    try {
      cameras = await availableCameras();
      if (mounted) {
        setState(() {
          controller = CameraController(cameras.first, ResolutionPreset.high);
        });
      }
      await controller?.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      sendAppLog(e);
    }
  }
}
