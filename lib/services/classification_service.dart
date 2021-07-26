import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class ClassificationService {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  TfLiteType outputType = TfLiteType.uint8;
  late TensorBuffer outputBuffer;

  late List<int> inputShape;
  late List<int> outputShape;
  late List<String> labels;

  // ClassificationService({String modelPath, String labelPath}) {
  //   _interpreterOptions = InterpreterOptions();
  //
  //   _interpreterOptions.threads = 1;
  // }
  //
  // Future<void> loadModel(String modelPath) async {
  //   try {
  //     interpreter = await Interpreter.fromAsset(modelPath, options: _interpreterOptions);
  //
  //     inputShape = interpreter.getInputTensor(0).shape;
  //     outputShape = interpreter.getOutputTensor(0).shape;
  //     outputType = interpreter.getOutputTensor(0).type;
  //
  //     outputBuffer =
  //   } catch(err) {
  //
  //   }
  // }
}