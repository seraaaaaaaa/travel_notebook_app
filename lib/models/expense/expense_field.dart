class ExpenseField {
  static const String tableName = 'expenses';

  static const String expenseId = 'expense_id';
  static const String destinationId = 'destination_id';
  static const String amount = 'amount';
  static const String converted = 'converted';
  static const String paymentMethod = 'payment_method';
  static const String typeNo = 'type_no';
  static const String typeName = 'type_name';
  static const String remark = 'remark';
  static const String receiptImg = 'receipt_img';
  static const String createdTime = 'created_time';
  //static const String sequence = 'sequence';
  static const String excludeBudget = 'exclude_budget';

  static const List<String> values = [
    expenseId,
    destinationId,
    amount,
    converted,
    paymentMethod,
    typeNo,
    typeName,
    remark,
    receiptImg,
    createdTime,
    //sequence,
    excludeBudget,
  ];
}
