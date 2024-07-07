import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';

class ClassifierModel {
  Interpreter interpreter;
  List<int> inputShape;
  List<int> outputShape;
  TfLiteType inputType;
  TfLiteType outputType;
  ClassifierModel({
    required this.interpreter,
    required this.inputShape,
    required this.outputShape,
    required this.inputType,
    required this.outputType,
  });
}
