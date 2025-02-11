import 'package:flutter/material.dart';
import 'package:aptify_admin/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final TextEditingController _categoryController = TextEditingController();
  List<Map<String, dynamic>> categoryList = [];
  int editId = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final data = await supabase.from('tbl_category').select();
      setState(() {
        categoryList = data.isNotEmpty ? data : [];
      });
    } catch (e) {
      print("Error fetching category: $e");
    }
  }

  Future<void> categorySubmit() async {
    try {
      String category = _categoryController.text.trim();
      if (category.isEmpty) return;
      await supabase.from('tbl_category').insert({'category_name': category});
      _categoryController.clear();
      fetchData();
    } catch (e) {
      print('Error Inserting Category: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_category').delete().eq('category_id', id);
      fetchData();
    } catch (e) {
      print('Error deleting data: $e');
    }
  }

  Future<void> update() async {
    try {
      if (_categoryController.text.trim().isEmpty) return;
      await supabase.from('tbl_category').update({
        'category_name': _categoryController.text.trim(),
      }).eq('category_id', editId);
      fetchData();
      setState(() {
        editId = 0;
        _categoryController.clear();
      });
    } catch (e) {
      print("Error updating category: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Manage Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isFormVisible = !_isFormVisible;
                  });
                },
                icon: Icon(_isFormVisible ? Icons.cancel : Icons.add),
                label: Text(_isFormVisible ? "Cancel" : "Add Category"),
              ),
            ],
          ),
          if (_isFormVisible)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Category',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: editId == 0 ? categorySubmit : update,
                        child: Text(editId == 0 ? 'Add' : 'Update'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: categoryList.isEmpty
                ? const Center(child: Text("No Categories Found"))
                : ListView.builder(
                    itemCount: categoryList.length,
                    itemBuilder: (context, index) {
                      final category = categoryList[index];
                      return Card(
                        child: ListTile(
                          title: Text(category['category_name']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  setState(() {
                                    editId = category['category_id'];
                                    _categoryController.text = category['category_name'];
                                    _isFormVisible = true;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  delete(category['category_id']);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
