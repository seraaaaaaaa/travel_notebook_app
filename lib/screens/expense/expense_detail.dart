import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_event.dart';
import 'package:travel_notebook/blocs/expense/expense_state.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/models/expense/enum/payment_method.dart';
import 'package:travel_notebook/models/expense/expense_model.dart';
import 'package:travel_notebook/models/expense/enum/expense_type.dart';
import 'package:travel_notebook/services/utils.dart';
import 'package:travel_notebook/screens/expense/widgets/select_payment.dart';

class ExpenseDetailPage extends StatefulWidget {
  final Destination destination;
  final Expense? expense;

  const ExpenseDetailPage({
    super.key,
    required this.destination,
    this.expense,
  });

  @override
  State<ExpenseDetailPage> createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends State<ExpenseDetailPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late ExpenseBloc _expenseBloc;
  late Expense _expense;

  late Destination _destination;

  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();

  ExpenseType _expenseType = ExpenseType.others;
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  bool _isAddNew = false;

  @override
  void initState() {
    _destination = widget.destination;

    _expenseBloc = BlocProvider.of<ExpenseBloc>(context);

    if (widget.expense == null) {
      _isAddNew = true;
      _expense = Expense(
          destinationId: _destination.destinationId!,
          amount: 0.00,
          converted: 0.00,
          paymentMethod: _paymentMethod.name,
          typeNo: _expenseType.typeNo,
          typeName: _expenseType.name,
          remark: '',
          createdTime: DateTime.now());
    } else {
      _expense = widget.expense!;

      _expenseType =
          ExpenseType.values.firstWhere((e) => e.name == _expense.typeName);
      _paymentMethod = PaymentMethod.values
          .firstWhere((p) => p.name == _expense.paymentMethod);

      _amountController.text = formatCurrency(_expense.amount);
      _remarkController.text = _expense.remark;
    }

    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseError) {
            Navigator.pop(context);
            // Show an error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ExpenseResult) {
            Navigator.pop(context);

            // Show a success message when Destinations are loaded
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_isAddNew
                      ? 'Expense recorded successfully'
                      : 'Expense updated successfully')),
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(kPadding),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: kPadding),
                        child: TextFormField(
                          controller: _amountController,
                          onTap: () => _amountController.selection =
                              TextSelection(
                                  baseOffset: 0,
                                  extentOffset:
                                      _amountController.value.text.length),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          enableInteractiveSelection: false,
                          autofocus: _isAddNew ? true : false,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(
                              letterSpacing: 1,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.end,
                          onChanged: (val) {
                            _amountController.text =
                                formatCurrency(parseDouble(val));
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: SizedBox(
                                child: Center(
                                  widthFactor: 0.0,
                                  child: Text(
                                    _destination.currency,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: kSecondaryColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: kPadding),
                      Text(
                        'Payment Method',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      SelectPayment(
                        PaymentMethod.values,
                        _paymentMethod,
                        onSelectionChanged: (selectedChoice) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _paymentMethod = selectedChoice;
                          });
                        },
                      ),
                      const SizedBox(height: kPadding),
                      Text(
                        'Expense Type',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(kPadding),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Center(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            bottom: 10, top: 6),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: kSecondaryColor.shade100,
                                        ),
                                        height: 10,
                                        width: 120,
                                      ),
                                    ),
                                    // Scrollable list
                                    Expanded(
                                      child: ListView(
                                        children: ExpenseType.values
                                            .map<Widget>(
                                                (ExpenseType expenseType) {
                                          return ListTile(
                                            visualDensity: const VisualDensity(
                                                vertical: -3),
                                            contentPadding:
                                                const EdgeInsets.all(0),
                                            onTap: () {
                                              Navigator.pop(context);
                                              setState(() {
                                                _expenseType = expenseType;
                                              });
                                            },
                                            enabled: expenseType.enabled,
                                            leading: expenseType.icon != null
                                                ? Icon(expenseType.icon)
                                                : null, // If no icon, leading is null
                                            title: Text(
                                              expenseType.name,
                                              style: expenseType.enabled
                                                  ? null
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .labelLarge,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(_expenseType.icon),
                                  const SizedBox(width: 10),
                                  Text(
                                    _expenseType.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.keyboard_arrow_down))
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Remark',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      TextField(
                        maxLines: 3,
                        controller: _remarkController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, letterSpacing: 1),
                        decoration: const InputDecoration(
                          hintText: 'Add a remark here...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
          child: Container(
        padding: const EdgeInsets.all(kPadding),
        child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                if (!_isAddNew) {
                  deductTotalExpenses(_expense, _destination);
                }

                double amount = parseDouble(_amountController.text);
                double converted =
                    calculateOwnCurrency(_destination.rate, amount);

                _expense.amount = amount;
                _expense.converted = converted;
                _expense.paymentMethod = _paymentMethod.name;
                _expense.typeNo = _expenseType.typeNo;
                _expense.typeName = _expenseType.name;
                _expense.remark = _remarkController.text;

                updateTotalExpenses(_expense, _destination);

                if (_isAddNew) {
                  _expenseBloc.add(AddExpense(_expense, _destination));
                } else {
                  _expenseBloc.add(UpdateExpense(_expense, _destination));
                }
              }
            },
            child: const Text('Save')),
      )),
    );
  }
}