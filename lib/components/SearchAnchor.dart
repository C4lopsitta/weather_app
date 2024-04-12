// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

//region definitions

const int _kOpenViewMilliseconds = 600;
const Duration _kOpenViewDuration = Duration(milliseconds: _kOpenViewMilliseconds);
const Duration _kAnchorFadeDuration = Duration(milliseconds: 150);
const Curve _kViewFadeOnInterval = Interval(0.0, 1/2);
const Curve _kViewIconsFadeOnInterval = Interval(1/6, 2/6);
const Curve _kViewDividerFadeOnInterval = Interval(0.0, 1/6);
const Curve _kViewListFadeOnInterval = Interval(133 / _kOpenViewMilliseconds, 233 / _kOpenViewMilliseconds);

/// Signature for a function that creates a [Widget] which is used to open a search view.
///
/// The `controller` callback provided to [ExposedSearchAnchor.builder] can be used
/// to open the search view and control the editable field on the view.
typedef SearchAnchorChildBuilder = Widget Function(BuildContext context, SearchController controller);

//endregion definitions

//region searchanchor

/// Manages a "search view" route that allows the user to select one of the
/// suggested completions for a search query.
///
/// The search view's route can either be shown by creating a [SearchController]
/// and then calling [SearchController.openView] or by tapping on an anchor.
/// When the anchor is tapped or [SearchController.openView] is called, the search view either
/// grows to a specific size, or grows to fill the entire screen. By default,
/// the search view only shows full screen on mobile platforms. Use [ExposedSearchAnchor.isFullScreen]
/// to override the default setting.
///
/// The search view is usually opened by a [SearchBar], an [IconButton] or an [Icon].
/// If [builder] returns an Icon, or any un-tappable widgets, we don't have
/// to explicitly call [SearchController.openView].
///
/// The search view route will be popped if the window size is changed and the
/// search view route is not in full-screen mode. However, if the search view route
/// is in full-screen mode, changing the window size, such as rotating a mobile
/// device from portrait mode to landscape mode, will not close the search view.
///
/// {@tool dartpad}
/// This example shows how to use an IconButton to open a search view in a [ExposedSearchAnchor].
/// It also shows how to use [SearchController] to open or close the search view route.
///
/// ** See code in examples/api/lib/material/search_anchor/search_anchor.2.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This example shows how to set up a floating (or pinned) AppBar with a
/// [ExposedSearchAnchor] for a title.
///
/// ** See code in examples/api/lib/material/search_anchor/search_anchor.1.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This example shows how to fetch the search suggestions from a remote API.
///
/// ** See code in examples/api/lib/material/search_anchor/search_anchor.3.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This example demonstrates fetching the search suggestions asynchronously and
/// debouncing network calls.
///
/// ** See code in examples/api/lib/material/search_anchor/search_anchor.4.dart **
/// {@end-tool}
///
/// See also:
///
/// * [SearchBar], a widget that defines a search bar.
/// * [SearchBarTheme], a widget that overrides the default configuration of a search bar.
/// * [SearchViewTheme], a widget that overrides the default configuration of a search view.
class ExposedSearchAnchor extends StatefulWidget {
  /// Creates a const [ExposedSearchAnchor].
  ///
  /// The [builder] and [suggestionsBuilder] arguments are required.
  ExposedSearchAnchor({
    super.key,
    this.isFullScreen,
    this.searchController,
    // this.viewBuilder,
    this.viewLeading,
    this.viewTrailing,
    this.viewHintText,
    this.viewBackgroundColor,
    this.viewElevation,
    this.viewSurfaceTintColor,
    this.viewSide,
    this.viewShape,
    this.headerTextStyle,
    this.headerHintStyle,
    this.dividerColor,
    this.viewConstraints,
    this.textCapitalization,
    this.viewOnChanged,
    this.viewOnSubmitted,
    required this.builder,
    required this.suggestions,
    // required this.suggestionsBuilder,
    this.textInputAction,
    this.keyboardType,
  });

  final bool? isFullScreen;

  /// An optional controller that allows opening and closing of the search view from
  /// other widgets.
  ///
  /// If this is null, one internal search controller is created automatically
  /// and it is used to open the search view when the user taps on the anchor.
  final SearchController? searchController;

  /// Optional callback to obtain a widget to lay out the suggestion list of the
  /// search view.
  ///
  /// Default view uses a [ListView] with a vertical scroll direction.
  // final ViewBuilder? viewBuilder;

  /// An optional widget to display before the text input field when the search
  /// view is open.
  ///
  /// Typically the [viewLeading] widget is an [Icon] or an [IconButton].
  ///
  /// Defaults to a back button which pops the view.
  final Widget? viewLeading;

  /// An optional widget list to display after the text input field when the search
  /// view is open.
  ///
  /// Typically the [viewTrailing] widget list only has one or two widgets.
  ///
  /// Defaults to an icon button which clears the text in the input field.
  final Iterable<Widget>? viewTrailing;

  /// Text that is displayed when the search bar's input field is empty.
  final String? viewHintText;

  /// The search view's background fill color.
  ///
  /// If null, the value of [SearchViewThemeData.backgroundColor] will be used.
  /// If this is also null, then the default value is [ColorScheme.surface].
  final Color? viewBackgroundColor;

  /// The elevation of the search view's [Material].
  ///
  /// If null, the value of [SearchViewThemeData.elevation] will be used. If this
  /// is also null, then default value is 6.0.
  final double? viewElevation;

  /// The surface tint color of the search view's [Material].
  ///
  /// See [Material.surfaceTintColor] for more details.
  ///
  /// If null, the value of [SearchViewThemeData.surfaceTintColor] will be used.
  /// If this is also null, then the default value is [ColorScheme.surfaceTint].
  final Color? viewSurfaceTintColor;

  /// The color and weight of the search view's outline.
  ///
  /// This value is combined with [viewShape] to create a shape decorated
  /// with an outline. This will be ignored if the view is full-screen.
  ///
  /// If null, the value of [SearchViewThemeData.side] will be used. If this is
  /// also null, the search view doesn't have a side by default.
  final BorderSide? viewSide;

  /// The shape of the search view's underlying [Material].
  ///
  /// This shape is combined with [viewSide] to create a shape decorated
  /// with an outline.
  ///
  /// If null, the value of [SearchViewThemeData.shape] will be used.
  /// If this is also null, then the default value is a rectangle shape for full-screen
  /// mode and a [RoundedRectangleBorder] shape with a 28.0 radius otherwise.
  final OutlinedBorder? viewShape;

  /// The style to use for the text being edited on the search view.
  ///
  /// If null, defaults to the `bodyLarge` text style from the current [Theme].
  /// The default text color is [ColorScheme.onSurface].
  final TextStyle? headerTextStyle;

  /// The style to use for the [viewHintText] on the search view.
  ///
  /// If null, the value of [SearchViewThemeData.headerHintStyle] will be used.
  /// If this is also null, the value of [headerTextStyle] will be used. If this is also null,
  /// defaults to the `bodyLarge` text style from the current [Theme]. The default
  /// text color is [ColorScheme.onSurfaceVariant].
  final TextStyle? headerHintStyle;

  /// The color of the divider on the search view.
  ///
  /// If this property is null, then [SearchViewThemeData.dividerColor] is used.
  /// If that is also null, the default value is [ColorScheme.outline].
  final Color? dividerColor;

  /// Optional size constraints for the search view.
  ///
  /// By default, the search view has the same width as the anchor and is 2/3
  /// the height of the screen. If the width and height of the view are within
  /// the [viewConstraints], the view will show its default size. Otherwise,
  /// the size of the view will be constrained by this property.
  ///
  /// If null, the value of [SearchViewThemeData.constraints] will be used. If
  /// this is also null, then the constraints defaults to:
  /// ```dart
  /// const BoxConstraints(minWidth: 360.0, minHeight: 240.0)
  /// ```
  final BoxConstraints? viewConstraints;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization? textCapitalization;

  /// Called each time the user modifies the search view's text field.
  ///
  /// See also:
  ///
  ///  * [viewOnSubmitted], which is called when the user indicates that they
  ///  are done editing the search view's text field.
  final ValueChanged<String>? viewOnChanged;

  /// Called when the user indicates that they are done editing the text in the
  /// text field of a search view. Typically this is called when the user presses
  /// the enter key.
  ///
  /// See also:
  ///
  /// * [viewOnChanged], which is called when the user modifies the text field
  /// of the search view.
  final ValueChanged<String>? viewOnSubmitted;

  /// Called to create a widget which can open a search view route when it is tapped.
  ///
  /// The widget returned by this builder is faded out when it is tapped.
  /// At the same time a search view route is faded in.
  final SearchAnchorChildBuilder builder;

  /// Called to get the suggestion list for the search view.
  ///
  /// By default, the list returned by this builder is laid out in a [ListView].
  /// To get a different layout, use [viewBuilder] to override.
  // final SuggestionsBuilder suggestionsBuilder;

  Widget suggestions;

  /// {@macro flutter.widgets.TextField.textInputAction}
  final TextInputAction? textInputAction;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to the default value specified in [TextField].
  final TextInputType? keyboardType;

  @override
  State<ExposedSearchAnchor> createState() => _ExposedSearchAnchorState();
}

class _ExposedSearchAnchorState extends State<ExposedSearchAnchor> {
  Size? _screenSize;
  bool _anchorIsVisible = true;
  final GlobalKey _anchorKey = GlobalKey();
  bool get _viewIsOpen => !_anchorIsVisible;
  SearchController? _internalSearchController;
  SearchController get _searchController => widget.searchController ?? (_internalSearchController ??= SearchController());

  @override
  void initState() {
    super.initState();
    _searchController._attach(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Size updatedScreenSize = MediaQuery.of(context).size;
    if (_screenSize != null && _screenSize != updatedScreenSize) {
      if (_searchController.isOpen && !getShowFullScreenView()) {
        _closeView(null);
      }
    }
    _screenSize = updatedScreenSize;
  }

  @override
  void didUpdateWidget(ExposedSearchAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchController != widget.searchController) {
      oldWidget.searchController?._detach(this);
      _searchController._attach(this);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.searchController?._detach(this);
    _internalSearchController?._detach(this);
    _internalSearchController?.dispose();
  }

  void _openView() {
    final NavigatorState navigator = Navigator.of(context);
    navigator.push(_SearchViewRoute(
      viewOnChanged: widget.viewOnChanged,
      viewOnSubmitted: widget.viewOnSubmitted,
      viewLeading: widget.viewLeading,
      viewTrailing: widget.viewTrailing,
      viewHintText: widget.viewHintText,
      viewBackgroundColor: widget.viewBackgroundColor,
      viewElevation: widget.viewElevation,
      viewSurfaceTintColor: widget.viewSurfaceTintColor,
      viewSide: widget.viewSide,
      viewShape: widget.viewShape,
      viewHeaderTextStyle: widget.headerTextStyle,
      viewHeaderHintStyle: widget.headerHintStyle,
      dividerColor: widget.dividerColor,
      viewConstraints: widget.viewConstraints,
      showFullScreenView: getShowFullScreenView(),
      toggleVisibility: toggleVisibility,
      textDirection: Directionality.of(context),
      anchorKey: _anchorKey,
      searchController: _searchController,
      suggestions: widget.suggestions,
      textCapitalization: widget.textCapitalization,
      capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
    ));
  }

  void _closeView(String? selectedText) {
    if (selectedText != null) {
      _searchController.text = selectedText;
    }
    Navigator.of(context).pop();
  }

  bool toggleVisibility() {
    setState(() {
      _anchorIsVisible = !_anchorIsVisible;
    });
    return _anchorIsVisible;
  }

  bool getShowFullScreenView() {
    if (widget.isFullScreen != null) {
      return widget.isFullScreen!;
    }

    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return true;
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      key: _anchorKey,
      opacity: _anchorIsVisible ? 1.0 : 0.0,
      duration: _kAnchorFadeDuration,
      child: GestureDetector(
        onTap: _openView,
        child: widget.builder(context, _searchController),
      ),
    );
  }
}

//endregion searchanchor

//region searchroute

class _SearchViewRoute extends PopupRoute<_SearchViewRoute> {
  _SearchViewRoute({
    this.viewOnChanged,
    this.viewOnSubmitted,
    this.toggleVisibility,
    this.textDirection,
    this.viewLeading,
    this.viewTrailing,
    this.viewHintText,
    this.viewBackgroundColor,
    this.viewElevation,
    this.viewSurfaceTintColor,
    this.viewSide,
    this.viewShape,
    this.viewHeaderTextStyle,
    this.viewHeaderHintStyle,
    this.dividerColor,
    this.viewConstraints,
    this.textCapitalization,
    required this.showFullScreenView,
    required this.anchorKey,
    required this.searchController,
    required this.suggestions,
    required this.capturedThemes,
    this.textInputAction,
    this.keyboardType,
  });

  final ValueChanged<String>? viewOnChanged;
  final ValueChanged<String>? viewOnSubmitted;
  final ValueGetter<bool>? toggleVisibility;
  final TextDirection? textDirection;
  final Widget? viewLeading;
  final Iterable<Widget>? viewTrailing;
  final String? viewHintText;
  final Color? viewBackgroundColor;
  final double? viewElevation;
  final Color? viewSurfaceTintColor;
  final BorderSide? viewSide;
  final OutlinedBorder? viewShape;
  final TextStyle? viewHeaderTextStyle;
  final TextStyle? viewHeaderHintStyle;
  final Color? dividerColor;
  final BoxConstraints? viewConstraints;
  final TextCapitalization? textCapitalization;
  final bool showFullScreenView;
  final GlobalKey anchorKey;
  final SearchController searchController;
  Widget suggestions;
  final CapturedThemes capturedThemes;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  late final SearchViewThemeData viewDefaults;
  late final SearchViewThemeData viewTheme;
  final RectTween _rectTween = RectTween();

  Rect? getRect() {
    final BuildContext? context = anchorKey.currentContext;
    if (context != null) {
      final RenderBox searchBarBox = context.findRenderObject()! as RenderBox;
      final Size boxSize = searchBarBox.size;
      final NavigatorState navigator = Navigator.of(context);
      final Offset boxLocation = searchBarBox.localToGlobal(Offset.zero, ancestor: navigator.context.findRenderObject());
      return boxLocation & boxSize;
    }
    return null;
  }

  @override
  TickerFuture didPush() {
    assert(anchorKey.currentContext != null);
    updateViewConfig(anchorKey.currentContext!);
    updateTweens(anchorKey.currentContext!);
    toggleVisibility?.call();
    return super.didPush();
  }

  @override
  bool didPop(_SearchViewRoute? result) {
    assert(anchorKey.currentContext != null);
    updateTweens(anchorKey.currentContext!);
    toggleVisibility?.call();
    return super.didPop(result);
  }

  void updateViewConfig(BuildContext context) {
    viewDefaults = _SearchViewDefaultsM3(context, isFullScreen: showFullScreenView);
    viewTheme = SearchViewTheme.of(context);
  }

  void updateTweens(BuildContext context) {
    final RenderBox navigator = Navigator.of(context).context.findRenderObject()! as RenderBox;
    final Size screenSize = navigator.size;
    final Rect anchorRect = getRect() ?? Rect.zero;

    final BoxConstraints effectiveConstraints = viewConstraints ?? viewTheme.constraints ?? viewDefaults.constraints!;
    _rectTween.begin = anchorRect;

    final double viewWidth = clampDouble(anchorRect.width, effectiveConstraints.minWidth, effectiveConstraints.maxWidth);
    final double viewHeight = clampDouble(screenSize.height * 2 / 3, effectiveConstraints.minHeight, effectiveConstraints.maxHeight);

    switch (textDirection ?? TextDirection.ltr) {
      case TextDirection.ltr:
        final double viewLeftToScreenRight = screenSize.width - anchorRect.left;
        final double viewTopToScreenBottom = screenSize.height - anchorRect.top;

        // Make sure the search view doesn't go off the screen. If the search view
        // doesn't fit, move the top-left corner of the view to fit the window.
        // If the window is smaller than the view, then we resize the view to fit the window.
        Offset topLeft = anchorRect.topLeft;
        if (viewLeftToScreenRight < viewWidth) {
          topLeft = Offset(screenSize.width - math.min(viewWidth, screenSize.width), topLeft.dy);
        }
        if (viewTopToScreenBottom < viewHeight) {
          topLeft = Offset(topLeft.dx, screenSize.height - math.min(viewHeight, screenSize.height));
        }
        final Size endSize = Size(viewWidth, viewHeight);
        _rectTween.end = showFullScreenView ? Offset.zero & screenSize : (topLeft & endSize);
        return;
      case TextDirection.rtl:
        final double viewRightToScreenLeft = anchorRect.right;
        final double viewTopToScreenBottom = screenSize.height - anchorRect.top;

        // Make sure the search view doesn't go off the screen.
        Offset topLeft = Offset(math.max(anchorRect.right - viewWidth, 0.0), anchorRect.top);
        if (viewRightToScreenLeft < viewWidth) {
          topLeft = Offset(0.0, topLeft.dy);
        }
        if (viewTopToScreenBottom < viewHeight) {
          topLeft = Offset(topLeft.dx, screenSize.height - math.min(viewHeight, screenSize.height));
        }
        final Size endSize = Size(viewWidth, viewHeight);
        _rectTween.end = showFullScreenView ? Offset.zero & screenSize : (topLeft & endSize);
    }
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {

    return Directionality(
      textDirection: textDirection ?? TextDirection.ltr,
      child: AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final Animation<double> curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubicEmphasized,
              reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
            );

            final Rect viewRect = _rectTween.evaluate(curvedAnimation)!;
            final double topPadding = showFullScreenView
                ? lerpDouble(0.0, MediaQuery.paddingOf(context).top, curvedAnimation.value)!
                : 0.0;

            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: _kViewFadeOnInterval,
                reverseCurve: _kViewFadeOnInterval.flipped,
              ),
              child: capturedThemes.wrap(
                _ViewContent(
                  viewOnChanged: viewOnChanged,
                  viewOnSubmitted: viewOnSubmitted,
                  viewLeading: viewLeading,
                  viewTrailing: viewTrailing,
                  viewHintText: viewHintText,
                  viewBackgroundColor: viewBackgroundColor,
                  viewElevation: viewElevation,
                  viewSurfaceTintColor: viewSurfaceTintColor,
                  viewSide: viewSide,
                  viewShape: viewShape,
                  viewHeaderTextStyle: viewHeaderTextStyle,
                  viewHeaderHintStyle: viewHeaderHintStyle,
                  dividerColor: dividerColor,
                  showFullScreenView: showFullScreenView,
                  animation: curvedAnimation,
                  topPadding: topPadding,
                  viewMaxWidth: _rectTween.end!.width,
                  viewRect: viewRect,
                  searchController: searchController,

                  textCapitalization: textCapitalization,
                  textInputAction: textInputAction,
                  keyboardType: keyboardType,
                  suggestions: suggestions,
                ),
              ),
            );
          }
      ),
    );
  }

  @override
  Duration get transitionDuration => _kOpenViewDuration;
}

//endregion searchroute

//region viewcontent
class _ViewContent extends StatefulWidget {
  _ViewContent({
    this.viewOnChanged,
    this.viewOnSubmitted,
    this.viewLeading,
    this.viewTrailing,
    this.viewHintText,
    this.viewBackgroundColor,
    this.viewElevation,
    this.viewSurfaceTintColor,
    this.viewSide,
    this.viewShape,
    this.viewHeaderTextStyle,
    this.viewHeaderHintStyle,
    this.dividerColor,
    this.textCapitalization,
    required this.showFullScreenView,
    required this.topPadding,
    required this.animation,
    required this.viewMaxWidth,
    required this.viewRect,
    required this.searchController,
    required this.suggestions,
    this.textInputAction,
    this.keyboardType,
  });

  final ValueChanged<String>? viewOnChanged;
  final ValueChanged<String>? viewOnSubmitted;
  final Widget? viewLeading;
  final Iterable<Widget>? viewTrailing;
  final String? viewHintText;
  final Color? viewBackgroundColor;
  final double? viewElevation;
  final Color? viewSurfaceTintColor;
  final BorderSide? viewSide;
  final OutlinedBorder? viewShape;
  final TextStyle? viewHeaderTextStyle;
  final TextStyle? viewHeaderHintStyle;
  final Color? dividerColor;
  final TextCapitalization? textCapitalization;
  final bool showFullScreenView;
  final double topPadding;
  final Animation<double> animation;
  final double viewMaxWidth;
  final Rect viewRect;
  Widget suggestions;
  final SearchController searchController;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;

  @override
  State<_ViewContent> createState() => _ViewContentState();
}

class _ViewContentState extends State<_ViewContent> {
  Size? _screenSize;
  late Rect _viewRect;
  late final SearchController _controller;
  Iterable<Widget> result = <Widget>[];

  @override
  void initState() {
    super.initState();
    _viewRect = widget.viewRect;
    _controller = widget.searchController;
  }

  @override
  void didUpdateWidget(covariant _ViewContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewRect != oldWidget.viewRect) {
      setState(() {
        _viewRect = widget.viewRect;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Size updatedScreenSize = MediaQuery.of(context).size;

    if (_screenSize != updatedScreenSize) {
      _screenSize = updatedScreenSize;
      if (widget.showFullScreenView) {
        _viewRect = Offset.zero & _screenSize!;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget defaultLeading = IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () { Navigator.of(context).pop(); },
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );

    final List<Widget> defaultTrailing = <Widget>[
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          _controller.clear();
        },
      ),
    ];

    final SearchViewThemeData viewDefaults = _SearchViewDefaultsM3(context, isFullScreen: widget.showFullScreenView);
    final SearchViewThemeData viewTheme = SearchViewTheme.of(context);
    final DividerThemeData dividerTheme = DividerTheme.of(context);

    final Color effectiveBackgroundColor = widget.viewBackgroundColor
        ?? viewTheme.backgroundColor
        ?? viewDefaults.backgroundColor!;
    final Color effectiveSurfaceTint = widget.viewSurfaceTintColor
        ?? viewTheme.surfaceTintColor
        ?? viewDefaults.surfaceTintColor!;
    final double effectiveElevation = widget.viewElevation
        ?? viewTheme.elevation
        ?? viewDefaults.elevation!;
    final BorderSide? effectiveSide = widget.viewSide
        ?? viewTheme.side
        ?? viewDefaults.side;
    OutlinedBorder effectiveShape = widget.viewShape
        ?? viewTheme.shape
        ?? viewDefaults.shape!;
    if (effectiveSide != null) {
      effectiveShape = effectiveShape.copyWith(side: effectiveSide);
    }
    final Color effectiveDividerColor = widget.dividerColor
        ?? viewTheme.dividerColor
        ?? dividerTheme.color
        ?? viewDefaults.dividerColor!;
    final TextStyle? effectiveTextStyle = widget.viewHeaderTextStyle
        ?? viewTheme.headerTextStyle
        ?? viewDefaults.headerTextStyle;
    final TextStyle? effectiveHintStyle = widget.viewHeaderHintStyle
        ?? viewTheme.headerHintStyle
        ?? widget.viewHeaderTextStyle
        ?? viewTheme.headerTextStyle
        ?? viewDefaults.headerHintStyle;

    final Widget viewDivider = DividerTheme(
      data: dividerTheme.copyWith(color: effectiveDividerColor),
      child: const Divider(height: 1),
    );

    return Align(
      alignment: Alignment.topLeft,
      child: Transform.translate(
        offset: _viewRect.topLeft,
        child: SizedBox(
          width: _viewRect.width,
          height: _viewRect.height,
          child: Material(
            clipBehavior: Clip.antiAlias,
            shape: effectiveShape,
            color: effectiveBackgroundColor,
            surfaceTintColor: effectiveSurfaceTint,
            elevation: effectiveElevation,
            child: ClipRect(
              clipBehavior: Clip.antiAlias,
              child: OverflowBox(
                alignment: Alignment.topLeft,
                maxWidth: math.min(widget.viewMaxWidth, _screenSize!.width),
                minWidth: 0,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: widget.animation,
                    curve: _kViewIconsFadeOnInterval,
                    reverseCurve: _kViewIconsFadeOnInterval.flipped,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: widget.topPadding),
                        child: SafeArea(
                          top: false,
                          bottom: false,
                          child: SearchBar(
                            autoFocus: true,
                            constraints: widget.showFullScreenView ? BoxConstraints(minHeight: _SearchViewDefaultsM3.fullScreenBarHeight) : null,
                            leading: widget.viewLeading ?? defaultLeading,
                            trailing: widget.viewTrailing ?? defaultTrailing,
                            hintText: widget.viewHintText,
                            backgroundColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
                            overlayColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
                            elevation: const MaterialStatePropertyAll<double>(0.0),
                            textStyle: MaterialStatePropertyAll<TextStyle?>(effectiveTextStyle),
                            hintStyle: MaterialStatePropertyAll<TextStyle?>(effectiveHintStyle),
                            controller: _controller,
                            onChanged: (String value) {
                              widget.viewOnChanged?.call(value);
                            },
                            onSubmitted: widget.viewOnSubmitted,
                            textCapitalization: widget.textCapitalization,
                            textInputAction: widget.textInputAction,
                            keyboardType: widget.keyboardType,
                          ),
                        ),
                      ),
                      FadeTransition(
                          opacity: CurvedAnimation(
                            parent: widget.animation,
                            curve: _kViewDividerFadeOnInterval,
                            reverseCurve: _kViewFadeOnInterval.flipped,
                          ),
                          child: viewDivider),
                      Expanded(
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: widget.animation,
                            curve: _kViewListFadeOnInterval,
                            reverseCurve: _kViewListFadeOnInterval.flipped,
                          ),
                          child: widget.suggestions,
                        ),
                      ),
                    ],
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

//endregion viewcontent

//region searchanchor_bar


/// A controller to manage a search view created by [SearchAnchor].
///
/// A [SearchController] is used to control a menu after it has been created,
/// with methods such as [openView] and [closeView]. It can also control the text in the
/// input field.
///
/// See also:
///
/// * [SearchAnchor], a widget that defines a region that opens a search view.
/// * [TextEditingController], A controller for an editable text field.
class SearchController extends TextEditingController {
  // The anchor that this controller controls.
  //
  // This is set automatically when a [SearchController] is given to the anchor
  // it controls.
  _ExposedSearchAnchorState? _anchor;

  /// Whether this controller has associated search anchor.
  bool get isAttached => _anchor != null;

  /// Whether or not the associated search view is currently open.
  bool get isOpen {
    assert(isAttached);
    return _anchor!._viewIsOpen;
  }

  /// Opens the search view that this controller is associated with.
  void openView() {
    assert(isAttached);
    _anchor!._openView();
  }

  /// Close the search view that this search controller is associated with.
  ///
  /// If `selectedText` is given, then the text value of the controller is set to
  /// `selectedText`.
  void closeView(String? selectedText) {
    assert(isAttached);
    _anchor!._closeView(selectedText);
  }

  // ignore: use_setters_to_change_properties
  void _attach(_ExposedSearchAnchorState anchor) {
    _anchor = anchor;
  }

  void _detach(_ExposedSearchAnchorState anchor) {
    if (_anchor == anchor) {
      _anchor = null;
    }
  }
}

//endregion searchbar

//region defaults


// BEGIN GENERATED TOKEN PROPERTIES - SearchView

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

class _SearchViewDefaultsM3 extends SearchViewThemeData {
  _SearchViewDefaultsM3(this.context, {required this.isFullScreen});

  final BuildContext context;
  final bool isFullScreen;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  static double fullScreenBarHeight = 72.0;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  double? get elevation => 6.0;

  @override
  Color? get surfaceTintColor => _colors.surfaceTint;

  // No default side

  @override
  OutlinedBorder? get shape => isFullScreen
      ? const RoundedRectangleBorder()
      : const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28.0)));

  @override
  TextStyle? get headerTextStyle => _textTheme.bodyLarge?.copyWith(color: _colors.onSurface);

  @override
  TextStyle? get headerHintStyle => _textTheme.bodyLarge?.copyWith(color: _colors.onSurfaceVariant);

  @override
  BoxConstraints get constraints => const BoxConstraints(minWidth: 360.0, minHeight: 240.0);

  @override
  Color? get dividerColor => _colors.outline;
}

// END GENERATED TOKEN PROPERTIES - SearchView
//endregion

