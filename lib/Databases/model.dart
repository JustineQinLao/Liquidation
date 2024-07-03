class Liquidation {
  final int id;
  final String event;
  final double fund;

  Liquidation({
    required this.id,
    required this.event,
    required this.fund,
  }
  );
  

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'event': event,
      'fund': fund,
    };
  }

  @override
  String toString() {
    return 'Liquidation{id: $id, event: $event, fund: $fund}';
  }
}


class TransactionDetails {
  final int id;
  final String date;
  final String payee;
  final String or_si;
  final String particulars;
  final double amount;
  final int transactionId;
   final String image;

  TransactionDetails({
    required this.id,
    required this.date,
    required this.payee,
    required this.or_si,
    required this.particulars,
    required this.amount,
    
    required this.transactionId,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'payee': payee,
      'or_si': or_si,
      'particulars': particulars,
      'amount': amount,
      'transactionId': transactionId,
      'image': image,
    };
  }
}
