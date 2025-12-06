import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_color_picker/custom_picker/extensions.dart';
import 'package:ios_color_picker/custom_picker/pickers/slider_picker/slider_helper.dart';
import 'package:ios_color_picker/l10n/strings.dart';

import '../../shared.dart';
import '../../utils.dart';

class SlidePicker extends StatefulWidget {
  const SlidePicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    this.colorModel = ColorModel.rgb,
    this.enableAlpha = true,
    this.sliderSize = const Size(260, 40),
    this.showSliderText = true,
    @Deprecated(
        'Use Theme.of(context).textTheme.bodyText1 & 2 to alter text style.')
    this.sliderTextStyle,
    this.showParams = true,
    @Deprecated('Use empty list in [labelTypes] to disable label.')
    this.showLabel = true,
    this.labelTypes = const [],
    @Deprecated(
        'Use Theme.of(context).textTheme.bodyText1 & 2 to alter text style.')
    this.labelTextStyle,
    this.showIndicator = true,
    this.indicatorSize = const Size(280, 50),
    this.indicatorAlignmentBegin = const Alignment(-1.0, -3.0),
    this.indicatorAlignmentEnd = const Alignment(1.0, 3.0),
    this.displayThumbColor = true,
    this.indicatorBorderRadius = const BorderRadius.all(Radius.zero),
  });

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final ColorModel colorModel;
  final bool enableAlpha;
  final Size sliderSize;
  final bool showSliderText;
  final TextStyle? sliderTextStyle;
  final bool showLabel;
  final bool showParams;
  final List<ColorLabelType> labelTypes;
  final TextStyle? labelTextStyle;
  final bool showIndicator;
  final Size indicatorSize;
  final AlignmentGeometry indicatorAlignmentBegin;
  final AlignmentGeometry indicatorAlignmentEnd;
  final bool displayThumbColor;
  final BorderRadius indicatorBorderRadius;

  @override
  State<StatefulWidget> createState() => _SlidePickerState();
}

class _SlidePickerState extends State<SlidePicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);
  final TextEditingController _hexController = TextEditingController();

  void _syncHexFromColor() {
    final hex = currentHsvColor.toColor().toHex();
    if (_hexController.text.toUpperCase() != hex.toUpperCase()) {
      _hexController.value = _hexController.value.copyWith(
        text: hex,
        selection: TextSelection.collapsed(offset: hex.length),
        composing: TextRange.empty,
      );
    }
  }

  void _applyHexInput(String input) {
    String v = input.trim();
    if (!v.startsWith('#')) v = '#$v';
    final reg = RegExp(kCompleteValidHexPattern);
    if (reg.hasMatch(v)) {
      final color = HexColor.fromHex(v);
      setState(() {
        currentHsvColor = HSVColor.fromColor(color);
      });
      widget.onColorChanged(color);
    }
  }

  @override
  void initState() {
    super.initState();
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
    _syncHexFromColor();
  }

  @override
  void didUpdateWidget(SlidePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
    _syncHexFromColor();
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Widget colorPickerSlider(TrackType trackType) {
    return ColorPickerSlider(
      trackType,
      currentHsvColor,
      small: false,
      (HSVColor color) {
        setState(() => currentHsvColor = color);
        widget.onColorChanged(currentHsvColor.toColor());
        _syncHexFromColor();
      },
    );
  }

  String getColorParams(int pos) {
    assert(pos >= 0 && pos < 4);
    if (widget.colorModel == ColorModel.rgb) {
      final Color color = currentHsvColor.toColor();
      return [
        color.red.toString(),
        color.green.toString(),
        color.blue.toString(),
        '${((color.alpha / 255.0) * 100).round()}',
      ][pos];
    } else if (widget.colorModel == ColorModel.hsv) {
      return [
        currentHsvColor.hue.round().toString(),
        (currentHsvColor.saturation * 100).round().toString(),
        (currentHsvColor.value * 100).round().toString(),
        (currentHsvColor.alpha * 100).round().toString(),
      ][pos];
    } else if (widget.colorModel == ColorModel.hsl) {
      HSLColor hslColor = hsvToHsl(currentHsvColor);
      return [
        hslColor.hue.round().toString(),
        (hslColor.saturation * 100).round().toString(),
        (hslColor.lightness * 100).round().toString(),
        (currentHsvColor.alpha * 100).round().toString(),
      ][pos];
    } else {
      return '??';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<TrackType> trackTypes = [
      if (widget.colorModel == ColorModel.hsv) ...[
        TrackType.hue,
        TrackType.saturation,
        TrackType.value
      ],
      if (widget.colorModel == ColorModel.hsl) ...[
        TrackType.hue,
        TrackType.saturationForHSL,
        TrackType.lightness
      ],
      if (widget.colorModel == ColorModel.rgb) ...[
        TrackType.red,
        TrackType.green,
        TrackType.blue
      ],
    ];
    List<SizedBox> sliders = [
      for (TrackType trackType in trackTypes)
        SizedBox(
          height: 82,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
                child: Text(
                  IcpStrings.of(context)
                      .trackLabel(trackType.toString().split('.').last),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 13,
                      color: onBackgroundOf(context).withAlpha(153)),
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: colorPickerSlider(trackType)),
                    Container(
                      height: 36,
                      width: 77,
                      margin: const EdgeInsets.only(left: 28),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: valueColorOf(context),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                      child: Text(
                        getColorParams(trackTypes.indexOf(trackType)),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 16,
                            letterSpacing: 0.6,
                            color: onBackgroundOf(context),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.showIndicator) const SizedBox(height: 20),
          ...sliders,
          const SizedBox(height: 16.0),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3.0, right: 8.0),
                  child: Text(
                    IcpStrings.of(context).displayP3Hex,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: const Color(0xff007AFF)),
                  ),
                ),
                SizedBox(
                  height: 42,
                  width: 100,
                  child: TextField(
                    controller: _hexController,
                    maxLines: 1,
                    maxLength: 8,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                    ],
                    textAlign: TextAlign.center,
                    onSubmitted: _applyHexInput,
                    onChanged: (t) {
                      // 仅在输入达到 6 或 8 位时尝试解析
                      if (t.length == 6 || t.length == 8) {
                        _applyHexInput(t);
                      }
                    },
                    textInputAction: TextInputAction.done,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 16,
                          letterSpacing: 1,
                          color: onBackgroundOf(context),
                          fontWeight: FontWeight.w600,
                        ),
                    decoration: InputDecoration(
                      counterText: '',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: valueColorOf(context),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'RRGGBB',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 23.0),
        ],
      ),
    );
  }
}
