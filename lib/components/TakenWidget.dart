import 'package:flutter/material.dart';

class TakenWidget extends StatefulWidget {

  const TakenWidget({Key? key}) : super(key: key);

  @override
  _BetWidgetState createState() => _BetWidgetState();
}

class _BetWidgetState extends State<TakenWidget> {
  int betValue = 1;  // Valore iniziale della scommessa

  // Funzione per modificare il valore della scommessa (potrebbe essere chiamata in risposta a eventi come il tap)
  void _changeBetValue() {
    setState(() {
      betValue++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Cambia il valore della scommessa quando l'utente tocca il widget
        _changeBetValue();  // Esempio di cambio valore (puoi modificarlo come preferisci)
      },
      child: Container(
        width: 109,
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFF2B2E4A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              betValue.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}