import 'package:flutter/material.dart';

class SetResultAnimation extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isWin; // True = Vittoria, False = Sconfitta
  final String? customText; // Opzionale

  const SetResultAnimation({
    super.key,
    required this.onComplete,
    required this.isWin,
    this.customText,
  });

  @override
  State<SetResultAnimation> createState() => _SetResultAnimationState();
}

class _SetResultAnimationState extends State<SetResultAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Durata leggermente diversa per dare feedback diversi
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.isWin ? 1500 : 1800),
      vsync: this,
    );

    // 1. Effetto Rimbalzo all'apparizione (più "pesante" se si perde)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: widget.isWin ? Curves.elasticOut : Curves.bounceOut),
      ),
    );

    // 2. Movimento: UP per la vittoria, DOWN per la sconfitta
    final targetOffset = widget.isWin ? const Offset(0, -2.0) : const Offset(0, 2.0);

    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: targetOffset).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuad),
      ),
    );

    // 3. Dissolvenza alla fine
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Configurazione stile basata su vittoria/sconfitta
    final color = widget.isWin ? Colors.amber : Colors.redAccent;
    final iconData = widget.isWin ? Icons.star_rounded : Icons.cancel_presentation_rounded; // o Icons.sentiment_very_dissatisfied
    final defaultText = widget.isWin ? "WON!" : "LOST...";
    final textToShow = widget.customText ?? defaultText;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconData, color: color, size: 50),
              Text(
                textToShow,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                  shadows: const [
                    Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(0, 2))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}