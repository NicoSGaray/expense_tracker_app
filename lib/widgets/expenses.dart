import 'package:expense_tracker_app/widgets/chart/chart.dart';
import 'package:expense_tracker_app/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker_app/models/expense.dart';
import 'package:expense_tracker_app/widgets/new_expense.dart';
import 'package:expense_tracker_app/widgets/Upgrades/budget_tracker.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = []; // No default expenses

  double _totalBudget = 0.0; // Total budget for all expenses
  double _totalExpenses = 0.0; // Track total expenses

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(onAddExpense: _addExpense),
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
      _totalExpenses += expense.amount; // Update total expenses
    });
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
      _totalExpenses -= expense.amount; // Subtract expense from total
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense Deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
              _totalExpenses += expense.amount; // Re-add expense on undo
            });
          },
        ),
      ),
    );
  }

  void _openBudgetOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return BudgetWidget(
          onAddBudget: (double budget) {
            setState(() {
              _totalBudget = budget; // Set the overall budget
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();

    // Separating expenses into past, future, and reccuring categories
    final pastExpenses = _registeredExpenses
        .where((expense) => expense.date.isBefore(currentDate))
        .toList();
    final futureExpenses = _registeredExpenses
        .where((expense) => expense.date.isAfter(currentDate))
        .toList();
    final reccuringExpenses = _registeredExpenses
        .where((expense) => expense.isRecurring == true)
        .toList();

    // Default message when no expenses are registered
    Widget mainContent = const Center(
      child: Text('No expenses found. Start adding some!'),
    );

    if (_registeredExpenses.isNotEmpty) {
      mainContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display upcoming expenses
          if (reccuringExpenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Reccuring Expenses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          if (reccuringExpenses.isNotEmpty)
            Expanded(
              child: ExpensesList(
                expenses: reccuringExpenses,
                onRemoveExpense: _removeExpense,
              ),
            ),
          // Display upcoming expenses
          if (futureExpenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Upcoming Expenses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          if (futureExpenses.isNotEmpty)
            Expanded(
              child: ExpensesList(
                expenses: futureExpenses,
                onRemoveExpense: _removeExpense,
              ),
            ),
          // Display past expenses
          if (pastExpenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Past Expenses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          if (pastExpenses.isNotEmpty)
            Expanded(
              child: ExpensesList(
                expenses: pastExpenses,
                onRemoveExpense: _removeExpense,
              ),
            ),
        ],
      );
    }

    // Calculate remaining balance from the budget
    double remainingBalance = _totalBudget - _totalExpenses;
    bool isOverBudget = remainingBalance < 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: _openBudgetOverlay, // Open budget settings
            icon: const Icon(Icons.account_balance_wallet),
          ),
        ],
      ),
      body: Column(
        children: [
          // Display chart at the top
          Chart(expenses: _registeredExpenses),

          // Display total budget information in a Card
          if (_totalBudget > 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title for the budget card
                      Text(
                        'Budget Overview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),

                      // Display Total Budget
                      Text(
                        'Total Budget: \$${_totalBudget.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),

                      // Display Total Expenses
                      Text(
                        'Total Expenses: \$${_totalExpenses.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),

                      // Display Remaining Balance
                      Text(
                        'Remaining Balance: \$${remainingBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isOverBudget ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Conditional budget warning display
                      if (isOverBudget)
                        const Text(
                          'Over Budget!',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      if (!isOverBudget &&
                          remainingBalance < (_totalBudget * 0.2))
                        const Text(
                          'Near Budget Limit',
                          style: TextStyle(color: Colors.orange),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Main content (expenses list) below the budget card
          Expanded(
            child: mainContent,
          ),
        ],
      ),
    );
  }
}
