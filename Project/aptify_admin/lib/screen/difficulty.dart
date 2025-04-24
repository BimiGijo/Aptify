import 'package:flutter/material.dart';
import 'package:aptify_admin/main.dart';

class Difficulty extends StatefulWidget {
  const Difficulty({super.key});

  @override
  State<Difficulty> createState() => _DifficultyState();
}

class _DifficultyState extends State<Difficulty> with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  List<Map<String, dynamic>> _difficultyList = [];
  int _editId = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> difficultySubmit() async {
    try {
      String name = _nameController.text.trim().toLowerCase();
      String count = _countController.text.trim();

      if (name.isEmpty || count.isEmpty) return;

      final difficultyName = await supabase
        .from('tbl_difficulty')
        .select('difficulty_name');

      final isDuplicate = difficultyName.any((c) => 
        c['difficulty_name'].toString().trim().toLowerCase() == name );

      if (isDuplicate) {
        showSnackbar("Difficulty level already exists", Colors.orange);
        return;
      }

      await supabase.from('tbl_difficulty').insert({
        'difficulty_name': name,
        'qn_count': int.parse(count), // Ensure count is an integer
      });

      fetchData(); 

      setState(() {
        _nameController.clear();
        _countController.clear();
        _isFormVisible = false;
      });

      showSnackbar('Difficulty Level Added Successfully', Colors.green);
    } catch (e) {
      print('Error inserting data: $e');
      showSnackbar('Error adding difficulty $e', Colors.red);
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await supabase.from('tbl_difficulty').select();
      setState(() {
        _difficultyList = response;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> updateDifficulty() async {
    try {
      if(_nameController.text.trim().isEmpty || _editId ==0) return;

      await supabase.from('tbl_difficulty').update({
       'difficulty_name' : _nameController.text.trim(),
       'qn_count' : _countController.text.trim() 
      }).eq('difficulty_id', _editId);

      await fetchData();
      showSnackbar("Difficulty Level Updated", Colors.green);

      setState(() {
        _editId = 0;
        _nameController.clear();
        _isFormVisible = false;
      });
    } catch (e) {
      print("Error updating difficulty level $e");
    }
  }

  Future<void> deleteDifficulty(int id) async {
    try {
      await supabase.from('tbl_difficulty')
      .delete()
      .eq('difficulty_id', id);

      await fetchData();
      showSnackbar("Difficulty Level Deleted", Colors.red);

      setState(() {
        if(_editId == id) {
          _editId = 0;
          _nameController.clear();
          _countController.clear();
        }
      });
    } catch (e) {
      showSnackbar("Unexpected Error Occured", Colors.red);
      print("Error Occured $e");
    }
  }

  void populateFormEdit(Map<String, dynamic> name) {
    setState(() {
      _editId = name['difficulty_id'];
      _nameController.text = name['difficulty_name'];
      _countController.text = name['qn_count'];
      _isFormVisible = true;
    });
  }

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
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
              const Text('MANAGE DIFFICULTY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF161616),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    padding:
                       const EdgeInsets.symmetric(horizontal: 25, vertical: 18)),
                onPressed: () {
                  setState(() {
                    _isFormVisible = !_isFormVisible;
                    if (!_isFormVisible) {
                      _editId = 0;
                      _nameController.clear();
                    }
                  });
                }, 
                label: Text(_isFormVisible ? "Cancel" : "Add",
                        style: TextStyle(color: Colors.white)),
                icon: Icon(_isFormVisible ? Icons.cancel : Icons.add,
                      color: Colors.white),
                )
            ]  
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        )
                      ]
                    ),
                    child: Column(
                      children: [
                        Text(
                          _editId == 0 ? "Add" : "Update",
                          style:  const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Difficulty Level',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category)
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _countController,
                          decoration: const InputDecoration(
                           labelText: 'Question Count',
                           border: OutlineInputBorder(), 
                          )
                        ),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF161616),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 70, vertical: 18)),
                          onPressed: _editId == 0 ? difficultySubmit : updateDifficulty, 
                          child: Text(_editId == 0 ? "Add" : "Update",
                                  style: const TextStyle(color: Colors.white)
                                )
                        )
                      ],
                    ),
                  )
                :Container()
            ),
            Expanded(
              child: _difficultyList.isEmpty
                    ? Center(child: Text("No Data Added"))
                    : ListView.builder(
                        itemCount: _difficultyList.length,
                        itemBuilder: (context, index) {
                          final difficulty = _difficultyList[index];
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: Icon(Icons.star),
                              title: Text(difficulty['difficulty_name'], style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Questions: ${difficulty['qn_count']}'),
                            ),
                      );
                    },)
            
            )
        ],
      )

          
                  
      ); 
  }
}
