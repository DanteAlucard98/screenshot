import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter ScreenShoot',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Flutter ScreenShoot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = ScreenshotController();
  @override
  Widget build(BuildContext context) => Screenshot(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: Column(
          children: [
            buildImage(),
            const SizedBox(
              height: 32,
            ),
            //Se tiene de dos formas capturamos solo el widget o tomas literal un screenshot de la pantalla
            FloatingActionButton(
              onPressed: () async {
                //boton de arriba se toma una captura completa de la pantalla
                final image = await controller.capture();
                if (image == null) return;

                await saveImage(image);
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.screenshot),
            ),
            const SizedBox(
              height: 16,
            ),
            FloatingActionButton(
                //boton de abajo se toma una captura del widget
                onPressed: () async {
                  final image =
                      await controller.captureFromWidget(buildImage());
                  saveAndShare(image);
                },
                backgroundColor: Colors.pink,
                child: const Icon(Icons.screenshot_rounded))
          ],
        ),
      ));

//Guardar y compartir la imagen
  Future saveAndShare(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flutter.png');
    image.writeAsBytesSync(bytes);
    final text = 'Shared from Danielito Panzon';
    await Share.shareFiles([image.path], text: text);
  }

//Se guarda la imagen en el dispositivo
  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'Screenshot_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    return result['filePath'];
  }

//Se tiene la imagen de prueba pero podemos poner nosotros la parte del arcore
  Widget buildImage() => Stack(children: [
        AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              'https://images.unsplash.com/photo-1652487952625-4a328398cd46?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=764&q=80',
              fit: BoxFit.cover,
            )),
        Positioned(
            bottom: 10,
            right: 170,
            left: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                color: Colors.transparent,
                child: Text(
                  '4awish Studio',
                  style: TextStyle(color: Colors.green, fontSize: 23),
                ),
              ),
            ))
      ]);
}
