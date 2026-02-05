import 'package:flutter/material.dart';

class FloatingActionMenu extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback onScrollToTop;

  const FloatingActionMenu({
    super.key,
    required this.scrollController,
    required this.onScrollToTop,
  });

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with TickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isVisible = false;

  // ---------------------------------------------------------------------------
  // Animation
  // ---------------------------------------------------------------------------

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _animationController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Scroll handling
  // ---------------------------------------------------------------------------

  void _onScroll() {
    final shouldShow = widget.scrollController.offset > 200;

    if (shouldShow != _isVisible) {
      setState(() => _isVisible = shouldShow);

      if (shouldShow) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                onPressed: widget.onScrollToTop,
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.keyboard_arrow_up),
              ),
            ),
          ),
        );
      },
    );
  }
}
