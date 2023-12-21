class TransactionModel {

  final String blockNumber;
  final String transactionHash;
  final String value;
  final String to;
  final String? from;
  final String? timestamp;

  TransactionModel({
    required this.blockNumber,
    required this.transactionHash,
    required this.value,
    required this.to,
    this.from,
    this.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      blockNumber: json['blockNumber'],
      transactionHash: json['hash'],
      value: json['value'],
      to: json['to'],
      from: json['from'],
      timestamp: json['timeStamp'],
    );
  }
}