/*
Arturo Valle

Future Expenses
*/

import 'package:flutter/material.dart';
import 'package:expense_tracker_app/models/expense.dart';

class ScheduledExpenses extends StatelessWidget {
  final List<Expense> expenses;

  const ScheduledExpenses({
    super.key,
    required this.expenses, // Required list of expenses
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduled Expenses')), // Title
      body: ListView.builder(
        itemCount: expenses.length, // Number of items in the expenses list
        itemBuilder: (ctx, index) {
          final expense = expenses[index]; // Get the current expense
          return ListTile(
            title: Text(expense.title), // Displays the expense title
            subtitle: Text(expense.formattedDate), // Display the formatted date
            trailing: Text(
                '\$${expense.amount.toStringAsFixed(2)}'), // Display the amount with 2 decimals
          );
        },
      ),
    );
  }
}
