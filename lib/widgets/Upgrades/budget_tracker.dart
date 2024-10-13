/* 
Nico Garay
This upgrade is a real time budget tracker
It will say the current budget
The budget will be updateable 
It will have a edit amount icon with a pop up 
*/

import 'package:flutter/material.dart';

class BudgetWidget extends StatefulWidget {
  final Function(double) onAddBudget;

   const BudgetWidget({Key? key, required this.onAddBudget}) : super(key: key);

  @override
  State<BudgetWidget> createState() => _BudgetWidgetState();
}

class _BudgetWidgetState extends State<BudgetWidget> {
  final _budgetController = TextEditingController();
  String? _errorMessage; // For displaying error messages

  void _submitBudget() {
    final enteredBudget = _budgetController.text;

    // Check if the entered value is a valid number
    if (enteredBudget.isEmpty || double.tryParse(enteredBudget) == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number for the budget.';
      });
      return; // Do not proceed if the input is invalid
    }

    // Convert the valid input to a double
    final budgetAmount = double.parse(enteredBudget);

    // Reset the error message if everything is valid
    setState(() {
      _errorMessage = null;
    });

    // Call the callback to add the budget
    widget.onAddBudget(budgetAmount);

    // Close the bottom sheet
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // Adjust for keyboard
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Budget Amount',
                  errorText: _errorMessage, // Display error message if exists
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: _submitBudget,
                  child: const Text('Set Budget'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }
}
