import 'dart:math';

String generateRandomCode(int length) {
  final rand = Random();
  return List.generate(length, (_) => rand.nextInt(10).toString()).join();
}
