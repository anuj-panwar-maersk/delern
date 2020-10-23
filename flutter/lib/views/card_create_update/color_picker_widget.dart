import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';

List<Color> _colorPickerList = [
  app_styles.kRedCardColor,
  app_styles.kOrangeCardColor,
  app_styles.kYellowCardColor,
  app_styles.kGreenCardColor,
  app_styles.kBlueCardColor,
  app_styles.kPaleBlueCardColor,
  app_styles.kDarkBlueCardColor,
  app_styles.kLilacCardColor,
];

typedef ColorSelectedCallBack = void Function(int colorValue);

class CardColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ColorSelectedCallBack onColorSelected;

  const CardColorPicker({
    @required this.onColorSelected,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _colorPickerList
                  .map((color) => _ColorButton(
                        color: color,
                        selected: selectedColor != null &&
                            selectedColor.value == color.value,
                        onTap: () => onColorSelected(color.value),
                      ))
                  .toList()),
        ),
      );
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorButton({
    @required this.color,
    this.selected = false,
    this.onTap,
  }) : assert(color != null);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onTap?.call(),
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: selected
                ? Border.all(
                    color: app_styles.kColorSelectedBorderColor,
                    width: 2,
                  )
                : null,
          ),
        ),
      );
}
