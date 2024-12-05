import 'package:flutter/material.dart';
import 'package:md_financial/enums/record_enum.dart';
import 'package:md_financial/main.dart';
import 'package:md_financial/models/entities/record_entity_model.dart';
import 'package:md_financial/widgets/form_field_widget.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  TextEditingController selectedDateController = TextEditingController();

  RecordEnumType recordEnumType = RecordEnumType.expense;
  Jalali picked = Jalali.now();
  String title = "";
  String description = "";
  String amount = "";
  String selectedDate = "";

  Future<void> save() async {
    final box = objectbox.store.box<RecordEntityModel>();
    await box.putAsync(RecordEntityModel(
      type: recordEnumType.index,
      amount: int.parse(amount.replaceAll(",", "")),
      title: title,
      description: description,
      date: picked!.toDateTime(),
    ));
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedDate = picked?.formatFullDate() ?? "";
    selectedDateController.text = selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("افزودن تراکنش جدید"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            FormFieldWidget(
              label: "عنوان",
              onChanged: (p0) {
                setState(() => title = p0);
              },
            ),
            FormFieldWidget(
              label: "توضیحات",
              minLines: 2,
              maxLines: 5,
              onChanged: (p0) {
                setState(() => description = p0);
              },
            ),
            FormFieldWidget(
              controller: selectedDateController,
              label: "تاریخ",
              isReadOnly: true,
              onTap: () async {
                picked = await showPersianDatePicker(
                  context: context,
                  initialDate: Jalali.now(),
                  firstDate: Jalali(1385, 8),
                  lastDate: Jalali(1450, 9),
                  initialEntryMode: PersianDatePickerEntryMode.calendarOnly,
                  initialDatePickerMode: PersianDatePickerMode.day,
                ) ?? Jalali.now();
                setState(() {
                  selectedDate = picked?.formatFullDate() ?? "";
                  selectedDateController.text = selectedDate;
                });
              },
            ),
            FormFieldWidget(
              label: "مقدار",
              suffix: Text("تومان"),
              inputFormatters: [ThousandsFormatter()],
              onChanged: (p0) {
                setState(() => amount = p0);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(amount.toWord()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: ToggleSwitch(
                      minWidth: 130.0,
                      centerText: true,
                      initialLabelIndex: 1,
                      cornerRadius: 15.0,
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      totalSwitches: 2,
                      labels: ['درآمد', 'هزینه'],
                      icons: [Icons.payment, Icons.payment],
                      activeBgColors: [
                        [Colors.green],
                        [Colors.red]
                      ],
                      onToggle: (index) {
                        if (index == 1) recordEnumType = RecordEnumType.expense;
                        if (index == 0) recordEnumType = RecordEnumType.income;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  onPressed: save,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("ذخیره"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
