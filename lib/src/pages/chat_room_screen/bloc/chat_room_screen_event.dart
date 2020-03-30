part of 'chat_room_screen_bloc.dart';

@immutable
abstract class ChatRoomScreenEvent {}

class InitializeChatRoomScreen extends ChatRoomScreenEvent {}
class AgoraEngineError extends ChatRoomScreenEvent {
  final dynamic code;
  AgoraEngineError(this.code);
}
class AgoraEngineJoinChannelSuccess extends ChatRoomScreenEvent {
  final String channel;
  final int uid;
  final int elapsed;

  AgoraEngineJoinChannelSuccess({
    @required this.channel,
    @required this.uid,
    @required this.elapsed,
  });
}

class AgoraEngineLeaveChannel extends ChatRoomScreenEvent {}

class AgoraEngineFirstRemoteVideoFrame extends ChatRoomScreenEvent {
  final int uid;
  final int width;
  final int height;
  final int elapsed;
  AgoraEngineFirstRemoteVideoFrame({
    @required this.uid,
    @required this.width,
    @required this.height,
    @required this.elapsed,
  });
}
class AgoraEngineUserOffline extends ChatRoomScreenEvent {
  final int uid;
  final int reason;
  AgoraEngineUserOffline({
    @required this.uid,
    @required this.reason,
  });
}
class AgoraEngineUserJoined extends ChatRoomScreenEvent {
  final int uid;
  final int elapsed;
  AgoraEngineUserJoined({
    @required this.uid,
    @required this.elapsed,
  });
}
class ToggleMute extends ChatRoomScreenEvent {}
class SwitchCamera extends ChatRoomScreenEvent {}