import 'dart:math';
import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as img;

class ClassificationService {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  TfLiteType outputType = TfLiteType.uint8;
  late TensorBuffer outputBuffer;

  late List<int> inputShape;
  late List<int> outputShape;
  late List<String> labels;

  ClassificationService(
      {required String modelPath, required String labelPath}) {
    _interpreterOptions = InterpreterOptions();

    _interpreterOptions.threads = 1;

    loadModel(modelPath);
    loadLabel(labelPath);
  }

  Future<void> loadModel(String modelPath) async {
    try {
      interpreter =
      await Interpreter.fromAsset(modelPath, options: _interpreterOptions);

      inputShape = interpreter
          .getInputTensor(0)
          .shape;
      outputShape = interpreter
          .getOutputTensor(0)
          .shape;
      outputType = interpreter
          .getOutputTensor(0)
          .type;

      outputBuffer = TensorBuffer.createFixedSize(outputShape, outputType);

      print('Load Model - $inputShape / $outputShape / $outputType');
    } catch (err) {
      print('Error : ${err.toString()}')
    }
  }

  Future<void> loadLabel(String labelPath) async {
    if (labelPath != null) {
      labels = await FileUtil.loadLabels('assets/$labelPath');
      if (labels.length > 0) {
        print('Labels loaded successfully');
      } else {
        print('Unable to load labels');
      }
    }
  }

  TensorImage imageResize(TensorImage inputImage) {
    int cropSize = min(inputImage.height, inputImage.width);
    return ImageProcessorBuilder().add(
        ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(
        ResizeOp(inputShape[1], inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        .build()
        .process(inputImage);
  }

  List<dynamic> runClassification({required Uint8List imageData}) {
    img.Image _baseImage = img.decodeImage(imageData);
    TensorImage _inputImage = TensorImage.fromImage(_baseImage);
    _inputImage = imageResize(_inputImage);

    interpreter.run(_inputImage.buffer, outputBuffer.getBuffer());

    Map<String, double> map = Map<String, double>();
    var outputResult = outputBuffer.getDoubleList();
    var length = min(outputResult.length, labels.length);

    // mapping
    for (var i = 0; i < length; i++) {
      var name = labels[i];

      if (!map.containsKey(name)) {
        map[name] = outputResult[i];
      } else {
        if (map[name]! < outputResult[i]) {
          map[name] = outputResult[i];
        }
      }
    }

    // sort
    var sortedKeys = map.keys.toList(growable: false)
      ..sort((k1, k2) => map[k2]!.compareTo(map[k1]!));

    List<dynamic> result = [];
    for (var i = 0; i < 10; i++) {
      result.add({
        'label': sortedKeys[i],
        'value': map[sortedKeys[i]],
      });
    }
    return result;
  }
}