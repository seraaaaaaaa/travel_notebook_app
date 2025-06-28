import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:travel_notebook/blocs/expense/expense_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_event.dart';
import 'package:travel_notebook/blocs/expense/expense_state.dart';
import 'package:travel_notebook/blocs/todo/todo_bloc.dart';
import 'package:travel_notebook/blocs/todo/todo_event.dart';
import 'package:travel_notebook/models/todo/todo_model.dart';
import 'package:travel_notebook/screens/expense/detail/select_todo.dart';
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
  final _dateController = TextEditingController();
  final _remarkController = TextEditingController();

  ExpenseType _expenseType = ExpenseType.others;
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  bool _isExclude = false;

  late TodoBloc _todoBloc;
  late List<Todo>? _todos;

  bool _isAddNew = false;

  @override
  void initState() {
    _destination = widget.destination;
    _todos = [];

    _expenseBloc = BlocProvider.of<ExpenseBloc>(context);
    _todoBloc = BlocProvider.of<TodoBloc>(context);

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

      _isExclude = _expense.excludeBudget == 1;

      _expenseType =
          ExpenseType.values.firstWhere((e) => e.name == _expense.typeName);
      _paymentMethod = PaymentMethod.values
          .firstWhere((p) => p.name == _expense.paymentMethod);

      _amountController.text =
          formatCurrency(_expense.amount, _destination.decimal);
      _remarkController.text = _expense.remark;
    }

    _dateController.text = formatDateWithTimeAndDay(_expense.createdTime);

    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
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
            showToast(state.message, color: kRedColor);
          } else if (state is ExpenseResult) {
            Navigator.pop(context);

            // Show a success message when Destinations are loaded
            showToast(_isAddNew
                ? 'Expense recorded successfully'
                : 'Expense updated successfully');
          }
        },
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: kPadding, vertical: kHalfPadding),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: kHalfPadding),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (_) {
                            DateTime tempDate =
                                _expense.createdTime ?? DateTime.now();
                            return Container(
                              height: MediaQuery.of(context).size.height * .4,
                              color:
                                  CupertinoColors.systemBackground.resolveFrom(
                                context,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(
                                      kHalfPadding,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.calendar_month_outlined,
                                              color: kPrimaryColor,
                                            ),
                                            const SizedBox(width: kHalfPadding),
                                            Text(
                                              'Select Date',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleLarge,
                                            ),
                                          ],
                                        ),
                                        CupertinoButton(
                                          child: const Text('Done'),
                                          onPressed: () {
                                            setState(() {
                                              _expense.createdTime = tempDate;
                                              _dateController.text =
                                                  formatDateWithTimeAndDay(
                                                      _expense.createdTime);
                                            });

                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: CupertinoTheme(
                                      data: const CupertinoThemeData(
                                        textTheme: CupertinoTextThemeData(
                                          dateTimePickerTextStyle: TextStyle(
                                            fontSize: 17,
                                            letterSpacing: 1,
                                            color: kBlackColor,
                                          ),
                                        ),
                                      ),
                                      child: CupertinoDatePicker(
                                        initialDateTime: _expense.createdTime ??
                                            DateTime.now(),
                                        mode:
                                            CupertinoDatePickerMode.dateAndTime,
                                        dateOrder: DatePickerDateOrder.ymd,
                                        //TODO minimumYear: 2000,
                                        maximumDate: DateTime.now()
                                            .add(const Duration(days: 1)),
                                        onDateTimeChanged: (DateTime newDate) {
                                          tempDate = newDate;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      onChanged: (val) {},
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.start,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: kGreyColor.shade100,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kHalfPadding),
                          borderSide: BorderSide(
                            color: kSecondaryColor.shade50,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kHalfPadding),
                          borderSide: BorderSide(
                            color: kSecondaryColor.shade50,
                            width: 1,
                          ),
                        ),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: kHalfPadding),
                          child: SizedBox(
                            child: Center(
                                widthFactor: 0.0,
                                child: Icon(Iconsax.calendar_1_copy)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: kPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: kPadding / 3),
                          child: Text(
                            formatCurrency(
                              _expense.converted,
                              _destination.ownDecimal,
                              currency: _destination.ownCurrency,
                            ),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: kHalfPadding),
                    TextFormField(
                      controller: _amountController,
                      onTap: () => _amountController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _amountController.value.text.length),
                      onChanged: (val) {
                        double ownAmount = calculateOwnCurrency(
                            _destination.rate, parseDouble(val));

                        setState(() {
                          _expense.converted = ownAmount;
                        });
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        CurrencyTextInputFormatter.simpleCurrency(
                            decimalDigits: _destination.decimal, name: '')
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: kGreyColor.shade100,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kHalfPadding),
                          borderSide: BorderSide(
                            color: kSecondaryColor.shade50,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kHalfPadding),
                          borderSide: BorderSide(
                            color: kSecondaryColor.shade50,
                            width: 1,
                          ),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: kHalfPadding),
                          child: SizedBox(
                            child: Center(
                              widthFactor: 0.0,
                              child: Text(
                                _destination.currency,
                                style: const TextStyle(
                                    letterSpacing: 1,
                                    fontSize: kPadding,
                                    fontWeight: FontWeight.w500,
                                    color: kSecondaryColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Transform.scale(
                          scale: 1.25,
                          child: CupertinoCheckbox(
                            activeColor: kPrimaryColor,
                            checkColor: kWhiteColor,
                            value: _isExclude,
                            onChanged: (bool? value) {
                              if (value != null) {
                                setState(() {
                                  _isExclude = value;
                                });
                              }
                            },
                          ),
                        ),
                        Text(
                          'Exclude from Budget',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(color: kSecondaryColor),
                        ),
                        const SizedBox(
                          width: kHalfPadding / 2,
                        ),
                        Tooltip(
                          decoration: BoxDecoration(
                              color: kBlackColor,
                              borderRadius:
                                  BorderRadius.circular(kHalfPadding / 2)),
                          padding: const EdgeInsets.all(kHalfPadding),
                          margin: const EdgeInsets.symmetric(
                              horizontal: kHalfPadding),
                          message:
                              'Tick this box to exclude this expense from your total budget',
                          child: Icon(
                            Icons.help,
                            size: kPadding * 1.25,
                            color: kGreyColor.shade400,
                          ),
                        ),
                      ],
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
                        null;
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
                    const SizedBox(height: kPadding / 2),
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
                                          bottom: kHalfPadding, top: 6),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(kHalfPadding),
                                        color: kSecondaryColor.shade100,
                                      ),
                                      height: kHalfPadding,
                                      width: 120,
                                    ),
                                  ),
                                  // Scrollable list
                                  Expanded(
                                    child: ListView(
                                      children: ExpenseType.values.map<Widget>(
                                          (ExpenseType expenseType) {
                                        return ListTile(
                                          visualDensity:
                                              const VisualDensity(vertical: -3),
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
                                const SizedBox(width: kHalfPadding),
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
                                  color: kGreyColor.shade200,
                                  borderRadius:
                                      BorderRadius.circular(kHalfPadding * 3)),
                              padding: const EdgeInsets.all(kPadding / 2),
                              child: const Icon(Icons.keyboard_arrow_down))
                        ],
                      ),
                    ),
                    const SizedBox(height: kPadding * 1.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remark',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        GestureDetector(
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();

                            _todos = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SelectTodo(
                                        destinationId:
                                            _destination.destinationId!,
                                      )),
                            );

                            if (_todos != null && _todos!.isNotEmpty) {
                              if (_remarkController.text.isNotEmpty) {
                                _remarkController.text += ' ';
                              }

                              _remarkController.text += _todos!
                                  .map((todo) => todo.content)
                                  .join(', ');
                            }
                          },
                          child: Text(
                            'Select To-do',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: kPrimaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: kHalfPadding,
                    ),
                    TextField(
                      maxLines: 5,
                      controller: _remarkController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, letterSpacing: 1),
                      decoration: InputDecoration(
                        hintText: 'Add a remark here...',
                        fillColor: kGreyColor.shade100,
                        filled: true,
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kHalfPadding),
                          borderSide: BorderSide(
                            color: kSecondaryColor.shade50,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kHalfPadding),
                          borderSide: BorderSide(
                            color: kSecondaryColor.shade50,
                            width: 1,
                          ),
                        ),
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: kGreyColor,
                        ),
                      ),
                    ),
                  ]),
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
                  //is edit
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
                _expense.excludeBudget = _isExclude ? 1 : 0;

                updateTotalExpenses(_expense, _destination);

                if (_todos != null && _todos!.isNotEmpty) {
                  _todoBloc.add(UpdateAllTodos(_todos!));
                }

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
