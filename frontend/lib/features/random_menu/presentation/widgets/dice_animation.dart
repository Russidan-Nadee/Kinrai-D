import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DiceAnimation extends StatelessWidget {
  final double size;

  const DiceAnimation({
    super.key,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          'assets/animations/dice.json',
          fit: BoxFit.contain,
          repeat: true,
          animate: true,
        ),
      ),
    );
  }
}
