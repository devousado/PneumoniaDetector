import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:tuberculose_detector/classifier_model.dart';
import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';
import 'package:tuberculose_detector/consts.dart';

class ImageClassification {
  ImageClassification() {
    runLabel();
    runModel();
  }

  Future<Category> classify(img.Image image) async {
    final proccessedImage = await processImage(image);
    final model = await runModel();
    TensorBuffer tensorBuffer =
        TensorBuffer.createFixedSize(model.outputShape, model.outputType);
    model.interpreter.run(proccessedImage.buffer, tensorBuffer.buffer);
    final labelResult = await probabilityResult(tensorBuffer);
    return labelResult;
  }

  Future<List<String>> runLabel() async {
    final rowlabel = await FileUtil.loadLabels(assetsLabelConst);
    final labels =
        rowlabel.map((e) => e.substring(e.indexOf(' ')).trim()).toList();

    return labels;
  }

  Future<ClassifierModel> runModel() async {
    final interPreter = await Interpreter.fromAsset(assetsModelConst,
        options: InterpreterOptions()..threads = 4);
    final inputShape = interPreter.getInputTensor(0).shape;
    final outPutShape = interPreter.getOutputTensor(0).shape;
    final inputType = interPreter.getInputTensor(0).type;
    final outputType = interPreter.getOutputTensor(0).type;
    interPreter.allocateTensors();
    return ClassifierModel(
        interpreter: interPreter,
        inputShape: inputShape,
        outputShape: outPutShape,
        inputType: inputType,
        outputType: outputType);
  }

  Future<TensorImage> processImage(img.Image image) async {
    try {
      final model = await runModel();
      final inputTensor = TensorImage(model.inputType);
      inputTensor.loadImage(image);
      final targetHeigh = model.inputShape[1];
      final targetWith = model.inputShape[2];
      final imageProcess = ImageProcessorBuilder()
          .add(ResizeWithCropOrPadOp(image.height, image.width))
          .add(ResizeOp(targetHeigh, targetWith, ResizeMethod.bilinear))
          .add(NormalizeOp(127.5, 127.5))
          .build();
      imageProcess.process(inputTensor);
      return inputTensor;
    } on Exception catch (e) {
      debugPrint(e.toString());
      throw Exception(e);
    }
  }

  Future<Category> probabilityResult(TensorBuffer tensorBuffer) async {
    final probabilityProcessor = TensorProcessorBuilder().build();
    final labes = await runLabel();
    probabilityProcessor.process(tensorBuffer);
    final category = <Category>[];
    final labelledResult = TensorLabel.fromList(labes, tensorBuffer);
    labelledResult.getMapWithFloatValue().forEach((key, value) {
      debugPrint("key:$key score:$value");
      category.add(Category(key, value));
    });

    category.sort((a, b) => (b.score > a.score ? 1 : -1));
    debugPrint(category[0].toString());
    return category[0];
  }
}
