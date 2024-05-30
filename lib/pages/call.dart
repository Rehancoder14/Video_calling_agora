import 'dart:developer';
import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttervid/utils/settings.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class CallPage extends StatefulWidget {
  final String? channelName;
  final ClientRole? clientRole; // todo: change this if required
  const CallPage({super.key, this.channelName, this.clientRole});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine _engine;
  bool isOn = false;
  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() async {
    if (appId.isEmpty) {
      setState(() {
        _infoStrings.add(
            'AppId is missing , please provider your appId in settings.dart');
        _infoStrings.add('Agora engine is not starting');
      });
      return;
    }
    //create the engine
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.enableAudio();
    speechToText();
    await _engine.setClientRole(
      widget.clientRole!,
    );
    // await _engine.initialize(const RtcEngineContext(
    //   appId: appId,
    //   channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    // ));
    _addAgoraEventHandler();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = const VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(
      token,
      widget.channelName!,
      null,
      0,
    );
  } // todo

  _addAgoraEventHandler() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
        error: (e) {
          setState(
            () {
              final info = 'Error: $e';
              _infoStrings.add('onError: $info');
            },
          );
        },
        joinChannelSuccess: (rtcConnection, count, uid) {
          setState(() {
            final info = 'onJoinChannel: $uid';
            _infoStrings.add('onJoinChannel: $info');
          });
        },
        userJoined: (uid, elapsed) {
          setState(() {
            final info = 'onUserJoined: $uid';
            _infoStrings.add(info);
            _users.add(uid);
          });
        },
        userOffline: (
          connection,
          remoteUid,
        ) {
          setState(
            () {
              final info = 'onUserOffline: $remoteUid';
              _infoStrings.add(info);
              _users.remove(connection);
            },
          );
        },
        firstRemoteVideoFrame: (connection, remoteUid, width, height) {
          setState(() {
            final info = 'FirstRemoteVideo: $remoteUid ${width}x $height';
            _infoStrings.add(info);
          });
        },
      ),
    );
  }

  Widget _viewRows() {
    final List<StatefulWidget> list = [];
    if (widget.clientRole == ClientRole.Broadcaster) {
      list.add(
        const rtc_local_view.SurfaceView(),
      );
    }
    for (var uid in _users) {
      list.add(
        rtc_remote_view.SurfaceView(
          uid: uid,
          channelId: widget.channelName!,
        ),
      );
    }

    final views = list;
    return Column(
      children: List.generate(
        views.length,
        (index) => Expanded(
          child: views[index],
        ),
      ),
    );
  }

  Widget _toolBar() {
    if (widget.clientRole == ClientRole.Audience) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: () {
              setState(() {
                muted = !muted;
              });
              _engine.muteLocalAudioStream(muted);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
            child: const Icon(Icons.call_end, color: Colors.white, size: 35.0),
          ),
          RawMaterialButton(
            onPressed: () {
              _engine.switchCamera();
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: const Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel() {
    return Visibility(
      visible: viewPanel,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: ListView.builder(
              reverse: true,
              itemCount: _infoStrings.length,
              itemBuilder: (context, index) {
                if (_infoStrings.isEmpty) {
                  return const Text('null');
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellowAccent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            _infoStrings[index],
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: const Text('Video Calling'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isOn = !isOn;
                });
                if (isOn) {
                  Future.delayed(
                    Duration(
                      seconds: 2,
                    ),
                    () {
                      showToast('_______****************____*__');
                      speechToText();
                    },
                  );
                }
              },
              icon: Icon(
                  isOn ? Icons.closed_caption : Icons.closed_caption_outlined),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  viewPanel = !viewPanel;
                });
              },
              icon: Icon(
                Icons.info_outline,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: Stack(children: <Widget>[
          _viewRows(),
          _panel(),
          _toolBar(),
        ]));
  }

  speechToText() async {
    stt.SpeechToText speech = stt.SpeechToText();
    bool available = await speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      speech.listen(
        onResult: (val) =>
            Fluttertoast.showToast(msg: 'onResult: ${val.recognizedWords}'),
      );
    } else {
      Fluttertoast.showToast(
          msg: "The user has denied the use of speech recognition.");
    }
  }

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    super.dispose();
  }

  Future showToast(String msg) async {
    Fluttertoast.showToast(msg: '_____________&&&&&&&&&******************');
    for (int i = 0; i < 3; i++) {
      Fluttertoast.showToast(msg: generateRandomString(i * 7));
    }
  }

  String generateRandomString(int length) {
    final random = Random();
    const availableChars = '!~@#%^&*()_+=}{|}';
    final randomString = List.generate(length,
            (index) => availableChars[random.nextInt(availableChars.length)])
        .join();
    return randomString;
  }
}
