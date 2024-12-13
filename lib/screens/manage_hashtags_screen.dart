import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:md_financial/main.dart';
import 'package:md_financial/models/entities/hashtag_entity.dart';
import 'package:md_financial/objectbox.g.dart';

class ManageHashtagsScreen extends StatelessWidget {
  final bool isSelectorMode;
  final List<HashtagEntity>? preselectedHashtags;

  const ManageHashtagsScreen({
    Key? key,
    this.isSelectorMode = false,
    this.preselectedHashtags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectorMode ? "انتخاب هشتگ‌ها" : "مدیریت هشتگ‌ها"),
        actions: isSelectorMode
            ? [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    final selectedHashtags =
                        HashtagListWidget.getSelectedHashtags();
                    Navigator.pop(context, selectedHashtags);
                  },
                ),
              ]
            : null,
      ),
      body: HashtagListWidget(
        isSelectorMode: isSelectorMode,
        preselectedHashtags: preselectedHashtags,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final TextEditingController controller = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("اضافه کردن هشتگ"),
                content: TextField(
                  controller: controller,
                  decoration:
                      const InputDecoration(hintText: "نام هشتگ را وارد کنید"),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text("لغو"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: const Text("اضافه کردن"),
                  ),
                ],
              );
            },
          );

          if (result != null && result.trim().isNotEmpty) {
            final box = objectbox.store.box<HashtagEntity>();

            // Check for duplicates
            final existing = box
                .query(HashtagEntity_.name.equals(result.trim()))
                .build()
                .findFirst();

            if (existing == null) {
              box.put(HashtagEntity(name: result.trim()));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text("هشتگ '${result.trim()}' با موفقیت اضافه شد.")),
              );
              HashtagListWidget.reloadHashtags();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text("هشتگ '${result.trim()}' قبلا اضافه شده است.")),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HashtagListWidget extends StatefulWidget {
  final bool isSelectorMode;
  final List<HashtagEntity>? preselectedHashtags;

  const HashtagListWidget({
    Key? key,
    this.isSelectorMode = false,
    this.preselectedHashtags,
  }) : super(key: key);

  static final _selectedHashtags = <HashtagEntity>[];

  static List<HashtagEntity> getSelectedHashtags() => _selectedHashtags;

  static Function? reloadHashtagsCallback;

  static void reloadHashtags() {
    if (reloadHashtagsCallback != null) reloadHashtagsCallback!();
  }


  @override
  State<HashtagListWidget> createState() => _HashtagListWidgetState();
}

class _HashtagListWidgetState extends State<HashtagListWidget> {
  List<HashtagEntity> allHashtags = [];

  @override
  void initState() {
    super.initState();
    _loadHashtags();
    HashtagListWidget.reloadHashtagsCallback = _loadHashtags;
    if (widget.preselectedHashtags != null) {
      HashtagListWidget._selectedHashtags.addAll(widget.preselectedHashtags!);
    }
  }

  void _loadHashtags() {
    final box = objectbox.store.box<HashtagEntity>();
    setState(() {
      allHashtags = box.getAll();
    });
  }


  void _deleteHashtag(int id) {
    final box = objectbox.store.box<HashtagEntity>();
    box.remove(id);
    setState(() {
      allHashtags.removeWhere((hashtag) => hashtag.id == id);
    });
  }


  void _editHashtag(HashtagEntity hashtag) async {
    final controller = TextEditingController(text: hashtag.name);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("ویرایش هشتگ"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "ویرایش نام هشتگ"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("لغو"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("ذخیره"),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty && result != hashtag.name) {
      final box = objectbox.store.box<HashtagEntity>();
      hashtag.name = result;
      box.put(hashtag);
      _loadHashtags();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allHashtags.isEmpty) {
      return const Center(child: Text("هیچ هشتگی وجود ندارد."));
    }

    return ListView.builder(
      itemCount: allHashtags.length,
      itemBuilder: (context, index) {
        final hashtag = allHashtags[index];
        return ListTile(
          title: Text(hashtag.name),
          onTap: () {
            if (widget.isSelectorMode) {
              bool value =
                  !HashtagListWidget._selectedHashtags.contains(hashtag);
              setState(() {
                if (value == true) {
                  HashtagListWidget._selectedHashtags.add(hashtag);
                } else {
                  HashtagListWidget._selectedHashtags.remove(hashtag);
                }
              });
            }
          },
          leading: Checkbox(
            value: HashtagListWidget._selectedHashtags.contains(hashtag),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  HashtagListWidget._selectedHashtags.add(hashtag);
                } else {
                  HashtagListWidget._selectedHashtags.remove(hashtag);
                }
              });
            },
          ),
          trailing: widget.isSelectorMode
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editHashtag(hashtag),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("حذف هشتگ"),
                            content: Text(
                                "آیا مطمئن هستید که می‌خواهید هشتگ '${hashtag.name}' را حذف کنید؟"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("لغو"),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteHashtag(hashtag.id);
                                  Navigator.pop(context);
                                },
                                child: const Text("حذف"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editHashtag(hashtag),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("حذف هشتگ"),
                            content: Text(
                                "آیا مطمئن هستید که می‌خواهید هشتگ '${hashtag.name}' را حذف کنید؟"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("لغو"),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteHashtag(hashtag.id);
                                  Navigator.pop(context);
                                },
                                child: const Text("حذف"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}
