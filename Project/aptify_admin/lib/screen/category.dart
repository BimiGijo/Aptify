import 'package:flutter/material.dart';
import 'package:aptify_admin/main.dart';


class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  List<Map<String, dynamic>> _categoryList = [];
  int _editId = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        _categoryList = response;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> categorySubmit() async {
    try {
      String category = _categoryController.text.trim();
      String link = _linkController.text.trim();
      if (category.isEmpty) return;

      await supabase.from('tbl_category').insert({
        'category_name': category,
        'category_link': link
      });
      fetchData();
      _categoryController.clear();
      _linkController.clear();
      showSnackbar('Category Added', const Color(0xFF14213D));
    } catch (e) {
      print('Error inserting category: $e');
    }
  }

  Future<void> updateCategory() async {
    try {
      if (_categoryController.text.trim().isEmpty) return;
      await supabase.from('tbl_category').update({
        'category_name': _categoryController.text.trim(),
        'category_link': _linkController.text.trim()
      }).eq('category_id', _editId);
      fetchData();
      showSnackbar('Category Updated', const Color(0xFF14213D));
      setState(() {
        _editId = 0;
        _categoryController.clear();
        _linkController.clear();
      });
    } catch (e) {
      print("Error updating category: $e");
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await supabase.from('tbl_category').delete().eq('category_id', id);
      fetchData();
      showSnackbar('Category Deleted', const Color(0xFF14213D));
      setState(() {
        _editId = 0;
        _categoryController.clear();
        _linkController.clear();
      });
    } catch (e) {
      print("Error deleting category: $e");
    }
  }

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CATEGORY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF161616),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18)),
                onPressed: () {
                  setState(() {
                    _isFormVisible = !_isFormVisible;
                    if (!_isFormVisible) {
                      _editId = 0;
                      _categoryController.clear();
                      _linkController.clear();
                    }
                  });
                },
                label: Text(_isFormVisible ? "Cancel" : "Add", style: const TextStyle(color: Colors.white)),
                icon: Icon(_isFormVisible ? Icons.cancel : Icons.add, color: Colors.white),
              )
            ],
          ),
          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            child: _isFormVisible
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5)],
                    ),
                    child: Column(
                      children: [
                        Text(_editId == 0 ? "Add Category" : "Edit Category", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _linkController,
                          decoration: const InputDecoration(
                            labelText: 'Category API Link',
                            border: OutlineInputBorder()
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF161616), padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 18)),
                          onPressed: _editId == 0 ? categorySubmit : updateCategory,
                          child: Text(_editId == 0 ? 'Add' : 'Update', style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          Expanded(
            child: _categoryList.isEmpty
                ? const Center(child: Text("No Categories Found"))
                : ListView.builder(
                    itemCount: _categoryList.length,
                    itemBuilder: (context, index) {
                      final category = _categoryList[index];
                      return Card(
                        child: ListTile(
                          title: Text(category['category_name']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    _editId = category['category_id'];
                                    _categoryController.text = category['category_name'];
                                    _linkController.text = category['category_link'];
                                    _isFormVisible = true;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteCategory(category['category_id']),
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
