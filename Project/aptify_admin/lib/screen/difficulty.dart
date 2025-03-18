import 'package:flutter/material.dart';
import 'package:aptify_admin/main.dart';

class Difficulty extends StatefulWidget {
  const Difficulty({super.key});

  @override
  State<Difficulty> createState() => _DifficultyState();
}

class _DifficultyState extends State<Difficulty> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  List<Map<String, dynamic>> _difficultyList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> difficultySubmit() async {
    try {
      String name = _nameController.text.trim();
      String count = _countController.text.trim();
      if (name.isEmpty || count.isEmpty) return;

      await supabase.from('tbl_difficulty').insert({
        'difficulty_name': name,
        'qn_count': int.parse(count), // Ensure count is an integer
      });

      _nameController.clear();
      _countController.clear();
      fetchData(); 
      showSnackbar('Difficulty Added Successfully', Colors.green);
    } catch (e) {
      print('Error inserting data: $e');
      showSnackbar('Error adding difficulty', Colors.red);
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

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
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
          Text('MANAGE DIFFICULTY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Column(
            children: [
              SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Difficulty Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _countController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Question Count',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF161616),
                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 18),
                ),
                onPressed: difficultySubmit,
                child: Text('Add', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _difficultyList.isEmpty
                ? Center(child: Text('No data'))
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
