import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:md_financial/enums/record_enum.dart';
import 'package:md_financial/object_box.dart';
import 'package:md_financial/screens/add_screen.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'models/entities/record_entity_model.dart';

/// Provides access to the ObjectBox Store throughout the app.
late ObjectBox objectbox;

Future<void> main() async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  objectbox = await ObjectBox.create();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حساب داری شخصی',
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        PersianMaterialLocalizations.delegate,
        PersianCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("fa", "IR"),
        Locale("fa"),
      ],
      theme: ThemeData(
        fontFamily: "Vazirmatn",
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'حساب داری شخصی'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final box = objectbox.store.box<RecordEntityModel>();

  double totalIncome = 0;  // Variable to hold total income
  double totalExpense = 0; // Variable to hold total expense

  @override
  void initState() {
    super.initState();
    _calculateTotalAmounts();
  }

  // Method to calculate total income and expense
  void _calculateTotalAmounts() {
    totalIncome = 0;
    totalExpense = 0;

    // Iterate over all records and calculate totals
    for (var item in box.getAll()) {
      if (RecordEnumType.values[item.type] == RecordEnumType.income) {
        totalIncome += item.amount;
      } else if (RecordEnumType.values[item.type] == RecordEnumType.expense) {
        totalExpense += item.amount;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScreen(),
            ),
          ).then((_) {
            // Recalculate total amounts after adding a new record
            _calculateTotalAmounts();
          });
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مجموع درآمد: ${totalIncome.toStringAsFixed(0).seRagham()} تومان',

                ),
                Text(
                  'مجموع هزینه: ${totalExpense.toStringAsFixed(0).seRagham()} تومان',
                ),
              ],
            ),
          ),
          if (box.getAll().isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: box.getAll().length,
                itemBuilder: (BuildContext context, int index) {
                  var item = box.getAll()[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.title),
                      leading: Icon(
                        RecordEnumType.values[item.type] ==
                            RecordEnumType.expense
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: RecordEnumType.values[item.type] ==
                            RecordEnumType.expense
                            ? Colors.red
                            : Colors.green,
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.amount.toString().seRagham() + " تومان"),
                        ],
                      ),
                      trailing: Text(item.date.toPersianDate()),
                    ),
                  );
                },
              ),
            ),
          if (box.getAll().isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'هیچ تراکنشی ثبت نشده است.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
