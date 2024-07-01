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