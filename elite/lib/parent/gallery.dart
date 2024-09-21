import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse("https://www.instagram.com/vinamrata2911/?hl=en"),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Gallery',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),),
        backgroundColor: Colors.purple,
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
