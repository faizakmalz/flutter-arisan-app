import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pmob/models/database.dart';
import 'package:pmob/models/transaction_with_category.dart';
import 'package:pmob/pages/calendarPage.dart';
import 'package:pmob/pages/transactionPage.dart';
import 'package:pmob/pages/cashflow_report.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;

  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();

  double totalIncome = 0.0;
  double totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  Future<void> _calculateTotals() async {
    final transactions = await database.getAllTransactionsRepo().first;
    double income = 0.0;
    double expense = 0.0;

    for (var transactionWithCategory in transactions) {
      if (transactionWithCategory.category.type == 1) {
        // Assuming 1 is the type for income
        income += transactionWithCategory.transaction.ammount;
      } else if (transactionWithCategory.category.type == 2) {
        // Assuming 2 is the type for expense
        expense += transactionWithCategory.transaction.ammount;
      }
    }

    setState(() {
      totalIncome = income;
      totalExpense = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('Arisan',
                style: GoogleFonts.montserrat(
                  color: Colors.blue,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ))),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _navigateToCashflowReport,
            child: Center(
              child: Container(
                width: 350,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total Cash',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 2),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Rp. ${(totalIncome - totalExpense).toStringAsFixed(2)}',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CalendarPage(),
                    ),
                  );
                },
                child: Container(
                  width: 340,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue, // Background color of the box
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26, // Shadow color
                        blurRadius: 4, // Blur radius of the shadow
                        offset: Offset(2, 2), // Offset of the shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event,
                        size: 24.0, // Icon size
                        color: Colors.white, // Icon color
                      ),
                      SizedBox(width: 8), // Space between icon and text
                      Text(
                        'Events',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Card(
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(
                                snapshot.data![index].category.type == 2
                                    ? Icons.upload
                                    : Icons.download,
                                color: snapshot.data![index].category.type == 2
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              title: Text(
                                  'Rp. ${snapshot.data![index].transaction.ammount.toString()}',
                                  style: GoogleFonts.montserrat(
                                    color:
                                        const Color.fromARGB(255, 48, 48, 48),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  )),
                              subtitle: Text(
                                '${snapshot.data![index].category.name} (${snapshot.data![index].transaction.name})',
                                style: GoogleFonts.montserrat(
                                    color:
                                        const Color.fromARGB(255, 48, 48, 48),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await database.deleteTransactionRepo(
                                        snapshot.data![index].transaction.id,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => Transactionpage(
                                            transactionWithCategory:
                                                snapshot.data![index],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No Data'));
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCashflowReport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CashflowReportPage(),
      ),
    );
  }
}
