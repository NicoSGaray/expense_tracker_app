/* 
Nico Garay
This upgrade is a real time budget tracker
It will say the current budget
The budget will be updateable 
It will have a edit amount icon with a pop up 
*/

import 'package:flutter/material.dart';

// Budget model
class Budget {
  String category;
  double amount;
  double spent;

  Budget({required this.category, required this.amount, this.spent = 0.0});

  bool isOverBudget() {
    return spent >= amount;
  }

  double percentageSpent() {
    return (spent / amount) * 100;
  }
}

// Budget widget that allows setting budgets
class BudgetWidget extends StatefulWidget {
  final Function(Budget) onAddBudget; // Callback function to pass the new budget

  BudgetWidget({required this.onAddBudget});

  @override
  _BudgetWidgetState createState() => _BudgetWidgetState();
}

class _BudgetWidgetState extends State<BudgetWidget> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(labelText: 'Category'),
          ),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(labelText: 'Budget Amount'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_categoryController.text.isNotEmpty &&
                  _amountController.text.isNotEmpty) {
                // Create a new budget
                final budget = Budget(
                  category: _categoryController.text,
                  amount: double.parse(_amountController.text),
                );

                // Call the callback function to pass the budget back
                widget.onAddBudget(budget);

                // Close the modal after the budget is added
                Navigator.of(context).pop();
              }
            },
            child: Text('Add Budget'),
          ),
        ],
      ),
    );
  }
}
