import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pmob/models/database.dart';
import 'package:pmob/models/transaction_with_category.dart';

class CashflowReportPage extends StatefulWidget {
  @override
  _CashflowReportPageState createState() => _CashflowReportPageState();
}

class _CashflowReportPageState extends State<CashflowReportPage> {
  final AppDb database = AppDb();
  double totalIncome = 0;
  double totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _calculateTotals() {
    database.getAllTransactionsRepo().listen((transactions) {
      double income = 0;
      double expense = 0;

      for (var transaction in transactions) {
        if (transaction.category.type == 1) {
          income += transaction.transaction.ammount;
        } else if (transaction.category.type == 2) {
          expense += transaction.transaction.ammount;
        }
      }

      setState(() {
        totalIncome = income;
        totalExpense = expense;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cashflow Report', style: GoogleFonts.montserrat()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display totals
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Income: Rp. $totalIncome',
                      style: GoogleFonts.montserrat(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total Expense: Rp. $totalExpense',
                      style: GoogleFonts.montserrat(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    StreamBuilder<List<TransactionWithCategory>>(
                      stream: database.getAllTransactionsRepo(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            'Balance: Calculating...',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          );
                        } else {
                          // Calculate live total balance
                          double liveTotal = totalIncome - totalExpense;
                          return Text(
                            'Balance: Rp. ${liveTotal.toStringAsFixed(2)}',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Display transaction list
            Expanded(
              child: StreamBuilder<List<TransactionWithCategory>>(
                stream: database.getAllTransactionsRepo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final transaction = snapshot.data![index];
                        return ListTile(
                          leading: Container(
                            child: (transaction.category.type == 2)
                                ? Icon(Icons.upload, color: Colors.red)
                                : Icon(Icons.download, color: Colors.green),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(8),
                          ),
                          title: Text("Rp. ${transaction.transaction.ammount}"),
                          subtitle: Text(
                              "${transaction.category.name} (${transaction.transaction.name})"),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No transactions available.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
