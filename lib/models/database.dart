import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'package:pmob/models/caregory.dart';
import 'package:pmob/models/transaction.dart';
import 'package:pmob/models/transaction_with_category.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Categories, Transactions],
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Category>> getAllCategoryRepo(int type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
        .get();
  }

  Future updateCategoryRepo(int id, String name) async {
    return await (update(categories)..where((tbl) => tbl.id.equals(id)))
        .write(CategoriesCompanion(name: Value(name)));
  }

  Future deleteCategoryRepo(int id) async {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future deleteTransactionRepo(int id) async {
    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future updateTransactionRepo(int id, int ammount, int categoryId,
      DateTime transactionDate, String nameDetail) async {
    return await (update(transactions)..where((tbl) => tbl.id.equals(id)))
        .write(TransactionsCompanion(
            name: Value(nameDetail),
            ammount: Value(ammount),
            category_id: Value(categoryId),
            transaction_Date: Value(transactionDate)));
  }

  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(
      DateTime date) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ])
      ..where(transactions.transaction_Date.equals(date)));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
            row.readTable(transactions), row.readTable(categories));
      }).toList();
    });
  }

  Stream<List<TransactionWithCategory>> getAllTransactionsRepo() {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ]));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
            row.readTable(transactions), row.readTable(categories));
      }).toList();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sb.sqlite'));
    return NativeDatabase(file);
  });
}
