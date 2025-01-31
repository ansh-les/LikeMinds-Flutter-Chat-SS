import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:likeminds_chat_ss_fl/src/navigation/router.dart';
import 'package:likeminds_chat_ss_fl/src/service/media_service.dart';
import 'package:likeminds_chat_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_chat_ss_fl/src/utils/imports.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';

Widget mediaErrorWidget({bool isPP = false}) {
  return Container(
    color: isPP ? kPrimaryColor : kWhiteColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LMIcon(
          type: LMIconType.icon,
          icon: Icons.error_outline,
          size: 10,
          color: isPP ? kWhiteColor : kBlackColor,
        ),
        isPP ? const SizedBox() : const SizedBox(height: 12),
        isPP
            ? const SizedBox()
            : LMTextView(
                text: "An error occurred fetching media",
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 8,
                  color: isPP ? kWhiteColor : kBlackColor,
                ),
              )
      ],
    ),
  );
}

Widget mediaShimmer({bool? isPP}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade100,
    highlightColor: Colors.grey.shade200,
    period: const Duration(seconds: 2),
    direction: ShimmerDirection.ltr,
    child: isPP != null && isPP
        ? const CircleAvatar(backgroundColor: Colors.white)
        : Container(
            color: Colors.white,
            width: 60.w,
            height: 60.w,
          ),
  );
}

String getFileSizeString({required int bytes, int decimals = 0}) {
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  var i = (log(bytes) / log(1000)).floor();
  return "${((bytes / pow(1000, i)).toStringAsFixed(decimals))} ${suffixes[i]}";
}

// Returns file size in double in MBs
double getFileSizeInDouble(int bytes) {
  return (bytes / pow(1000, 2));
}

Widget getChatBubbleImage(Media mediaFile, {double? width, double? height}) {
  return Container(
    height: height,
    width: width,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Stack(
      children: [
        CachedNetworkImage(
          imageUrl: mediaFile.mediaType == MediaType.photo
              ? mediaFile.mediaUrl ?? ''
              : mediaFile.thumbnailUrl ?? '',
          fit: BoxFit.cover,
          height: height,
          width: width,
          errorWidget: (context, url, error) => mediaErrorWidget(),
          progressIndicatorBuilder: (context, url, progress) => mediaShimmer(),
        ),
        mediaFile.mediaType == MediaType.video && mediaFile.thumbnailUrl != null
            ? Center(
                child: LMIcon(
                  type: LMIconType.icon,
                  icon: Icons.play_arrow,
                  color: kBlackColor,
                  boxSize: 8.w,
                  backgroundColor: kWhiteColor.withOpacity(0.7),
                  size: 6.w,
                  boxBorderRadius: 4.w,
                  boxPadding: 2.w,
                ),
              )
            : const SizedBox(),
      ],
    ),
  );
}

Widget getImageMessage(
    BuildContext context,
    List<Media>? conversationAttachments,
    ChatRoom chatroom,
    Conversation conversation,
    Map<int, User?> userMeta) {
  void onTap() {
    router.pushNamed(
      "media_preview",
      extra: [
        conversationAttachments,
        chatroom,
        conversation,
        userMeta,
      ],
    );
  }

  if (conversationAttachments!.length == 1) {
    return GestureDetector(
      onTap: onTap,
      child: getChatBubbleImage(
        conversationAttachments.first,
        height: 55.w,
        width: 55.w,
      ),
    );
  } else if (conversationAttachments.length == 2) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          getChatBubbleImage(
            conversationAttachments[0],
            height: 26.w,
            width: 26.w,
          ),
          kHorizontalPaddingSmall,
          getChatBubbleImage(
            conversationAttachments[1],
            height: 26.w,
            width: 26.w,
          ),
        ],
      ),
    );
  } else if (conversationAttachments.length == 3) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          getChatBubbleImage(
            conversationAttachments[0],
            height: 26.w,
            width: 26.w,
          ),
          kHorizontalPaddingSmall,
          Container(
            height: 26.w,
            width: 26.w,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Stack(
              children: [
                getChatBubbleImage(
                  conversationAttachments[1],
                  height: 26.w,
                  width: 26.w,
                ),
                Positioned(
                  child: Container(
                    height: 26.w,
                    width: 26.w,
                    alignment: Alignment.center,
                    color: kBlackColor.withOpacity(0.5),
                    child: const LMTextView(
                      text: '+2',
                      textStyle: TextStyle(
                        color: kWhiteColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  } else if (conversationAttachments.length == 4) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: <Widget>[
              getChatBubbleImage(
                conversationAttachments[0],
                height: 26.w,
                width: 26.w,
              ),
              kHorizontalPaddingSmall,
              getChatBubbleImage(
                conversationAttachments[1],
                height: 26.w,
                width: 26.w,
              ),
            ],
          ),
          kVerticalPaddingSmall,
          Row(
            children: <Widget>[
              getChatBubbleImage(
                conversationAttachments[2],
                height: 26.w,
                width: 26.w,
              ),
              kHorizontalPaddingSmall,
              getChatBubbleImage(
                conversationAttachments[3],
                height: 26.w,
                width: 26.w,
              ),
            ],
          ),
        ],
      ),
    );
  } else {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: <Widget>[
              getChatBubbleImage(
                conversationAttachments[0],
                height: 26.w,
                width: 26.w,
              ),
              kHorizontalPaddingSmall,
              getChatBubbleImage(
                conversationAttachments[1],
                height: 26.w,
                width: 26.w,
              ),
            ],
          ),
          kVerticalPaddingSmall,
          Row(
            children: <Widget>[
              getChatBubbleImage(
                conversationAttachments[2],
                height: 26.w,
                width: 26.w,
              ),
              kHorizontalPaddingSmall,
              Container(
                height: 26.w,
                width: 26.w,
                clipBehavior: Clip.hardEdge,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(6.0)),
                child: Stack(
                  children: [
                    getChatBubbleImage(
                      conversationAttachments[3],
                      height: 26.w,
                      width: 26.w,
                    ),
                    Positioned(
                      child: Container(
                        height: 26.w,
                        width: 26.w,
                        alignment: Alignment.center,
                        color: kBlackColor.withOpacity(0.5),
                        child: LMTextView(
                          text: '+${conversationAttachments.length - 3}',
                          textStyle: const TextStyle(
                            color: kWhiteColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget getFileImageTile(Media mediaFile, {double? width, double? height}) {
  if (mediaFile.mediaFile == null && mediaFile.thumbnailFile == null) {
    return mediaErrorWidget();
  }
  return Container(
    height: height,
    width: width,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(3.0),
    ),
    child: Stack(
      children: [
        Image.file(
          mediaFile.mediaType == MediaType.photo
              ? mediaFile.mediaFile!
              : mediaFile.thumbnailFile!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => mediaErrorWidget(),
          height: height,
          width: width,
        ),
        mediaFile.mediaType == MediaType.video &&
                mediaFile.thumbnailFile != null
            ? Center(
                child: LMIcon(
                  type: LMIconType.icon,
                  icon: Icons.play_arrow,
                  color: kBlackColor,
                  boxSize: 36,
                  backgroundColor: kWhiteColor.withOpacity(0.7),
                  size: 24,
                  boxBorderRadius: 18,
                  boxPadding: 8,
                ),
              )
            : const SizedBox(),
      ],
    ),
  );
}

Widget getImageFileMessage(BuildContext context, List<Media> mediaFiles) {
  if (mediaFiles.length == 1) {
    return GestureDetector(
      child: getFileImageTile(
        mediaFiles.first,
        height: 55.w,
        width: 55.w,
      ),
    );
  } else if (mediaFiles.length == 2) {
    return GestureDetector(
      child: Row(
        children: <Widget>[
          getFileImageTile(
            mediaFiles[0],
            height: 26.w,
            width: 26.w,
          ),
          kHorizontalPaddingSmall,
          getFileImageTile(
            mediaFiles[1],
            height: 26.w,
            width: 26.w,
          )
        ],
      ),
    );
  } else if (mediaFiles.length == 3) {
    return GestureDetector(
      child: Row(
        children: <Widget>[
          getFileImageTile(
            mediaFiles[0],
            height: 26.w,
            width: 26.w,
          ),
          kHorizontalPaddingSmall,
          Container(
            height: 26.w,
            width: 26.w,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Stack(
              children: [
                getFileImageTile(
                  mediaFiles[1],
                  height: 26.w,
                  width: 26.w,
                ),
                Positioned(
                  child: Container(
                    height: 26.w,
                    width: 26.w,
                    alignment: Alignment.center,
                    color: kBlackColor.withOpacity(0.5),
                    child: const LMTextView(
                      text: '+2',
                      textStyle: TextStyle(
                        color: kWhiteColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  } else if (mediaFiles.length == 4) {
    return GestureDetector(
      child: Column(
        children: [
          Row(
            children: <Widget>[
              getFileImageTile(
                mediaFiles[0],
                height: 26.w,
                width: 26.w,
              ),
              kHorizontalPaddingSmall,
              getFileImageTile(
                mediaFiles[1],
                height: 26.w,
                width: 26.w,
              ),
            ],
          ),
          kVerticalPaddingSmall,
          Row(
            children: <Widget>[
              getFileImageTile(
                mediaFiles[2],
                height: 26.w,
                width: 26.w,
              ),
              kHorizontalPaddingSmall,
              getFileImageTile(
                mediaFiles[3],
                height: 26.w,
                width: 26.w,
              ),
            ],
          ),
        ],
      ),
    );
  } else {
    return GestureDetector(
      child: Column(
        children: [
          Row(
            children: <Widget>[
              getFileImageTile(
                mediaFiles[0],
                height: 26.w,
                width: 26.w,
              ),
              kHorizontalPaddingSmall,
              getFileImageTile(
                mediaFiles[1],
                height: 26.w,
                width: 26.w,
              ),
            ],
          ),
          kVerticalPaddingSmall,
          Row(
            children: <Widget>[
              getFileImageTile(
                mediaFiles[2],
                height: 26.w,
                width: 26.w,
              ),
              kHorizontalPaddingSmall,
              Container(
                height: 26.w,
                width: 26.w,
                clipBehavior: Clip.hardEdge,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(6.0)),
                child: Stack(
                  children: [
                    getFileImageTile(
                      mediaFiles[3],
                      height: 26.w,
                      width: 26.w,
                    ),
                    Positioned(
                      child: Container(
                        height: 26.w,
                        width: 26.w,
                        alignment: Alignment.center,
                        color: kBlackColor.withOpacity(0.5),
                        child: LMTextView(
                          text: '+${mediaFiles.length - 3}',
                          textStyle: const TextStyle(
                            color: kWhiteColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
