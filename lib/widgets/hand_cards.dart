import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../client_manager.dart';
import '../model/card_game.dart';
import 'card_widget.dart';

class HandCards extends StatefulWidget {
  const HandCards({super.key});

  @override
  State<HandCards> createState() => _HandCardsBarState();
}

class _HandCardsBarState extends State<HandCards> {
  // Card lifted under the finger or pointer
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    // Rebuilds only when the hand changes (the list is replaced, never mutated)
    return Selector<ClientManager, List<CardGame>>(
      selector: (context, clientManager) =>
      clientManager.mySelfPlayer?.handCards ?? [],

      builder: (context, handCards, child) {
        return Container(
          height: 150,
          color: Colors.grey.withValues(alpha: 0.1),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {

              final totalCards = handCards.length;

              if (totalCards == 0) {
                return const SizedBox.shrink();
              }

              const cardWidth = 60.0;
              const cardHeight = 91.0;

              // Kept free on both sides even when the hand is fully compressed
              const innerMargin = 8.0;

              final maxWidth = constraints.maxWidth;

              final playableWidth = maxWidth - (2 * innerMargin);

              final totalCardsWidthNoOverlap = (totalCards * cardWidth).toDouble();

              const minSpacing = 10.0;
              final totalCardsWidthWithSpacing =
                  totalCardsWidthNoOverlap + (totalCards - 1) * minSpacing;

              double overlap;
              double startX;

              if (totalCardsWidthWithSpacing <= playableWidth) {
                // Room to spare: space the cards out (negative overlap) and centre them
                overlap = -minSpacing;
                final totalHandWidth = totalCardsWidthWithSpacing;
                startX = (maxWidth - totalHandWidth) / 2;
              } else if (totalCardsWidthNoOverlap <= playableWidth) {
                // They fit edge to edge
                overlap = 0.0;
                final totalHandWidth = totalCardsWidthNoOverlap;
                startX = (maxWidth - totalHandWidth) / 2;
              } else {
                // Too many cards: overlap them just enough to fit
                overlap =
                    (totalCardsWidthNoOverlap - playableWidth) / (totalCards - 1);

                // Always leave 20px of each card visible
                const maxOverlap = cardWidth - 20.0;
                if (overlap > maxOverlap) {
                  overlap = maxOverlap;
                }

                final totalHandWidth =
                    totalCards * cardWidth - (totalCards - 1) * overlap;
                startX = (maxWidth - totalHandWidth) / 2;
              }

              // Distance between the left edges of neighbouring cards
              final double cardSpacing = cardWidth - overlap;

              // Lifts the card under the pointer
              void handleTouch(Offset localPosition) {
                final index =
                ((localPosition.dx - startX) / cardSpacing).floor();

                int? newHoveredIndex;
                if (index >= 0 && index < totalCards) {
                  if (localPosition.dy > (150 - cardHeight - 20)) {
                    newHoveredIndex = index;
                  }
                }

                if (newHoveredIndex != _hoveredIndex) {
                  setState(() => _hoveredIndex = newHoveredIndex);
                }
              }

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: (details) => handleTouch(details.localPosition),
                onPanUpdate: (details) => handleTouch(details.localPosition),
                onPanEnd: (_) => setState(() => _hoveredIndex = null),
                onTapDown: (details) =>
                    handleTouch(details.localPosition),
                onTapUp: (_) => setState(() => _hoveredIndex = null),
                child: Stack(
                  clipBehavior: Clip.none, // lifted cards may overflow
                  children: List.generate(totalCards, (index) {
                    final isHovered = _hoveredIndex == index;
                    final leftPosition = startX + (index * cardSpacing);

                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      left: leftPosition,
                      bottom: isHovered ? 40.0 : 20.0,
                      child: AnimatedScale(
                        scale: isHovered ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        child: LongPressDraggable<CardGame>(
                          data: handCards[index],
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: cardWidth,
                              height: cardHeight,
                              child: CardWidget(card: handCards[index]),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: SizedBox(
                              width: cardWidth,
                              height: cardHeight,
                              child: CardWidget(card: handCards[index]),
                            ),
                          ),
                          child: SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: CardWidget(card: handCards[index]),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

