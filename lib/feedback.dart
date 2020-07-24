class FeedbackResponse {
  num code;
  String msg;

  FeedbackResponse({this.code, this.msg});
  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      code: json['code'] as num,
      msg: json['msg'] as String,
    );
  }
  @override
  String toString() {
    return "[$code, $msg ]";
  }
}
