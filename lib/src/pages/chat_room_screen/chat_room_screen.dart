import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/chat_room_screen_bloc.dart';


class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({Key key}) : super(key: key);

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }
  void _onToggleMute(BuildContext context) {
    BlocProvider.of<ChatRoomScreenBloc>(context).add(ToggleMute());
  }
  void _onSwitchCamera(BuildContext context) {
    BlocProvider.of<ChatRoomScreenBloc>(context).add(SwitchCamera());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatRoomScreenBloc,ChatRoomScreenState>(
      builder: (BuildContext context, ChatRoomScreenState state){
        return _buildWidget(context, state);
      }
    );
  }

  Widget _buildWidget(BuildContext context, ChatRoomScreenState state){
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Bloc Agora QuickStart'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: state.loading ? CircularProgressIndicator() : Stack(
          children: <Widget>[
            _viewRows(context, state),
            _panel(context, state),
            _toolbar(context, state),
          ],
        ),
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows(BuildContext context, ChatRoomScreenState state) {
    final views = _getRenderViews(context, state);
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Info panel to show logs
  Widget _panel(BuildContext context, ChatRoomScreenState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: state.infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (state.infoStrings.isEmpty) {
                return null;
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
                          state.infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Toolbar layout
  Widget _toolbar(BuildContext context, ChatRoomScreenState state) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () => _onToggleMute(context),
            child: Icon(
              state.muted ? Icons.mic_off : Icons.mic,
              color: state.muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: state.muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: () => _onSwitchCamera(context),
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews(BuildContext context, ChatRoomScreenState state) {
    final List<AgoraRenderWidget> list = [
      AgoraRenderWidget(0, local: true, preview: true),
    ];
    state.users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }
}
