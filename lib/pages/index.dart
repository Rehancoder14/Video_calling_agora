import 'dart:developer';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:fluttervid/pages/call.dart';
import 'package:fluttervid/utils/settings.dart';
import 'package:permission_handler/permission_handler.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({
    super.key,
  });

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final channelController = TextEditingController();
  TextEditingController tokenController = TextEditingController();

  bool validator = false;
  ClientRole clientRole = ClientRole.Broadcaster;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    tokenController.text = token;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Chat'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Image.network(
                  'https://tinyurl.com/2p889y4k',
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter channel name';
                    }
                    return null;
                  },
                  showCursor: true,
                  controller: channelController,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: 'Enter channel',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter token ';
                    }
                    return null;
                  },
                  showCursor: true,
                  maxLines: 3,
                  controller: tokenController,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: 'Enter token',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                RadioListTile(
                  value: ClientRole.Broadcaster,
                  groupValue: clientRole,
                  onChanged: (ClientRole? clientRoleType) {
                    setState(() {
                      clientRole = clientRoleType!;
                    });
                  },
                  title: const Text(
                    'Broadcaster',
                  ),
                ),
                RadioListTile(
                  value: ClientRole.Audience,
                  groupValue: clientRole,
                  onChanged: (ClientRole? clientRoleType) {
                    setState(() {
                      clientRole = clientRoleType!;
                    });
                  },
                  title: const Text(
                    'Audience',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // token = tokenController.text;
                            await _handleCameraAndMic(
                              Permission.camera,
                            );
                            await _handleCameraAndMic(
                              Permission.microphone,
                            );
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallPage(
                                  channelName: channelController.text,
                                  clientRole: clientRole,
                                ),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: Text(
                            'Join',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    channelController.dispose();
    super.dispose();
  }
}

Future<void> _handleCameraAndMic(Permission permissions) async {
  final status = await permissions.request();
  log(status.toString(), name: 'PERMISSION');
}
