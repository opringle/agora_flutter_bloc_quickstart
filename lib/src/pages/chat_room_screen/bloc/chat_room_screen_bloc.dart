import 'dart:async';
import 'dart:ui';

import 'package:agora_flutter_quickstart/src/utils/settings.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'chat_room_screen_event.dart';
part 'chat_room_screen_state.dart';

class ChatRoomScreenBloc extends Bloc<ChatRoomScreenEvent, ChatRoomScreenState> {

  ChatRoomScreenBloc(){
    add(InitializeChatRoomScreen());
  }

  @override
  ChatRoomScreenState get initialState => ChatRoomScreenState.empty();

  @override
  Stream<ChatRoomScreenState> mapEventToState(
    ChatRoomScreenEvent event,
  ) async* {
    if (event is InitializeChatRoomScreen){
      yield* _mapInitializeChatRoomScreenToState(event);
    } else if (event is AgoraEngineError){
      yield* _mapAgoraEngineErrorToState(event);
    } else if (event is AgoraEngineJoinChannelSuccess){
      yield* _mapAgoraEngineJoinChannelSuccessToState(event);
    } else if (event is AgoraEngineLeaveChannel){
      yield* _mapAgoraEngineLeaveChannelToState(event);
    } else if (event is AgoraEngineFirstRemoteVideoFrame){
      yield* _mapAgoraEngineFirstRemoteVideoFrameToState(event);
    } else if (event is AgoraEngineUserOffline){
      yield* _mapAgoraEngineUserOfflineToState(event);
    } else if (event is AgoraEngineUserJoined){
      yield* _mapAgoraEngineUserJoinedToState(event);
    } else if (event is ToggleMute){
      yield* _mapToggleMuteToState(event);
    } else if (event is SwitchCamera){
      yield* _mapSwitchCameraToState(event);
    }
  }
  Stream<ChatRoomScreenState> _mapInitializeChatRoomScreenToState(InitializeChatRoomScreen event) async* {
    if (APP_ID.isEmpty) {
      List<String> updatedInfoStrings = state.infoStrings;
      updatedInfoStrings.add(
        'APP_ID missing, please provide your APP_ID in settings.dart',
      );
      updatedInfoStrings.add('Agora Engine is not starting');
      yield state.copyWith(
        infoStrings: updatedInfoStrings,
      );
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // video settings
    VideoEncoderConfiguration config = VideoEncoderConfiguration();
    config.orientationMode = VideoOutputOrientationMode.FixedPortrait;
    config.degradationPreference = DegradationPreference.MaintainFramerate;
    config.frameRate = 30;
    config.minFrameRate = 15;
    config.dimensions = Size(320, 180);
    config.bitrate = AgoraVideoBitrateStandard;
    config.minBitrate = 100;
    
    await Future.wait([
      AgoraRtcEngine.enableWebSdkInteroperability(true),
      // TODO: stream higher quality video
      AgoraRtcEngine.setChannelProfile(ChannelProfile.Communication),
      AgoraRtcEngine.setVideoEncoderConfiguration(config),
      // TODO: ensure android device plays audio...
      AgoraRtcEngine.setAudioProfile(AudioProfile.SpeechStandard, AudioScenario.Default),
      AgoraRtcEngine.setDefaultAudioRouteToSpeaker(true),
      AgoraRtcEngine.setEnableSpeakerphone(true),
      AgoraRtcEngine.adjustPlaybackSignalVolume(400),
      AgoraRtcEngine.adjustRecordingSignalVolume(400),
      AgoraRtcEngine.adjustAudioMixingVolume(100),
    ]);

    await AgoraRtcEngine.joinChannel(null, state.channelName, null, 0);
    yield state.copyWith(loading: false);
  }
  Stream<ChatRoomScreenState> _mapAgoraEngineErrorToState(AgoraEngineError event) async* {
    List<String> updatedInfoStrings = state.infoStrings;
    final info = 'onError: $event.code';
    updatedInfoStrings.add(info);
    yield state.copyWith(
      infoStrings: updatedInfoStrings,
    );
  }
  Stream<ChatRoomScreenState> _mapAgoraEngineLeaveChannelToState(AgoraEngineLeaveChannel event) async* {
    List<String> updatedInfoStrings = state.infoStrings;
    List<int> updatedUsers = state.users;
    updatedInfoStrings..add('onLeaveChannel');
    updatedUsers.clear();
    yield state.copyWith(
      infoStrings: updatedInfoStrings,
      users: updatedUsers,
    );
  }
  Stream<ChatRoomScreenState> _mapAgoraEngineFirstRemoteVideoFrameToState(AgoraEngineFirstRemoteVideoFrame event) async* {
    List<String> updatedInfoStrings = state.infoStrings;
    final info = 'firstRemoteVideo: $event.uid ${event.width}x $event.height';
    updatedInfoStrings.add(info);
    yield state.copyWith(
      infoStrings: updatedInfoStrings,
    );
  }
  Stream<ChatRoomScreenState> _mapAgoraEngineUserOfflineToState(AgoraEngineUserOffline event) async* {
    final info = 'userOffline: $event.uid';
    List<String> updatedInfoStrings = state.infoStrings;
    List<int> updatedUsers = state.users;
    updatedInfoStrings.add(info);
    updatedUsers.remove(event.uid);
    yield state.copyWith(
      users: updatedUsers,
      infoStrings: updatedInfoStrings,
    );
  }
  Stream<ChatRoomScreenState> _mapAgoraEngineUserJoinedToState(AgoraEngineUserJoined event) async* {
    final info = 'userJoined: $event.uid';
    List<String> updatedInfoStrings = state.infoStrings;
    List<int> updatedUsers = state.users;
    updatedInfoStrings.add(info);
    updatedUsers.add(event.uid);
    yield state.copyWith(
      users: updatedUsers,
      infoStrings: updatedInfoStrings,
    );
  }
  Stream<ChatRoomScreenState> _mapAgoraEngineJoinChannelSuccessToState(AgoraEngineJoinChannelSuccess event) async* {
    List<String> updatedInfoStrings = state.infoStrings;
    final info = 'onJoinChannel: $event.channel, uid: $event.uid';
    updatedInfoStrings.add(info);
    yield state.copyWith(
      infoStrings: updatedInfoStrings,
    );
  }
  Stream<ChatRoomScreenState> _mapToggleMuteToState(ToggleMute event) async* {
    await AgoraRtcEngine.muteLocalAudioStream(!state.muted);
    yield state.copyWith(
      muted: !state.muted,
    );
  }
  Stream<ChatRoomScreenState> _mapSwitchCameraToState(SwitchCamera event) async* {
    await AgoraRtcEngine.switchCamera();
  }
  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.enableVideo();
  }

  /// Add agora event handlers
  _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      add(AgoraEngineError(code));
    };
    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      add(AgoraEngineJoinChannelSuccess(
        channel: channel,
        uid: uid,
        elapsed: elapsed,
      ));
    };

    AgoraRtcEngine.onLeaveChannel = () {
      add(AgoraEngineLeaveChannel());
    };
    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      add(AgoraEngineUserJoined(
        uid: uid,
        elapsed: elapsed,
      ));
    };
    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      add(AgoraEngineUserOffline(uid: uid, reason: reason));
    };
    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      add(AgoraEngineFirstRemoteVideoFrame(
        uid: uid,
        width: width,
        height: height,
        elapsed: elapsed,
      ));
    };
  }

  @override
  Future<void> close() {
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    return super.close();
  }
}
