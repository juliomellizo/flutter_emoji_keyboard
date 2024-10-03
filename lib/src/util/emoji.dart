class Emoji {
  int? id;
  late String emoji;
  late int amount;

  Emoji(this.emoji, this.amount, {this.id});

  void increase() {
    this.amount += 1;
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'emoji': emoji,
      'amount': amount,
    };
  }

  Emoji.fromDbMap(Map<String, dynamic> map) {
    id = map['id'] as int?;
    emoji = map['emoji'] as String;
    amount = map['amount'] as int;
  }
}
