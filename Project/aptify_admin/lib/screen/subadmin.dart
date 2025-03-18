import 'package:flutter/material.dart';
import 'package:aptify_admin/main.dart';


class SubAdmin extends StatefulWidget {
  @override
  _SubAdminState createState() => _SubAdminState();
}

class _SubAdminState extends State<SubAdmin> with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<Map<String, dynamic>> _subadminList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> register() async {
    try {
      final auth = await supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text
        );
      final uid = auth.user!.id;
      if(uid.isNotEmpty || uid != "") {
        submitForm(uid);
      }
    } catch (e) {
        print("Authentication Error: $e");
    }
  }

  Future<void> submitForm(String uid) async {
    try {
      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
  
  await supabase.from('tbl_subadmin').insert(
    {'subadmin_id': uid,
      'subadmin_name': name,
      'subadmin_email': email,
      'subadmin_password': password
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        'Sub-Admin Added',
        style: TextStyle(color: Colors.white)
        ),
        backgroundColor: Colors.green
        ));
        fetchData();
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
} catch (e) {
  print('Error inserting data: $e');
}
      
  }

Future<void> fetchData() async {
  try {
    final response = await supabase.from('tbl_subadmin').select();
    setState(() {
      _subadminList= response;
    });
  } catch (e) {
      print('Error fetching data: $e');
  }
}
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Manage Colleges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF161616),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18)
                    ),
                    onPressed: () {
                      setState(() {
                        _isFormVisible = !_isFormVisible;
                        /*if (!_isFormVisible) {
                          _editId = 0;
                          _nameController.clear();
                          _emailController.clear();
                          _passwordController.clear();
                    }*/
                      });
                    },
                    label: Text(_isFormVisible ? "Cancel" : "Add", style: TextStyle(color: Colors.white)),
                    icon: Icon(_isFormVisible ? Icons.cancel : Icons.add, color: Colors.white)
                    )
                ],
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
                        Text('Add College', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Name",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.account_box)
                          ),                        
                          validator: (value) => value!.isEmpty ? "Please enter your name" : null,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: "Email",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email)
                          ),                            
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: "Password",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.remove_red_eye)),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF161616), padding: EdgeInsets.symmetric(horizontal: 70, vertical: 18)
                          ),
                          onPressed: register,
                          child: Text("Add", style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                  )
                  :Container()
                ), 
                Expanded(
                  child: _subadminList.isEmpty
                    ? Center(child: Text("No Colleges Added"))
                    : ListView.builder(
                        itemCount: _subadminList.length,
                        itemBuilder: (context, index) {
                          final subAdmin = _subadminList[index];
                          return Card(
                            child: ListTile(
                            title: Text(subAdmin['subadmin_name']),
                            subtitle: Text(subAdmin['subadmin_email']),                            
                          )
                        );
                        }
                      ),
                  )          
            ],
          ),
        ),
      ),
    );
  }
}
