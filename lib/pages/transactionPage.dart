import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pmob/models/database.dart';
import 'package:pmob/models/transaction_with_category.dart';

class Transactionpage extends StatefulWidget {
  final TransactionWithCategory? transactionWithCategory;
  const Transactionpage({Key? key, required this.transactionWithCategory})
      : super(key: key);

  @override
  State<Transactionpage> createState() => _TransactionpageState();
}

class _TransactionpageState extends State<Transactionpage> {
  final AppDb database = AppDb();
  bool isExpense = true;
  late int type;
  List<String> list = ['Makan dan Jajan', 'Transportasi', 'NontonFilm'];
  late String dropDownValue = list.first;
  TextEditingController ammountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  Category? selectedCategory;

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  Future update(int transactionId, int ammount, int categoryId,
      DateTime transactionDate, String nameDetail) async {
    return await database.updateTransactionRepo(
        transactionId, ammount, categoryId, transactionDate, nameDetail);
  }

  Future insert(
      int ammount, DateTime date, String nameDetail, int categoryId) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.transactions).insertReturning(
        TransactionsCompanion.insert(
            name: nameDetail,
            category_id: categoryId,
            transaction_Date: date,
            ammount: ammount,
            createdAt: now,
            updatedAt: now,
            deletedAt: now));
    print('apanih : ' + row.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.transactionWithCategory != null) {
      updateTransactionView(widget.transactionWithCategory!);
    } else {
      type = 2;
    }

    super.initState();
  }

  void updateTransactionView(TransactionWithCategory transactionWithCategory) {
    ammountController.text =
        transactionWithCategory.transaction.ammount.toString();
    detailController.text = transactionWithCategory.transaction.name;
    dateController.text = DateFormat('yyyy-MM-dd')
        .format(transactionWithCategory.transaction.transaction_Date);
    type = transactionWithCategory.category.type;
    (type == 2) ? isExpense = true : isExpense = false;
    selectedCategory = transactionWithCategory.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transcation'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Switch(
                        value: isExpense,
                        onChanged: (bool value) {
                          setState(() {
                            isExpense = value;
                            type = (isExpense) ? 2 : 1;
                            selectedCategory = null;
                          });
                        },
                        inactiveTrackColor: Colors.green[200],
                        inactiveThumbColor: Colors.green,
                        activeColor: Colors.red,
                      ),
                      SizedBox(width: 10),
                      Text(
                        isExpense ? 'Expense' : 'Income',
                        style: GoogleFonts.montserrat(fontSize: 14),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: TextFormField(
                      controller: ammountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(), labelText: "Ammount"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Category',
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                  ),
                  FutureBuilder<List<Category>>(
                      future: getAllCategory(type),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          if (snapshot.hasData) {
                            if (snapshot.data!.length > 0) {
                              selectedCategory = (selectedCategory == null)
                                  ? snapshot.data!.first
                                  : selectedCategory;
                              print('APANIH : ' + snapshot.toString());
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: DropdownButton<Category>(
                                    value: (selectedCategory == null)
                                        ? snapshot.data!.first
                                        : selectedCategory,
                                    isExpanded: true,
                                    icon: Icon(Icons.arrow_downward),
                                    items: snapshot.data!.map((Category item) {
                                      return DropdownMenuItem<Category>(
                                        value: item,
                                        child: Text(item.name),
                                      );
                                    }).toList(),
                                    onChanged: (Category? value) {
                                      setState(() {});
                                      selectedCategory = value;
                                    }),
                              );
                            } else {
                              return Center(
                                child: Text('Data Kosong'),
                              );
                            }
                          } else {
                            return Center(
                              child: Text("Tidak Ada Data"),
                            );
                          }
                        }
                      }),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      readOnly: true,
                      controller: dateController,
                      decoration: InputDecoration(labelText: "Enter Date"),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2099));

                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);

                          dateController.text = formattedDate;
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: TextFormField(
                      controller: detailController,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(), labelText: "Detail"),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                      child: ElevatedButton(
                          onPressed: () async {
                            (widget.transactionWithCategory == null)
                                ? await insert(
                                    int.parse(ammountController.text),
                                    DateTime.parse(dateController.text),
                                    detailController.text,
                                    selectedCategory!.id)
                                : await update(
                                    widget.transactionWithCategory!.transaction
                                        .id,
                                    int.parse(ammountController.text),
                                    selectedCategory!.id,
                                    DateTime.parse(dateController.text),
                                    detailController.text);
                            setState(() {});
                            Navigator.pop(context, true);
                          },
                          child: Text('Save')))
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}
