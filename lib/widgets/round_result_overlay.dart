import 'dart:async';

import 'package:flutter/material.dart';

/// Un widget overlay che mostra un'icona con un'animazione
/// di pop-up e dissolvenza, per poi scomparire da sola.
class RoundResultOverlay extends StatefulWidget {
  /// True per mostrare l'icona di vittoria (es. coppa),
  /// false per quella di sconfitta (es. X).
  final bool isWinner;

  /// Callback chiamata quando l'animazione è finita e
  /// l'overlay è pronto per essere rimosso.
  final VoidCallback onComplete;

  const RoundResultOverlay({
    super.key,
    required this.isWinner,
    required this.onComplete,
  });

  @override
  State<RoundResultOverlay> createState() => _RoundResultOverlayState();
}

class _RoundResultOverlayState extends State<RoundResultOverlay> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Avviamo l'animazione quasi subito
    Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _visible = true);
        // Avvia il timer per la scomparsa
        _startFadeOutTimer();
      }
    });
  }

  void _startFadeOutTimer() {
    // Attendi prima di far scomparire l'overlay
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _visible = false);
        // Attendi la fine dell'animazione di uscita prima
        // di notificare il completamento.
        Timer(const Duration(milliseconds: 300), () {
          if (mounted) {
            widget.onComplete();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determina icona e colore in base al risultato
    final IconData iconData = widget.isWinner ? Icons.emoji_events : Icons.close;
    final Color iconColor = widget.isWinner ? Colors.amber : Colors.red;

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Center(
          child: AnimatedScale(
            scale: _visible ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut, // Bell'effetto "elastico"
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border: Border.all(color: iconColor, width: 3),
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 80,
              ),
            ),
          ),
        ),
      ),
    );
  }
}