import 'package:flutter/material.dart';
import 'package:ios_color_picker/l10n/strings.dart';
import 'package:ios_color_picker/custom_picker/pickers/slider_picker/slider_helper.dart';
import 'package:ios_color_picker/custom_picker/pickers_selector_row.dart';
import 'package:ios_color_picker/custom_picker/shared.dart';
import 'color_observer.dart';
import 'helpers/cache_helper.dart';
import 'history_colors.dart';

///Returns iOS Style color Picker
class IosColorPicker extends StatefulWidget {
  const IosColorPicker({
    super.key,
    required this.onColorSelected,
  });

  ///returns the selected color
  final ValueChanged<Color> onColorSelected;

  @override
  State<IosColorPicker> createState() => _IosColorPickerState();
}

class _IosColorPickerState extends State<IosColorPicker> {
  @override
  void initState() {
    CacheHelper.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: maxWidth(context),
            ),
          ),
        ),
        Container(
          width: maxWidth(context),
          height: 340 + componentsHeight(context),
          decoration: BoxDecoration(
            color: backgroundColorOf(context).withAlpha(250),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  8,
                  2,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 22,
                      ),
                      Expanded(
                        child: Text(
                          IcpStrings.of(context).titleColors,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontSize: 17,
                                  color: onBackgroundOf(context),
                                  fontWeight: FontWeight.w700),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Color(0xff3A3A3B)
                                  : Color.fromARGB(255, 236, 236, 236),
                              shape: BoxShape.circle),
                          child: Center(
                            child: Icon(
                              Icons.close_rounded,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Color(0xffA4A4AA)
                                  : Color.fromARGB(255, 159, 159, 165),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PickersSelectorRow(
                onColorChanged: widget.onColorSelected,
              ),

              ///ALL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17.0),
                child: Text(
                  IcpStrings.of(context).opacity,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 13,
                      color: onBackgroundOf(context).withAlpha(153)),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2),
                      child: SizedBox(
                        height: 36.0,
                        child: ValueListenableBuilder<Color>(
                          valueListenable: colorController,
                          builder: (context, color, child) {
                            return ColorPickerSlider(
                                TrackType.alpha, HSVColor.fromColor(color),
                                small: false, (v) {
                              colorController.updateOpacity(v.alpha);
                              widget.onColorSelected(colorController.value);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 36,
                    width: 77,
                    margin: const EdgeInsets.only(right: 16, left: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: valueColorOf(context),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: ValueListenableBuilder<Color>(
                      valueListenable: colorController,
                      builder: (context, color, child) {
                        int alpha = (color.opacity * 100).toInt();
                        return Text(
                          "$alpha%",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  fontSize: 16,
                                  letterSpacing: 0.6,
                                  color: onBackgroundOf(context),
                                  fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  )
                ],
              ),
              // const SizedBox(
              //   height: 44,
              // ),
              Divider(
                height: 44,
                thickness: 0.2,
                indent: 17,
                endIndent: 17,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 78,
                        width: 78,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        margin: const EdgeInsets.only(
                          left: 16,
                        ),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Transform.scale(
                          scale: 1.5,
                          child: Transform.rotate(
                            angle: 0.76,
                            child: Row(
                              children: [
                                Expanded(child: Container(color: Colors.white)),
                                Expanded(child: Container(color: Colors.black)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ValueListenableBuilder<Color>(
                        valueListenable: colorController,
                        builder: (context, color, child) {
                          return Container(
                            height: 78,
                            width: 78,
                            margin: const EdgeInsets.only(
                              left: 16,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: color),
                          );
                        },
                      ),
                    ],
                  ),
                  HistoryColors(
                    onColorChanged: widget.onColorSelected,
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
