import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:md_financial/main.dart';
import 'package:md_financial/models/entities/hashtag_entity.dart';
import 'package:md_financial/models/entities/record_entity_model.dart';
import 'package:md_financial/objectbox.g.dart';

class ManageHashtagsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("مدیریت هشتگ‌ها")),
      body: HashtagListWidget(), // Implement a list widget for hashtags
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final TextEditingController controller = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("اضافه کردن هشتگ"),
                content: TextField(controller: controller),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: Text("لغو"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: Text("اضافه کردن"),
                  ),
                ],
              );
            },
          );

          if (result != null && result.isNotEmpty) {
            final box = objectbox.store.box<HashtagEntity>();
            box.put(HashtagEntity(name: result));
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class HashtagListWidget extends StatefulWidget {
  const HashtagListWidget({super.key});

  @override
  State<HashtagListWidget> createState() => _HashtagListWidgetState();
}

class _HashtagListWidgetState extends State<HashtagListWidget> {
  List<HashtagEntity> record = [];
  List<String> allHashtags = []; // Available hashtags
  List<String> selectedHashtags =
      []; // Selected hashtags for the current record

  @override
  void initState() {
    super.initState();
    // Load existing hashtags from the database and initialize them
    _loadHashtags();
  }

  void _loadHashtags() {
    final box = objectbox.store.box<HashtagEntity>();
    record = box.getAll();
    final hashtagBox = objectbox.store.box<HashtagEntity>();
    final allTags = hashtagBox.getAll().map((e) => e.name).toList();
    final recordTags = record.map((e) => e.name).toList();

    setState(() {
      allHashtags = allTags;
      selectedHashtags = recordTags;
    });
  }

  Future<void> _openFilterDialog() async {
    await FilterListDialog.display<String>(
      context,
      listData: allHashtags,
      selectedListData: selectedHashtags,
      onApplyButtonClick: (list) {
        if (list != null) {
          setState(() {
            selectedHashtags = List<String>.from(list);
          });
          _updateRecordHashtags();
        }
      },
      onItemSearch: (item, query) =>
          item.toLowerCase().contains(query.toLowerCase()),
      choiceChipLabel: (item) => item,
      validateSelectedItem: (list, item) => list!.contains(item),
      hideSearchField: true,
    );
  }

  void _updateRecordHashtags() {
    final hashtagBox = objectbox.store.box<HashtagEntity>();

    // Find or create hashtags in the database
    final updatedTags = selectedHashtags.map((tagName) {
      final existingTag = hashtagBox
          .query(HashtagEntity_.name.equals(tagName))
          .build()
          .findFirst();
      return existingTag ?? HashtagEntity(name: tagName);
    }).toList();

    // Update the record's hashtags
    record.clear();
    record.addAll(updatedTags);
    objectbox.store.box<HashtagEntity>().putMany(record);
  }

  void _addNewHashtag(String name) {
    final hashtagBox = objectbox.store.box<HashtagEntity>();
    final newTag = HashtagEntity(name: name);

    hashtagBox.put(newTag);
    setState(() {
      allHashtags.add(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Hashtags", style: Theme.of(context).textTheme.bodyLarge),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _AddHashtagDialog(onAdd: _addNewHashtag),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: selectedHashtags
              .map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () {
                      setState(() {
                        selectedHashtags.remove(tag);
                        _updateRecordHashtags();
                      });
                    },
                  ))
              .toList(),
        ),
        ElevatedButton(
          onPressed: _openFilterDialog,
          child: const Text("Manage Hashtags"),
        ),
      ],
    );
  }
}

class _AddHashtagDialog extends StatefulWidget {
  final Function(String) onAdd;

  const _AddHashtagDialog({super.key, required this.onAdd});

  @override
  State<_AddHashtagDialog> createState() => _AddHashtagDialogState();
}

class _AddHashtagDialogState extends State<_AddHashtagDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Hashtag"),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: "Enter hashtag"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onAdd(_controller.text);
            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}

class FilterListCloseButton extends StatelessWidget {
  final VoidCallback? onClose;

  const FilterListCloseButton({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onClose ?? () => Navigator.of(context).pop(),
      child: const Text(
        "Close",
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}
