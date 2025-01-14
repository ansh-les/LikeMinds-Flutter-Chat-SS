import 'dart:async';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:flutter_typeahead_mm/flutter_typeahead.dart';
import 'package:likeminds_chat_ss_fl/src/utils/imports.dart';

class LMTextField extends StatefulWidget {
  final bool isDown;
  final FocusNode focusNode;
  final Function(UserTag) onTagSelected;
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final Function(String)? onChange;
  final int chatroomId;

  const LMTextField({
    super.key,
    required this.isDown,
    required this.chatroomId,
    required this.onTagSelected,
    required this.controller,
    required this.focusNode,
    this.style,
    this.decoration,
    this.onChange,
  });

  @override
  State<LMTextField> createState() => _LMTextFieldState();
}

class _LMTextFieldState extends State<LMTextField> {
  late final TextEditingController _controller;
  FocusNode? _focusNode;
  final ScrollController _scrollController = ScrollController();
  final SuggestionsBoxController _suggestionsBoxController =
      SuggestionsBoxController();

  List<UserTag> userTags = [];

  int page = 1;
  int tagCount = 0;
  bool tagComplete = false;
  String textValue = "";
  String tagValue = "";
  static const FIXED_SIZE = 6;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode;
    _controller = widget.controller!;
    _scrollController.addListener(() async {
      // page++;
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        page++;
        final taggingData = (await locator<LikeMindsService>().getTaggingList(
          (TagRequestModelBuilder()
                ..chatroomId(widget.chatroomId)
                ..page(page)
                ..pageSize(FIXED_SIZE))
              .build(),
        ))
            .data;
        if (taggingData!.members != null && taggingData.members!.isNotEmpty) {
          userTags.addAll(taggingData.members!.map((e) => e).toList());
          // return userTags;
        }
      }
    });
  }

  TextEditingController? get controller => _controller;

  FutureOr<Iterable<UserTag>> _getSuggestions(String query) async {
    String currentText = query;
    try {
      if (currentText.isEmpty) {
        return const Iterable.empty();
      } else if (!tagComplete && currentText.contains('@')) {
        String tag = tagValue.substring(1).replaceAll(' ', '');
        final taggingData = (await locator<LikeMindsService>().getTaggingList(
          (TagRequestModelBuilder()
                ..chatroomId(widget.chatroomId)
                ..page(page)
                ..searchQuery(tag)
                ..pageSize(FIXED_SIZE))
              .build(),
        ))
            .data;
        if (taggingData!.members != null && taggingData.members!.isNotEmpty) {
          userTags = taggingData.members!.map((e) => e).toList();
          return userTags;
        }
        return const Iterable.empty();
      } else {
        return const Iterable.empty();
      }
    } catch (e) {
      return const Iterable.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 6.0,
        right: 6.0,
        bottom: 4.0,
      ),
      child: TypeAheadField<UserTag>(
        tagColor: secondary,
        onTagTap: (p) {
          // print(p);
        },
        suggestionsBoxController: _suggestionsBoxController,
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          offsetX: -2.w,
          elevation: 2,
          color: kWhiteColor,
          clipBehavior: Clip.hardEdge,
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          hasScrollbar: false,
          constraints: BoxConstraints(
            maxHeight: 24.h,
            minWidth: 80.w,
          ),
        ),
        // keepSuggestionsOnLocading: true,
        noItemsFoundBuilder: (context) => const SizedBox.shrink(),
        hideOnEmpty: true,
        debounceDuration: const Duration(milliseconds: 500),
        scrollController: _scrollController,
        textFieldConfiguration: TextFieldConfiguration(
          keyboardType: TextInputType.multiline,
          controller: _controller,
          style: widget.style ?? const TextStyle(fontSize: 14),
          textCapitalization: TextCapitalization.sentences,
          focusNode: _focusNode,
          minLines: 1,
          maxLines: 200,
          enabled: widget.decoration?.enabled ?? true,
          decoration: widget.decoration ??
              InputDecoration(
                hintText: 'Type something...',
                hintStyle: widget.style,
                border: InputBorder.none,
              ),
          onChanged: ((value) {
            widget.onChange!(value);
            final int newTagCount = '@'.allMatches(value).length;
            final int completeCount = '~'.allMatches(value).length;
            if (newTagCount == completeCount) {
              textValue = _controller.value.text;
              tagComplete = true;
            } else if (newTagCount > completeCount) {
              tagComplete = false;
              tagCount = completeCount;
              tagValue = value.substring(value.lastIndexOf('@'));
              textValue = value.substring(0, value.lastIndexOf('@'));
            }
          }),
        ),
        direction: widget.isDown ? AxisDirection.down : AxisDirection.up,
        suggestionsCallback: (suggestion) async {
          return await _getSuggestions(suggestion);
        },
        keepSuggestionsOnSuggestionSelected: true,

        itemBuilder: ((context, opt) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(
                bottom: BorderSide(
                  color: kGrey3Color,
                  width: 0.2,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    LMProfilePicture(
                      fallbackText: opt.name!,
                      imageUrl: opt.imageUrl,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      opt.name!,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        onSuggestionSelected: ((suggestion) {
          debugPrint(suggestion.toString());
          widget.onTagSelected.call(suggestion);
          setState(() {
            tagComplete = true;
            tagCount = '@'.allMatches(_controller.text).length;
            // _controller.text.substring(_controller.text.lastIndexOf('@'));
            if (textValue.length > 2 &&
                textValue.substring(textValue.length - 1) == '~') {
              textValue += " @${suggestion.name!}~";
            } else {
              textValue += "@${suggestion.name!}~";
            }
            _controller.text = '$textValue ';
            _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length));
            tagValue = '';
            textValue = _controller.value.text;
            page = 1;
          });
        }),
      ),
    );
  }
}

extension NthOccurrenceOfSubstring on String {
  int nThIndexOf(String stringToFind, int n) {
    if (indexOf(stringToFind) == -1) return -1;
    if (n == 1) return indexOf(stringToFind);
    int subIndex = -1;
    while (n > 0) {
      subIndex = indexOf(stringToFind, subIndex + 1);
      n -= 1;
    }
    return subIndex;
  }

  bool hasNthOccurrence(String stringToFind, int n) {
    return nThIndexOf(stringToFind, n) != -1;
  }
}
