import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:tuberculose_detector/consts.dart';
import 'package:tuberculose_detector/image_classification.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ImageClassification _imageClassification;
  @override
  void initState() {
    _imageClassification = ImageClassification();
    super.initState();
  }

  Category? resultOfClassification;
  String? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)!.appName),
          centerTitle: true,
        ),
        body: _body());
  }

  Future<String?> pickImage(ImageSource imageSource) async =>
      await ImagePicker()
          .pickImage(source: imageSource)
          .then((value) => value?.path);
  Widget _selectPickerImageFormButton(String text, ImageSource imageSource) =>
      ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              fixedSize: Size(MediaQuery.of(context).size.height * 80,
                  MediaQuery.of(context).size.height * .07)),
          onPressed: () async {
            final imagePicked = await pickImage(imageSource);
            if (imagePicked == null) return;
            final resultProcessed = await _imageClassification.classify(
                img.decodeImage(File(imagePicked).readAsBytesSync())!);
            setState(() {
              image = imagePicked;
              resultOfClassification = resultProcessed;
            });
          },
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ));

  Widget _imageWidget() => ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image(
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height * 0.50,
          image: image == null
              ? (const AssetImage(assetsPnoumoniaConst)) as ImageProvider
              : FileImage(
                  File(image!),
                ),
        ),
      );

  Widget _resultWidget(String title, String subgtitle) => Text.rich(
        TextSpan(
          text: title,
          style: const TextStyle(fontSize: 20),
          children: [
            TextSpan(
              text: subgtitle,
              style: const TextStyle(color: Colors.amber, fontSize: 16),
            )
          ],
        ),
      );

  Widget _body() => Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageWidget(),
              const SizedBox(height: 10),
              resultOfClassification == null
                  ? Container()
                  : Column(
                      children: [
                        const SizedBox(height: 20),
                        _resultWidget(AppLocalizations.of(context)!.rayoxresult,
                            resultOfClassification!.label),
                        _resultWidget(AppLocalizations.of(context)!.probability,
                            resultOfClassification!.score.toString()),
                        const SizedBox(height: 20),
                      ],
                    ),
              _selectPickerImageFormButton(
                  AppLocalizations.of(context)!.selectioOnGallery,
                  ImageSource.gallery),
              const SizedBox(height: 10),
              _selectPickerImageFormButton(
                  AppLocalizations.of(context)!.captureByCamera,
                  ImageSource.camera)
            ],
          ),
        ),
      );
}
