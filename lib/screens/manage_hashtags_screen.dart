import 'dart:developer';

import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:md_financial/main.dart';
import 'package:md_financial/models/entities/hashtag_entity.dart';
import 'package:md_financial/objectbox.g.dart';

class ManageHashtagsScreen extends StatefulWidget {
  final bool isSelectorMode;
  final List<HashtagEntity>? preselectedHashtags;

  const ManageHashtagsScreen({
    Key? key,
    this.isSelectorMode = false,
    this.preselectedHashtags,
  }) : super(key: key);

  @override
  State<ManageHashtagsScreen> createState() => _ManageHashtagsScreenState();
}

class _ManageHashtagsScreenState extends State<ManageHashtagsScreen> {
  List<HashtagEntity> selectedHashtags = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelectorMode ? "انتخاب هشتگ‌ها" : "مدیریت هشتگ‌ها"),
        actions: widget.isSelectorMode
            ? [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, selectedHashtags); // Return selected hashtags
            },
          ),
        ]
            : null,
      ),
      body: HashtagListWidget(
        isSelectorMode: widget.isSelectorMode,
        preselectedHashtags: widget.preselectedHashtags,
        onHashtagsChanged: (hashtags) {
          setState(() {
            selectedHashtags = hashtags;
          });
        },
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
  final ValueChanged<List<HashtagEntity>>? onHashtagsChanged; // Callback

  const HashtagListWidget({
    Key? key,
    this.isSelectorMode = false,
    this.preselectedHashtags,
    this.onHashtagsChanged, // Pass the callback
  }) : super(key: key);

  @override
  State<HashtagListWidget> createState() => _HashtagListWidgetState();
}

class _HashtagListWidgetState extends State<HashtagListWidget> {
  List<HashtagEntity> allHashtags = [];
  List<HashtagEntity> selectedHashtags = <HashtagEntity>[];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedHashtags != null) {
      setState(() {
        selectedHashtags.addAll(widget.preselectedHashtags!);
      });
    }
    _loadHashtags();
  }

  void _loadHashtags() {
    final box = objectbox.store.box<HashtagEntity>();
    setState(() {
      allHashtags = box.getAll();
    });
  }

  void _onHashtagsChanged() {
    // Notify the parent widget of the selected hashtags
    if (widget.onHashtagsChanged != null) {
      widget.onHashtagsChanged!(selectedHashtags);
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
          leading: Checkbox(
            value: selectedHashtags.contains(hashtag),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  selectedHashtags.add(hashtag);
                } else {
                  selectedHashtags.remove(hashtag);
                }
              });
              _onHashtagsChanged(); // Call the callback to notify parent
            },
          ),
          trailing: widget.isSelectorMode
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
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
                },
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
                            final box = objectbox.store.box<HashtagEntity>();
                            box.remove(hashtag.id);
                            setState(() {
                              allHashtags.removeWhere((h) => h.id == hashtag.id);
                            });
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
                onPressed: () async {
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
                },
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
                            final box = objectbox.store.box<HashtagEntity>();
                            box.remove(hashtag.id);
                            setState(() {
                              allHashtags.removeWhere((h) => h.id == hashtag.id);
                            });
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
