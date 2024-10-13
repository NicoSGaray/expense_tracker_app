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
  final List<Expense> _registeredExpenses = [
    Expense(
      title: 'Flutter Course',
      amount: 19.99,
      date: DateTime.now(),
      category: Category.work,
    ),
    Expense(
      title: 'Cinema',
      amount: 16.59,
      date: DateTime.now(),
      category: Category.leisure,
    ),
  ];

  final List<Budget> _budgets = []; // For storing budget data

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
      _updateBudgets(expense); // Update the budget when a new expense is added
    });
  }

  void _updateBudgets(Expense expense) {
    // Update budget spent amounts when new expense is added
    for (var budget in _budgets) {
      if (budget.category == expense.category.toString().split('.').last ||
          budget.category == 'Overall') {
        setState(() {
          budget.spent += expense.amount;
        });
      }
    }
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense Deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(
              () {
                _registeredExpenses.insert(expenseIndex, expense);
                _updateBudgets(
                    expense); // Re-add the expense to the budget if undone
              },
            );
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
          onAddBudget: (Budget budget) {
            setState(() {
              _budgets.add(budget);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now(); // Gets the current date

    // Separates expenses into past and future categories
    final pastExpenses = _registeredExpenses
        .where((expense) => expense.date.isBefore(currentDate)) // Past expenses
        .toList();
    final futureExpenses = _registeredExpenses
        .where(
            (expense) => expense.date.isAfter(currentDate)) // Future expenses
        .toList();

    Widget mainContent = const Center(
      child: Text('No expenses found. Start adding some!'),
    );

    if (_registeredExpenses.isNotEmpty) {
      // Displays upcoming and past expenses in a single column
      mainContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Displays future expenses section if there are future expenses
          if (futureExpenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Upcoming Expenses', // Title for future expenses section
                style: Theme.of(context).textTheme.titleLarge, // Text style
              ),
            ),
          if (futureExpenses.isNotEmpty)
            Expanded(
              child: ExpensesList(
                expenses: futureExpenses, // Shows future expenses first
                onRemoveExpense: _removeExpense, // Allows deletion of expenses
              ),
            ),

          // Displays past expenses section if there are past expenses
          if (pastExpenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Past Expenses', // Title for past expenses section
                style: Theme.of(context).textTheme.titleLarge, // Text style
              ),
            ),
          if (pastExpenses.isNotEmpty)
            Expanded(
              child: ExpensesList(
                expenses:
                    pastExpenses, // Shows past expenses after future expenses
                onRemoveExpense: _removeExpense, // Allows deletion of expenses
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: _openBudgetOverlay, // Button to open budget settings
            icon: const Icon(Icons.account_balance_wallet),
          ),
        ],
      ),
      body: Column(
        children: [
          // Show chart at the top
          Chart(expenses: _registeredExpenses),

          // Display budget list under the chart
          if (_budgets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: _budgets.map((budget) {
                  return ListTile(
                    title:
                        Text('${budget.category} Budget: \$${budget.amount}'),
                    subtitle: Text('Spent: \$${budget.spent}'),
                    trailing: budget.isOverBudget()
                        ? const Text(
                            'Over Budget!',
                            style: TextStyle(color: Colors.red),
                          )
                        : budget.percentageSpent() >= 80
                            ? const Text(
                                'Near Budget Limit!',
                                style: TextStyle(color: Colors.orange),
                              )
                            : null,
                  );
                }).toList(),
              ),
            ),

          // Main content (expenses list) below budget list
          Expanded(
            child: mainContent,
          ),
        ],
      ),
    );
  }
}
