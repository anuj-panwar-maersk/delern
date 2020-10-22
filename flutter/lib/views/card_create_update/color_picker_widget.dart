import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';

enum _ColorPicker {
  red,
  orange,
  yellow,
  green,
  blue,
  paleBlue,
  darkBlue,
  lilac,
}

Map<_ColorPicker, Color> _colorPickerMap = {
  _ColorPicker.red: app_styles.kRedCardColor,
  _ColorPicker.orange: app_styles.kOrangeCardColor,
  _ColorPicker.yellow: app_styles.kYellowCardColor,
  _ColorPicker.green: app_styles.kGreenCardColor,
  _ColorPicker.blue: app_styles.kBlueCardColor,
  _ColorPicker.paleBlue: app_styles.kPaleBlueCardColor,
  _ColorPicker.darkBlue: app_styles.kDarkBlueCardColor,
  _ColorPicker.lilac: app_styles.kLilacCardColor,
};

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
            children: _ColorPicker.values
                .map((e) => _ColorButton(
                      color: _colorPickerMap[e],
                      selected: selectedColor != null &&
                          selectedColor.value == _colorPickerMap[e].value,
                      onPressed: () =>
                          onColorSelected(_colorPickerMap[e].value),
                    ))
                .toList(),
          ),
        ),
      );
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  const _ColorButton({
    @required this.color,
    this.selected = false,
    this.onPressed,
  }) : assert(color != null);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onPressed?.call(),
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: selected
                ? Border.all(
                    color: app_styles.kCardPickeBorderColor,
                    width: 2,
                  )
                : null,
          ),
        ),
      );
}
