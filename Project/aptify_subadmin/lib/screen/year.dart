import 'package:flutter/material.dart';
import 'package:aptify_subadmin/main.dart';

class Year extends StatefulWidget {
  const Year({super.key});

  @override
  State<Year> createState() => _YearState();
}

class _YearState extends State<Year> with SingleTickerProviderStateMixin{
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(microseconds: 300);
  final TextEditingController _yearController = TextEditingController();
  List<Map<String, dynamic>> _yearList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await supabase.from('tbl_year').select();
      setState(() {
        _yearList = response;
      });

    } catch (e) {
        print('Error Fetching Year: $e');
    }
  }
  
  Future<void> yearSubmit() async {
    try {
      String year = _yearController.text.trim();
      if(year.isEmpty) return;

      await supabase.from('tbl_year').insert({'year_name':year});

      fetchData();
      _yearController.clear();
      showSnackbar('Year Added', Colors.green);
    } catch (e) {
        print("Error Inserting Year: $e");
    }
  }

  Future<void> yearDelete(int id) async {
    try {
      await supabase.from('tbl_year').delete().eq('year_id', id);
      fetchData();
      showSnackbar('Year Deleted', Colors.red);
      setState(() {
        _yearController.clear();
      });
    } catch (e) {
      print('Error deleting year: $e');      
    }
  }

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.white)), backgroundColor: color),
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
              Text('Manage Academic Year', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF161616),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18)
                ),
                onPressed: (){
                  setState(() {
                    _isFormVisible = !_isFormVisible;
                    if(!_isFormVisible) {
                      _yearController.clear();
                    }
                  });
                }, 
                label: Text(_isFormVisible? "Cancel" : "Add", style: TextStyle(color: Colors.white,)),
                icon: Icon(_isFormVisible ? Icons.cancel : Icons.add, color: Colors.white)
              )
            ]
          ),
          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            child: _isFormVisible
                ? Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5)],
                    ),
                    child: Column(
                      children: [
                        Text("Add Year" , style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _yearController,
                          decoration: InputDecoration(
                            hintText: 'Academic Year',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF161616), padding: EdgeInsets.symmetric(horizontal: 70, vertical: 18)),
                          onPressed: yearSubmit,
                          child: Text('Add', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          Expanded(
            child: _yearList.isEmpty
                  ? Center(child: Text('No Academic Year Found'))
                  : ListView.builder(
                      itemCount: _yearList.length,
                      itemBuilder: (context,index) {
                        final year = _yearList[index];
                        return Card(
                          child: ListTile(
                            title: Text(year['year_name']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: ()=>yearDelete(year['year_id']))
                              ],
                            ),
                          ),
                        );
                      } 
                    )        
          )
        ],
      ),);
  }
}