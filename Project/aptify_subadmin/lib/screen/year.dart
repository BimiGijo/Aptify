import 'package:flutter/material.dart';
import 'package:aptify_subadmin/main.dart';

class Year extends StatefulWidget {
  const Year({super.key});

  @override
  State<Year> createState() => _YearState();
}

class _YearState extends State<Year> with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);

  int? _startYear;
  int? _endYear;

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
      if (_startYear == null || _endYear == null) {
        showSnackbar("Select both years", Colors.orange);
        return;
      }

      if (_endYear! <= _startYear!) {
        showSnackbar("End year must be greater than start year", Colors.red);
        return;
      }

      final yearName = '$_startYear - $_endYear';

      await supabase.from('tbl_year').insert({'year_name': yearName});

      fetchData();

      setState(() {
       _startYear = null;
        _endYear = null;
        _isFormVisible = false; 
      });
      
      showSnackbar('Year Added', Colors.green);
    } catch (e) {
      print("Error Inserting Year: $e");
      showSnackbar("Failed to add year", Colors.red);
    }
  }

  Future<void> yearDelete(int id) async {
    try {
      await supabase.from('tbl_year').delete().eq('year_id', id);
      await fetchData();
      showSnackbar('Year Deleted', Colors.red);
      setState(() {
        _startYear = null;
        _endYear = null;
      });
    } catch (e) {
      if (e.toString().contains('violates foreign key constraint')) {
        showSnackbar('This academic year is already in use elsewhere.', Colors.orange);
      } else {
        print('Error deleting year: $e');
        showSnackbar('An unexpected error occurred.', Colors.red);
      }
    }
  }

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _pickYear({required bool isStart}) async {
    final currentYear = DateTime.now().year;
    final picked = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isStart ? 'Select Start Year' : 'Select End Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              selectedDate: DateTime(isStart ? (_startYear ?? currentYear) : (_endYear ?? currentYear)),
              onChanged: (dateTime) {
                Navigator.pop(context, dateTime.year);
              },
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startYear = picked;
          _endYear = null;
        } else {
          if (_startYear != null && picked > _startYear!) {
            _endYear = picked;
          } else {
            showSnackbar("End year must be after $_startYear", Colors.red);
          }
        }
      });
    }
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
              const Text(
                'Academic Year',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF161616),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                ),
                onPressed: () {
                  setState(() {
                    _isFormVisible = !_isFormVisible;
                    if (!_isFormVisible) {
                      _startYear = null;
                      _endYear = null;
                    }
                  });
                },
                label: Text(
                  _isFormVisible ? "Cancel" : "Add",
                  style: const TextStyle(color: Colors.white),
                ),
                icon: Icon(
                  _isFormVisible ? Icons.cancel : Icons.add,
                  color: Colors.white,
                ),
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
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5)
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Add Academic Year",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          title: const Text("Start Year"),
                          subtitle: Text(
                            _startYear?.toString() ?? "Select start year",
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _pickYear(isStart: true),
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          title: const Text("End Year"),
                          subtitle: Text(
                            _endYear?.toString() ?? "Select end year",
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () {
                            if (_startYear == null) {
                              showSnackbar("Select start year first", Colors.orange);
                            } else {
                              _pickYear(isStart: false);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF161616),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 70, vertical: 18)),
                          onPressed: yearSubmit,
                          child: const Text('Add',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _yearList.isEmpty
                ? const Center(child: Text('No Academic Year Found'))
                : ListView.builder(
                    itemCount: _yearList.length,
                    itemBuilder: (context, index) {
                      final year = _yearList[index];
                      return Card(
                        child: ListTile(
                          title: Text(year['year_name']),
                          trailing: IconButton(
                            icon:
                                const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => yearDelete(year['year_id']),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
