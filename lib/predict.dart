class Predict {
  String text;
  num confidence;
  String data;
  Predict({this.text, this.confidence, this.data});
  factory Predict.fromJson(Map<String, dynamic> json) {
    return Predict(
        text: json['text'] as String,
        confidence: json['confidence'] as num,
        data: json['data'] as String);
  }
  @override
  String toString() {
    return "[$text, $confidence, $data ]";
  }
}

class PredictResponse {
  Predict prediction;
  num code;
  String msg;

  PredictResponse({this.prediction, this.code, this.msg});
  factory PredictResponse.fromJson(Map<String, dynamic> json) {
    return PredictResponse(
      prediction: Predict.fromJson(json['prediction']),
      code: json['code'] as num,
      msg: json['msg'] as String,
    );
  }
  @override
  String toString() {
    return "[$prediction, $code, $msg ]";
  }
}
