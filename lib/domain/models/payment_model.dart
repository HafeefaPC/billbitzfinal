class PaymentModel {
  final String receiverUpiId;
  final String receiverName;
  final String transactionRefId;
  final String transactionNote;
  final double amount;

  PaymentModel({
    required this.receiverUpiId,
    required this.receiverName,
    required this.transactionRefId,
    required this.transactionNote,
    required this.amount,
  });
}
