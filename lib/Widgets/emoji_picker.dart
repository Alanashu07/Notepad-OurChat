import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../main.dart';

Widget emojiSelect(TextEditingController controller) {
  return EmojiPicker(
    textEditingController: controller,
    config: Config(
      height: 256,
      checkPlatformCompatibility: true,
      emojiSet: defaultEmojiSet,
      emojiViewConfig: EmojiViewConfig(
        // Issue: https://github.com/flutter/flutter/issues/28894
        emojiSizeMax: 28 *
            (defaultTargetPlatform == TargetPlatform.iOS
                ?  1.20
                :  1.0),
      ),
      swapCategoryAndBottomBar:  false,
      skinToneConfig: const SkinToneConfig(),
      categoryViewConfig: const CategoryViewConfig(),
      bottomActionBarConfig: const BottomActionBarConfig(),
      searchViewConfig: const SearchViewConfig(),
    ),
  );
}