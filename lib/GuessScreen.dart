import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './GuessButton.dart';
import './predict.dart';
import './feedback.dart';
import './constants.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

class GuessScreen extends StatefulWidget {
  GuessScreen() : super() {
    FlutterStatusbarcolor.setNavigationBarColor(
        Color.fromARGB(255, 30, 30, 30));
  }

  @override
  _GuessScreenState createState() => _GuessScreenState();
}

PredictResponse parsePredict(String responseBody) {
  final parsed = json.decode(responseBody);

  return PredictResponse.fromJson(parsed);
}

class _GuessScreenState extends State<GuessScreen> {
  var isSelected = [true, false];
  var isCorrect = [false, false];
  var showFeedbackInput = false;
  var feedbackInputValue;
  var showFeedbackToggle = false;
  Future<PredictResponse> _predictionAvailable;
  PredictResponse _predictionData;
  @override
  void initState() {
    super.initState();
    predict(getMode(), 0);
  }

  void resetFeedbackToggle() {
    setState(() {
      showFeedbackToggle = false;
      showFeedbackInput = false;
      isCorrect = [false, false];
      feedbackInputValue = '';
    });
  }

  Future<PredictResponse> predict(mode, userId) {
    print("predict called");
    resetFeedbackToggle();
    final url = '${Constants.baseUrl}/random/predict?mode=$mode&userId=$userId';

    Future<PredictResponse> p = http.get(url).then((response) {
      final parsed = json.decode(response.body);
      final pd = PredictResponse.fromJson(parsed);
      setState(() {
        _predictionData = pd;
      });
      return pd;
    }).then((res) {
      setState(() {
        showFeedbackToggle = true;
      });
      return res;
    });
    setState(() {
      _predictionAvailable = p;
    });
    return p;
  }

  Future<FeedbackResponse> feedback(mode, feedback, actualValue, userId, ctxt) {
    print("feedback called");
    resetFeedbackToggle();
    String url;
    if (feedback == 'correct') {
      var fdbk =
          '${_predictionData.prediction.text}:${actualValue}:${_predictionData.prediction.data}';
      fdbk = Uri.encodeQueryComponent(base64Url.encode(utf8.encode(fdbk)));
      url =
          '${Constants.baseUrl}/random/feedback?mode=$mode&userId=$userId&feedback=$fdbk';
    } else {
      setState(() {
        showFeedbackToggle = false;
        showFeedbackInput = true;
        feedbackInputValue = '';
      });
      return null;
    }
    return http.get(url).then((response) {
      final parsed = json.decode(response.body);
      Scaffold.of(ctxt).showSnackBar(SnackBar(
        content: Text('Feedback registered!'),
        backgroundColor: Color.fromARGB(200, 100, 50, 50),
      ));
      return FeedbackResponse.fromJson(parsed);
    });
  }

  String getMode() {
    return isSelected[0] == true ? 'number' : 'alpha';
  }

  String getFeedback() {
    return isCorrect[0] == true ? 'correct' : 'wrong';
  }

  void guessButtonPressed() {
    print("gues button pressed");
    predict(getMode(), 0);
  }

  @override
  Widget build(BuildContext ctxt) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 30, 30, 30),
      body: Builder(builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
              child: Column(
                children: <Widget>[
                  ToggleButtons(
                    children: <Widget>[
                      Container(
                        width: (MediaQuery.of(context).size.width - 36) / 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 20),
                          child: Row(children: <Widget>[
                            Icon(Icons.list),
                            SizedBox(width: 10),
                            Text('Number')
                          ]),
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width - 36) / 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 20),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.sort_by_alpha),
                              SizedBox(width: 10),
                              Text('Alphabet')
                            ],
                          ),
                        ),
                      )
                    ],
                    onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0;
                            buttonIndex < isSelected.length;
                            buttonIndex++) {
                          if (buttonIndex == index) {
                            isSelected[buttonIndex] = true;
                          } else {
                            isSelected[buttonIndex] = false;
                          }
                        }
                      });
                      predict(getMode(), 0);
                    },
                    isSelected: isSelected,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FutureBuilder<PredictResponse>(
                            future: _predictionAvailable,
                            builder: (_, predictSnapShot) {
                              print(
                                  "predict connectionstate :${predictSnapShot.connectionState}:${predictSnapShot.data}");
                              if (predictSnapShot.connectionState ==
                                  ConnectionState.done) {
                                if (predictSnapShot.hasData) {
                                  return GuessButton(
                                      mode: getMode(),
                                      value:
                                          predictSnapShot.data.prediction.text,
                                      confidence: predictSnapShot
                                          .data.prediction.confidence,
                                      onPressed: guessButtonPressed);
                                } else {
                                  return GuessButton(
                                      mode: getMode(),
                                      value: 'Error',
                                      confidence: 100,
                                      onPressed: guessButtonPressed);
                                }
                              } else {
                                return SizedBox(
                                  width: 234,
                                  height: 234,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.red),
                                  ),
                                );
                              }
                            }),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  showFeedbackToggle && _predictionData != null
                      ? ToggleButtons(
                          children: <Widget>[
                            Container(
                              width:
                                  (MediaQuery.of(context).size.width - 36) / 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 20),
                                child: Row(children: <Widget>[
                                  Icon(Icons.check),
                                  SizedBox(width: 10),
                                  Text('Correct')
                                ]),
                              ),
                            ),
                            Container(
                              width:
                                  (MediaQuery.of(context).size.width - 36) / 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 20),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.clear),
                                    SizedBox(width: 10),
                                    Text('Wrong')
                                  ],
                                ),
                              ),
                            )
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0;
                                  buttonIndex < isCorrect.length;
                                  buttonIndex++) {
                                if (buttonIndex == index) {
                                  isCorrect[buttonIndex] = true;
                                } else {
                                  isCorrect[buttonIndex] = false;
                                }
                              }
                              if (_predictionData != null) {
                                feedback(
                                    getMode(),
                                    getFeedback(),
                                    _predictionData.prediction.text,
                                    0,
                                    context);
                              }
                            });
                          },
                          isSelected: isCorrect,
                        )
                      : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  showFeedbackInput
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                onChanged: (text) {
                                  feedbackInputValue = text;
                                },
                              ),
                            ),
                            FlatButton(
                              child: Text('Submit'),
                              onPressed: () {
                                if (feedbackInputValue != null &&
                                    feedbackInputValue.isNotEmpty) {
                                  feedback(getMode(), 'correct',
                                      feedbackInputValue, 0, context);
                                  setState(() {
                                    showFeedbackInput = false;
                                  });
                                } else {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text('Please input a feedback!'),
                                    backgroundColor:
                                        Color.fromARGB(200, 100, 50, 50),
                                  ));
                                }
                              },
                            )
                          ],
                        )
                      : Container()
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
