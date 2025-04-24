import 'package:aptify_admin/main.dart';
import 'package:flutter/material.dart';

class AdminComplaintsPage extends StatefulWidget {
  const AdminComplaintsPage({super.key});

  @override
  State<AdminComplaintsPage> createState() => _AdminComplaintsPageState();
}

class _AdminComplaintsPageState extends State<AdminComplaintsPage> {
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;
  final Map<String, TextEditingController> _replyControllers = {};

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  // Fetch complaints and complainant names
  Future<void> fetchComplaints() async {
    try {
      // Fetch complaints
      final complaintResponse = await supabase
          .from('tbl_complaint')
          .select('id, created_at, complaint_title, complaint_content, complaint_reply, complaint_screenshot, complaint_status, teacher_id, student_id')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> complaintData = complaintResponse;

      // Fetch student names
      final studentResponse = await supabase
          .from('tbl_student')
          .select('student_id, student_name');
      final Map<String, String> studentNames = {
        for (var s in studentResponse) s['student_id']: s['student_name']
      };

      // Fetch teacher names
      final teacherResponse = await supabase
          .from('tbl_teacher')
          .select('teacher_id, teacher_name');
      final Map<String, String> teacherNames = {
        for (var t in teacherResponse) t['teacher_id']: t['teacher_name']
      };

      // Combine data
      final enrichedComplaints = complaintData.map((complaint) {
        final isTeacher = complaint['teacher_id'] != null;
        final complainantId = isTeacher ? complaint['teacher_id'] : complaint['student_id'];
        final complainantName = isTeacher
            ? (teacherNames[complainantId] ?? 'Unknown Teacher')
            : (studentNames[complainantId] ?? 'Unknown Student');
        return {
          ...complaint,
          'complainant_name': complainantName,
          'complainant_type': isTeacher ? 'Teacher' : 'Student',
        };
      }).toList();

      // Initialize reply controllers
      for (var complaint in enrichedComplaints) {
        _replyControllers[complaint['id'].toString()] = TextEditingController(
          text: complaint['complaint_reply'] ?? '',
        );
      }

      setState(() {
        complaints = enrichedComplaints;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching complaints: $e')),
      );
    }
  }

  // Submit or update a reply
  Future<void> submitReply(String complaintId, String reply) async {
    try {
      await supabase.from('tbl_complaint').update({
        'complaint_reply': reply,
        'complaint_status': '1', // Mark as resolved
      }).eq('id', complaintId);

      // Update local state
      setState(() {
        final index = complaints.indexWhere((c) => c['id'].toString() == complaintId);
        if (index != -1) {
          complaints[index]['complaint_reply'] = reply;
          complaints[index]['complaint_status'] = '1';
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting reply: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Complaints',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
              ? const Center(child: Text('No complaints found'))
              : RefreshIndicator(
                  onRefresh: fetchComplaints,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = complaints[index];
                      final controller = _replyControllers[complaint['id'].toString()];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Complainant Info
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${complaint['complainant_name']} (${complaint['complainant_type']})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    complaint['complaint_status'] == 0 ? 'Pending' : 'Resolved',
                                    style: TextStyle(
                                      color: complaint['complaint_status'] == 0
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Complaint Details
                              Text(
                                'Title: ${complaint['complaint_title']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Content: ${complaint['complaint_content']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Date: ${DateTime.parse(complaint['created_at']).toLocal().toString().split('.')[0]}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              // Screenshot
                              if (complaint['complaint_screenshot'] != null)
                                GestureDetector(
                                  onTap: () {
                                    // Open screenshot in a dialog or external browser
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: Image.network(
                                          complaint['complaint_screenshot'],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(complaint['complaint_screenshot']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              // Reply Section
                              TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: 'Reply',
                                  border: const OutlineInputBorder(),
                                  hintText: 'Enter your reply here',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                maxLines: 3,
                                enabled: complaint['complaint_status'] == 0,
                              ),
                              const SizedBox(height: 8),
                              if (complaint['complaint_status'] == 0)
                                ElevatedButton(
                                  onPressed: () {
                                    final reply = controller!.text;
                                    if (reply.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Reply cannot be empty')),
                                      );
                                      return;
                                    }
                                    submitReply(complaint['id'].toString(), reply);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Submit Reply'),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _replyControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}