class Loyalty {
  final String clientId;
  final int bonusEarned;
  final int bonusUsed;

  Loyalty({
    required this.clientId,
    required this.bonusEarned,
    required this.bonusUsed,
  });

  int get currentBalance => bonusEarned - bonusUsed;
}
