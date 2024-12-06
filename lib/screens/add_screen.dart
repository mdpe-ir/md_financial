import 'package:filter_list/filter_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:md_financial/enums/record_enum.dart';
import 'package:md_financial/main.dart';
import 'package:md_financial/models/entities/hashtag_entity.dart';
import 'package:md_financial/models/entities/record_entity_model.dart';
import 'package:md_financial/screens/manage_hashtags_screen.dart';
import 'package:md_financial/utils/convertor.dart';
import 'package:md_financial/widgets/form_field_widget.dart';
import 'package:objectbox/objectbox.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  List<HashtagEntity> selectedHashtags = [];
  List<HashtagEntity> allHashtags = [];

  TextEditingController selectedDateController = TextEditingController();
  TextEditingController typeController = TextEditingController();

  RecordEnumType recordEnumType = RecordEnumType.unknown;
  Jalali picked = Jalali.now();
  String title = "";
  String description = "";
  String amount = "";
  String selectedDate = "";

  Future<void> showHashtagPicker() async {
    final box = objectbox.store.box<HashtagEntity>();
    allHashtags = box.getAll();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageHashtagsScreen(),
      ),
    );

    final List<HashtagEntity>? result =
        await FilterListDialog.display<HashtagEntity>(
      context,
      listData: allHashtags,
      selectedListData: selectedHashtags,
      choiceChipLabel: (item) => item?.name ?? '',
      onItemSearch: (item, query) =>
          item.name.toLowerCase().contains(query.toLowerCase()),
      onApplyButtonClick: (selected) {
        setState(() {
          selectedHashtags = selected ?? [];
        });
      },
      validateSelectedItem: (list, val) => list!.contains(val),
    );

    if (result != null) {
      setState(() => selectedHashtags = result);
    }
  }

  Future<void> showTypeModalBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Material(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () => {
                  setState(() => recordEnumType = RecordEnumType.income),
                  Navigator.of(context).pop()
                },
                iconColor: Colors.green,
                splashColor: Colors.green,
                leading: Icon(Icons.payments),
                title: Text("درآمد"),
              ),
              ListTile(
                onTap: () => {
                  setState(() => recordEnumType = RecordEnumType.expense),
                  Navigator.of(context).pop()
                },
                iconColor: Colors.red,
                splashColor: Colors.red,
                leading: Icon(Icons.paid),
                title: Text("هزینه"),
              ),
            ],
          ),
        );
      },
    );

    setState(() {
      typeController.text = Convertor.typeToString(recordEnumType);
    });
  }

  Future<void> save() async {
    final recordBox = objectbox.store.box<RecordEntityModel>();
    final hashtagBox = objectbox.store.box<HashtagEntity>();

    // Save new hashtags to the database
    for (final hashtag in selectedHashtags) {
      if (hashtag.id == 0) {
        hashtagBox.put(hashtag);
      }
    }

    // Save record with hashtags
    final record = RecordEntityModel(
      type: recordEnumType.index,
      amount: int.parse(amount.replaceAll(",", "")),
      title: title,
      description: description,
      date: picked.toDateTime(),
      hashtags: ToMany<HashtagEntity>(items: selectedHashtags),
    );

    await recordBox.putAsync(record);
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
                    ) ??
                    Jalali.now();
                setState(() {
                  selectedDate = picked.formatFullDate() ?? "";
                  selectedDateController.text = selectedDate;
                });
              },
            ),
            FormFieldWidget(
              prefixIcon: Convertor.typeToIcon(recordEnumType),
              controller: typeController,
              label: "نوع",
              isReadOnly: true,
              onTap: showTypeModalBottomSheet,
            ),
            FormFieldWidget(
              label: "هشتگ‌ها",
              isReadOnly: true,
              onTap: showHashtagPicker,
              value: selectedHashtags.map((e) => e.name).join(', '),
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
