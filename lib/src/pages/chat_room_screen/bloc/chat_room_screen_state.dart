part of 'chat_room_screen_bloc.dart';

@immutable
class ChatRoomScreenState {
  final bool loading;
  final String channelName;
  final List<String> infoStrings;
  final List<int> users;
  final bool muted;

  ChatRoomScreenState({
    @required this.loading,
    @required this.channelName,
    @required this.infoStrings,
    @required this.users,
    @required this.muted,
  });

  ChatRoomScreenState copyWith({
    bool loading,
    String channelName,
    List<String> infoStrings,
    List<int> users,
    bool muted,
  }){
    return ChatRoomScreenState(
      loading: loading ?? this.loading,
      channelName: channelName ?? this.channelName,
      infoStrings: infoStrings ?? this.infoStrings,
      users: users ?? this.users,
      muted: muted ?? this.muted,
    );
  }

  factory ChatRoomScreenState.empty(){
    return ChatRoomScreenState(
      loading: true,
      channelName: '123',
      infoStrings: [],
      users: [],
      muted: false,
    );
  }
}

