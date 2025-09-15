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

  const ExpenseItem({
    super.key,
    required this.expense,
    required this.destination,
    required this.onUploadReceipt,
    required this.onEdit,
    required this.onDelete,
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
      showToast('Receipt Deleted Successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
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
                            bottom: kPadding, top: kPadding - kHalfPadding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(kHalfPadding),
                          color: kSecondaryColor.shade100,
                        ),
                        height: kHalfPadding,
                        width: 120,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: kHalfPadding,
                      children: [
                        Expanded(
                          child: Row(
                            spacing: kHalfPadding,
                            children: [
                              _ExpenseIcon(
                                typeNo: expense.typeNo,
                                typeName: expense.typeName,
                              ),
                              Expanded(
                                child: _ExpenseTitle(
                                  expense: expense,
                                  showFull: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatDateWithTime(expense.createdTime),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 13, color: kSecondaryColor),
                        ),
                      ],
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: kHalfPadding),
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
                            width: kHalfPadding,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  if (expense.receiptImg.isNotEmpty) {
                                    await _viewReceipt(context);
                                  } else {
                                    XFile? selectedImg = await ImageHandler()
                                        .selectImgFromGallery();

                                    String imgPath = "";
                                    if (selectedImg != null) {
                                      imgPath = await ImageHandler()
                                          .saveImageToFolder(selectedImg);

                                      await onUploadReceipt(imgPath);

                                      if (context.mounted) {
                                        showToast(
                                            'Receipt Uploaded Successfully');

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
                                  color: kIndigoColor,
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
                                              "Are you sure you want to delete this expense record?",
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
                                  icon: const Icon(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: kHalfPadding / 2),
                      margin: const EdgeInsets.only(
                          top: kHalfPadding / 2, bottom: kHalfPadding),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(
                                PaymentMethod.values
                                    .firstWhere(
                                        (e) => e.name == expense.paymentMethod)
                                    .icon,
                                size: 28,
                                color: kSecondaryColor.shade700,
                              ),
                              const SizedBox(width: kHalfPadding / 2),
                              Text(
                                expense.paymentMethod,
                                style: Theme.of(context).textTheme.titleMedium,
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
      contentPadding: const EdgeInsets.symmetric(
          horizontal: kHalfPadding / 3, vertical: kPadding / 2),
      leading: _ExpenseIcon(
        typeNo: expense.typeNo,
        typeName: expense.typeName,
      ),
      title: _ExpenseTitle(expense: expense),
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
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color:
                    expense.excludeBudget == 1 ? kSecondaryColor : kBlackColor),
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

class _ExpenseTitle extends StatelessWidget {
  const _ExpenseTitle({
    required this.expense,
    this.showFull = false,
  });

  final Expense expense;
  final bool showFull;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                expense.typeName,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (expense.excludeBudget == 1)
              Container(
                margin: const EdgeInsets.only(left: kHalfPadding),
                padding: const EdgeInsets.symmetric(
                    vertical: kHalfPadding / 5, horizontal: kHalfPadding / 1.5),
                decoration: BoxDecoration(
                    color: kGreyColor.shade50,
                    border: Border.all(color: kSecondaryColor.shade100),
                    borderRadius: BorderRadius.circular(kHalfPadding / 2.5)),
                child: Text(
                  showFull ? 'Excluded' : 'Excl.',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: kSecondaryColor),
                ),
              ),
          ],
        ),
        Text(
          expense.remark.isNotEmpty && !showFull
              ? expense.remark
              : ExpenseType.values
                  .firstWhere((e) => e.typeNo == expense.typeNo)
                  .name,
          style: Theme.of(context).textTheme.labelLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ExpenseIcon extends StatelessWidget {
  const _ExpenseIcon({
    required this.typeNo,
    required this.typeName,
  });

  final int typeNo;
  final String typeName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kHalfPadding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ExpenseType.values
            .firstWhere((e) => e.typeNo == typeNo && !e.enabled)
            .color!
            .withValues(alpha: .2),
      ),
      child: Icon(
        ExpenseType.values.firstWhere((e) => e.name == typeName).icon,
        size: 28,
        color: kGreyColor.shade800,
      ),
    );
  }
}
