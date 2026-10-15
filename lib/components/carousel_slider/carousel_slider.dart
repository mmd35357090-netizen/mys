import 'dart:async';
import 'package:flutter/material.dart';

class WKCarouselSlider extends StatefulWidget {
  final List<Widget> items;
  final double viewportFraction;
  final int initialPage;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Duration autoPlayAnimationDuration;
  final bool enableInfiniteScroll;
  final bool enlargeCenterPage;
  final ValueChanged<int>? onPageChanged;
  final double? height;
  final WKCarouselSliderController? controller;

  const WKCarouselSlider({
    super.key,
    required this.items,
    this.viewportFraction = 0.8,
    this.initialPage = 0,
    this.height,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 300),
    this.enableInfiniteScroll = true,
    this.enlargeCenterPage = false,
    this.onPageChanged,
    this.controller,
  });

  @override
  State<WKCarouselSlider> createState() => _WKCarouselSliderState();
}

class _WKCarouselSliderState extends State<WKCarouselSlider> {
  Timer? _autoPlayTimer;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: widget.initialPage,
    );
    _currentIndex = widget.initialPage;
    widget.controller?._attach(_pageController);
    if (widget.autoPlay) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _startAutoPlay());
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index % widget.items.length;
    });
    widget.onPageChanged!(_currentIndex);
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    if (widget.items.length > 1) {
      _stopAutoPlay();
      _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
        if (_pageController.hasClients) {
          final nextPage = _currentIndex + 1;
          if (nextPage >= widget.items.length) {
            _pageController.jumpToPage(0);
            _currentIndex = 0;
          } else {
            _pageController.animateToPage(
              nextPage,
              duration: widget.autoPlayAnimationDuration,
              curve: Curves.easeInOut,
            );
            _currentIndex = nextPage;
          }
        }
      });
    }
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  double _getScale(int index) {
    if (!widget.enlargeCenterPage) return 1.0;
    final page = _pageController.position.hasContentDimensions
        ? _pageController.page ?? 0
        : 0;
    final distance = (page - index).abs();
    return 1 - (0.2 * distance).clamp(0.0, 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged:
            widget.onPageChanged == null ? null : _onPageChanged,
        itemCount:
            widget.enableInfiniteScroll ? null : widget.items.length,
        itemBuilder: (context, index) {
          final actualIndex = index % widget.items.length;
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) => Transform.scale(
              scale: _getScale(index),
              child: Center(
                child: widget.items[actualIndex],
              ),
            ),
          );
        },
      ),
    );
  }
}

class WKCarouselSliderController {
  late PageController _pageController;

  void _attach(PageController controller) {
    _pageController = controller;
  }

  void animateToPage(int page,
      {Duration duration = const Duration(milliseconds: 300),
      Curve curve = Curves.easeInOut}) {
    _pageController.animateToPage(page, duration: duration, curve: curve);
  }
}
