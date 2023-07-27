import 'package:flick_video_player/flick_video_player.dart';
import 'package:likeminds_chat_ss_fl/src/service/media_service.dart';
import 'package:likeminds_chat_ss_fl/src/widgets/media/multimedia/video/chat_video.dart';
import 'package:flutter/material.dart';

Widget chatVideoFactory(Media media, FlickManager flickManager) {
  if (media.mediaFile != null) {
    return ChatVideo(
      media: media,
      flickManager: flickManager,
    );
  } else if (media.mediaUrl != null) {
    return ChatVideo(
      media: media,
      flickManager: flickManager,
      showControls: true,
    );
  }
  return const SizedBox.shrink();
}
