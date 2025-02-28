import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/models/expense/enum/expense_type.dart';
import 'package:travel_notebook/models/expense/enum/payment_method.dart';
import 'package:travel_notebook/models/expense/expense_model.dart';
import 'package:travel_notebook/services/image_handler.dart';
import 'package:travel_notebook/services/utils.dart';
import 'package:travel_notebook/components/delete_dialog.dart';
import 'package:travel_notebook/screens/expense/view_receipt.dart';

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final Destination destination;
  final Function(String) onUploadReceipt;
  final Function() onEdit;
  final Function() onDelete;
  final int index; //for reordering

  const ExpenseItem({
    super.key,
    required this.expense,
    required this.destination,
    required this.onUploadReceipt,
    required this.onEdit,
    required this.onDelete,
    this.index = -1,
  });

  Future _viewReceipt(BuildContext context) async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewReceipt(
          imagePath: expense.receiptImg,
          onDeleteImage: onUploadReceipt,
        ),
      ),
    );
    if (result == 'deleted' && context.mounted) {
      Navigator.pop(context); //pop modal bottom dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt Deleted Successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: index >= 0
          ? null
          : () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(kPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  bottom: kPadding, top: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: kSecondaryColor.shade100,
                              ),
                              height: 10,
                              width: 120,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ExpenseType.values
                                          .firstWhere((e) =>
                                              e.typeNo == expense.typeNo &&
                                              !e.enabled)
                                          .color!
                                          .withOpacity(.2),
                                    ),
                                    child: Icon(
                                      ExpenseType.values
                                          .firstWhere(
                                              (e) => e.name == expense.typeName)
                                          .icon,
                                      size: 28,
                                      color: kGreyColor.shade800,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense.typeName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      Text(
                                        ExpenseType.values
                                            .firstWhere((e) =>
                                                e.typeNo == expense.typeNo)
                                            .name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(formatDateWithTime(expense.createdTime)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    expense.remark.isEmpty
                                        ? 'No Remark'
                                        : expense.remark,
                                    style: TextStyle(
                                        height: 1.4,
                                        letterSpacing: .4,
                                        fontSize: kPadding,
                                        color: expense.remark.isEmpty
                                            ? kGreyColor
                                            : null),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        if (expense.receiptImg.isNotEmpty) {
                                          await _viewReceipt(context);
                                        } else {
                                          XFile? selectedImg =
                                              await ImageHandler()
                                                  .selectImgFromGallery();

                                          String imgPath = "";
                                          if (selectedImg != null) {
                                            imgPath = await ImageHandler()
                                                .saveImageToFolder(selectedImg);

                                            await onUploadReceipt(imgPath);

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Receipt Uploaded Successfully')),
                                              );

                                              Navigator.pop(context);
                                              await _viewReceipt(context);
                                            }
                                          }
                                        }
                                      },
                                      icon: Icon(
                                        expense.receiptImg.isEmpty
                                            ? Icons.file_upload
                                            : Icons.receipt,
                                        color: kSecondaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);

                                        onEdit();
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: kPrimaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return DeleteDialog(
                                                title: "Delete Expense",
                                                content:
                                                    "Are you sure you want to delete this record?",
                                                onConfirm: () {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);

                                                  onDelete();
                                                },
                                                onCancel: () {
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          );
                                        },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: kRedColor,
                                          size: 20,
                                        )),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(
                            color: kSecondaryColor.shade100,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            margin: const EdgeInsets.only(top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Icon(
                                      PaymentMethod.values
                                          .firstWhere((e) =>
                                              e.name == expense.paymentMethod)
                                          .icon,
                                      size: 28,
                                      color: kGreyColor.shade800,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      expense.paymentMethod,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                Text(
                                  formatCurrency(
                                    expense.amount,
                                    destination.decimal,
                                    currency: destination.currency,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            },
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      leading: ReorderableDragStartListener(
        index: index,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ExpenseType.values
                .firstWhere((e) => e.typeNo == expense.typeNo && !e.enabled)
                .color!
                .withOpacity(.2),
          ),
          child: Icon(
            ExpenseType.values
                .firstWhere((e) => e.name == expense.typeName)
                .icon,
            size: 28,
            color: kGreyColor.shade800,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            expense.typeName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            expense.remark.isNotEmpty
                ? expense.remark
                : ExpenseType.values
                    .firstWhere((e) => e.typeNo == expense.typeNo)
                    .name,
            style: Theme.of(context).textTheme.labelLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatCurrency(
              expense.amount,
              destination.decimal,
              currency: destination.currency,
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            formatCurrency(
              expense.converted,
              destination.ownDecimal,
              currency: destination.ownCurrency,
            ),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
