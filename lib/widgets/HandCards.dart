import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ClientManager.dart';
import '../model/CardGame.dart';
import 'CardWidget.dart';
// Assicurati di importare le definizioni di CardGame e CardWidget
// import '...';

class HandCards extends StatefulWidget {
  // 1. Rimuovi clientManager dal costruttore.
  // Lo prenderemo dal 'Provider'
  const HandCards({Key? key}) : super(key: key);

  @override
  State<HandCards> createState() => _HandCardsBarState();
}

class _HandCardsBarState extends State<HandCards> {
  // Stato locale per la carta "sollevata" (hover)
  // Questo è corretto, perché è uno stato della UI, non uno stato globale.
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    // 2. USA UN 'SELECTOR' PER ASCOLTARE SOLO LA MANO
    // Questo widget si ricostruirà SOLO se la lista di carte cambia.
    return Selector<ClientManager, List<CardGame>>(
      // 3. IL 'SELECTOR'
      // Seleziona esattamente il dato che ci interessa.
      // Usiamo 'mySelfPlayer?.handCards' come da tua logica
      selector: (context, clientManager) =>
      clientManager.mySelfPlayer?.handCards ?? [],

      // 4. IL 'BUILDER'
      // Riceve 'handCards' (la lista) direttamente.
      builder: (context, handCards, child) {
        // 5. ORA INSERIAMO TUTTA LA TUA LOGICA DI LAYOUT
        return Container(
          height: 150, // Altezza della barra della mano
          color: Colors.grey.withOpacity(0.1),
          // Il padding del Container definisce il margine *esterno* principale.
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {

              // 6. LA MODIFICA CHIAVE:
              // Non usiamo 'widget.clientManager', usiamo la variabile
              // 'handCards' fornita dal builder del Selector.
              final totalCards = handCards.length;

              if (totalCards == 0) {
                return const SizedBox.shrink(); // Nessuna carta, non mostrare nulla
              }

              // --- Inizio Logica di Posizionamento Migliorata ---
              // (Questa è la tua logica, è corretta e la manteniamo)

              const cardWidth = 60.0;
              const cardHeight = 91.0; // Assumiamo un'altezza per il drag feedback

              // Definiamo un margine *interno* minimo da rispettare,
              // anche quando le carte sono al massimo della compressione.
              const innerMargin = 8.0;

              // Larghezza massima disponibile dal LayoutBuilder (già tolto il padding del Container)
              final maxWidth = constraints.maxWidth;

              // Larghezza "giocabile" (dove le carte possono essere posizionate)
              final playableWidth = maxWidth - (2 * innerMargin);

              // Larghezza totale se le carte non avessero overlap
              final totalCardsWidthNoOverlap = (totalCards * cardWidth).toDouble();

              // Spaziatura minima desiderata tra le carte quando c'è spazio
              const minSpacing = 10.0;
              final totalCardsWidthWithSpacing =
                  totalCardsWidthNoOverlap + (totalCards - 1) * minSpacing;

              double overlap;
              double startX;

              if (totalCardsWidthWithSpacing <= playableWidth) {
                // CASO 1: Le carte si adattano comodamente con spaziatura.
                // Usiamo un overlap "negativo" (spaziatura) e centriamo il blocco.
                overlap = -minSpacing;
                final totalHandWidth = totalCardsWidthWithSpacing;
                startX = (maxWidth - totalHandWidth) / 2;
              } else if (totalCardsWidthNoOverlap <= playableWidth) {
                // CASO 2: Le carte si adattano, ma senza spaziatura.
                // Usiamo overlap 0 e centriamo il blocco.
                overlap = 0.0;
                final totalHandWidth = totalCardsWidthNoOverlap;
                startX = (maxWidth - totalHandWidth) / 2;
              } else {
                // CASO 3: Le carte non si adattano. Dobbiamo sovrapporle.
                // Calcoliamo l'overlap necessario per riempire la 'playableWidth'.
                overlap =
                    (totalCardsWidthNoOverlap - playableWidth) / (totalCards - 1);

                // Impediamo che le carte si sovrappongano completamente (lasciamo 20px visibili)
                final maxOverlap = cardWidth - 20.0;
                if (overlap > maxOverlap) {
                  overlap = maxOverlap;
                }

                // Ricalcoliamo la larghezza totale CON l'overlap e centriamo il blocco.
                // Questo assicura che anche se 100 carte sono compresse,
                // il blocco risultante sia centrato.
                final totalHandWidth =
                    totalCards * cardWidth - (totalCards - 1) * overlap;
                startX = (maxWidth - totalHandWidth) / 2;
              }

              // La distanza tra l'inizio di una carta e l'inizio della successiva
              final double cardSpacing = cardWidth - overlap;

              // --- Fine Logica di Posizionamento ---

              // Gestore per l'effetto "hover" (sollevamento)
              // Questa logica è corretta e usa 'setState' per
              // aggiornare lo stato locale '_hoveredIndex'.
              void handleTouch(Offset localPosition) {
                // Calcola l'indice in base alla posizione e allo spazio tra le carte
                final index =
                ((localPosition.dx - startX) / cardSpacing).floor();

                int? newHoveredIndex;
                if (index >= 0 && index < totalCards) {
                  // Controlla anche l'asse Y per un'attivazione più precisa
                  if (localPosition.dy > (150 - cardHeight - 20)) {
                    // 20 è il 'bottom'
                    newHoveredIndex = index;
                  }
                }

                if (newHoveredIndex != _hoveredIndex) {
                  setState(() => _hoveredIndex = newHoveredIndex);
                }
              }

              return GestureDetector(
                behavior: HitTestBehavior.translucent, // Cattura eventi sull'intera area
                onPanDown: (details) => handleTouch(details.localPosition),
                onPanUpdate: (details) => handleTouch(details.localPosition),
                onPanEnd: (_) => setState(() => _hoveredIndex = null),
                onTapDown: (details) =>
                    handleTouch(details.localPosition), // Per hover su desktop/tap
                onTapUp: (_) => setState(() => _hoveredIndex = null),
                child: Stack(
                  clipBehavior: Clip.none, // Permette alle carte sollevate di uscire
                  children: List.generate(totalCards, (index) {
                    final isHovered = _hoveredIndex == index;
                    final leftPosition = startX + (index * cardSpacing);

                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      left: leftPosition,
                      bottom: isHovered ? 40.0 : 20.0, // Solleva la carta
                      child: AnimatedScale(
                        scale: isHovered ? 1.08 : 1.0, // Ingrandisce la carta
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        child: LongPressDraggable<CardGame>(
                          data: handCards[index], // Usa la lista dal Selector
                          // Feedback: L'aspetto della carta durante il drag
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: cardWidth,
                              height: cardHeight, // Usa altezza definita
                              child: CardWidget(card: handCards[index]),
                            ),
                          ),
                          // ChildWhenDragging: L'aspetto del "buco" lasciato
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: SizedBox(
                              width: cardWidth,
                              height: cardHeight,
                              child: CardWidget(card: handCards[index]),
                            ),
                          ),
                          // Child: L'aspetto normale della carta
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

