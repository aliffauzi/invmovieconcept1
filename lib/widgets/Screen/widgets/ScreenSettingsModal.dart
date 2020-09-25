import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:invmovieconcept1/configs/AppDimensions.dart';
import 'package:provider/provider.dart';

import 'package:invmovieconcept1/Utils.dart';
import 'package:invmovieconcept1/UI.dart';

import 'ScreenSettingsModalBody.dart';
import '../ScreenStateProvider.dart';

class ScreenSettingsModal extends StatefulWidget {
  ScreenSettingsModal(Key key) : super(key: key);

  @override
  ScreenSettingsModalState createState() => ScreenSettingsModalState();
}

class ScreenSettingsModalState extends State<ScreenSettingsModal>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    this.controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    Future.delayed(Duration.zero, () {
      this.controller.addListener(() {
        final state = Provider.of<ScreenStateProvider>(context, listen: false);
        state.offset = this.animation.value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    this.controller.dispose();
    super.dispose();
  }

  void runAnimation({double begin, double end}) {
    this.animation = this.controller.drive(Tween(begin: begin, end: end));
    this.controller.reset();
    this.controller.duration = Duration(milliseconds: 400);
    this.controller.forward();
  }

  void openModal() {
    final state = Provider.of<ScreenStateProvider>(context, listen: false);
    this.runAnimation(begin: state.offset, end: 0.0);
  }

  void onVerticalDragStart(
    DragStartDetails event,
    ScreenStateProvider state,
  ) {
    state.startOffset = state.offset;
  }

  void onVerticalDragUpdate(
    DragUpdateDetails event,
    ScreenStateProvider state,
  ) {
    state.offset = (state.offset + event.delta.dy).clamp(0.0, state.baseOffset);
  }

  void onVerticalDragEnd(
    DragEndDetails event,
    ScreenStateProvider state,
  ) {
    final threshold = (UI.height * 0.15).clamp(60.0, 260.0);
    final thresholdCheck = state.baseOffset - threshold;
    double newOffset;

    if (state.startOffset == state.baseOffset) {
      newOffset = thresholdCheck > state.offset ? 0 : state.baseOffset;
    } else {
      newOffset = state.offset < threshold ? 0 : state.baseOffset;
    }
    this.runAnimation(begin: state.offset, end: newOffset);
  }

  onDoubleTap(ScreenStateProvider state) {
    if (state.offset == 0.0) {
      this.runAnimation(begin: 0.0, end: state.baseOffset);
    } else if (state.offset == state.baseOffset) {
      this.runAnimation(begin: state.baseOffset, end: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ScreenStateProvider>(context, listen: true);
    final opacity = Utils.rangeMap(
      state.offset,
      0.0,
      state.baseOffset,
      1.4,
      0.0,
    ).clamp(0.0, 1.0);

    return Positioned(
      // Disable
      top: state.offset,
      left: 0,
      right: 0,
      // top: UI.height,
      child: GestureDetector(
        onDoubleTap: () => this.onDoubleTap(
          state,
        ),
        onVerticalDragEnd: (obj) => this.onVerticalDragEnd(
          obj,
          state,
        ),
        onVerticalDragStart: (obj) => this.onVerticalDragStart(
          obj,
          state,
        ),
        onVerticalDragUpdate: (obj) => this.onVerticalDragUpdate(
          obj,
          state,
        ),
        child: NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (SizeChangedLayoutNotification notification) {
            state.onLayoutChange();
            return true;
          },
          child: WillPopScope(
            onWillPop: () async {
              final isClosed = state.startOffset == state.baseOffset;
              if (!isClosed) {
                this.runAnimation(
                  begin: state.offset,
                  end: state.baseOffset,
                );
              }
              return isClosed;
            },
            child: SizeChangedLayoutNotifier(
              child: ClipRect(
                child: Container(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: 15,
                      sigmaY: 15,
                    ),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        alignment: Alignment.topCenter,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .color
                            .withOpacity(0.10),
                        child: Container(
                          height: UI.height,
                          width: AppDimensions.containerWidth,
                          child: ScreenSettingsModalBody(
                            runAnimation: this.runAnimation,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
