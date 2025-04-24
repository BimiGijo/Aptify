import 'dart:io';
import 'package:aptify_student/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For formatting date

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    setState(() => isLoading = true);
    try {
      final uid = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_complaint')
          .select()
          .eq('student_id', uid)
          .order('created_at', ascending: false);

      setState(() {
        complaints = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching complaints: $e')),
      );
    }
  }

  Future<void> showAddComplaintDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    File? screenshot;
    final picker = ImagePicker();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Report an Issue'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(labelText: 'Content'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            setState(() {
                              screenshot = File(picked.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text('Add Screenshot'),
                      ),
                      const SizedBox(width: 10),
                      if (screenshot != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        setState(() => isSubmitting = true);
                        String? screenshotUrl;
                        if (screenshot != null) {
                          final fileName = 'complaint_${DateTime.now().millisecondsSinceEpoch}.jpg';
                          final bytes = await screenshot!.readAsBytes();
                          await supabase.storage.from('complaints').uploadBinary(fileName, bytes);
                          screenshotUrl = supabase.storage.from('complaints').getPublicUrl(fileName);
                        }
                        final uid = supabase.auth.currentUser!.id;
                        await supabase.from('tbl_complaint').insert({
                          'complaint_title': titleController.text.trim(),
                          'complaint_content': contentController.text.trim(),
                          'complaint_screenshot': screenshotUrl ?? '',
                          'complaint_status': 0,
                          'student_id': uid,
                        });
                        Navigator.pop(context);
                        fetchComplaints();
                      },
                child: isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildComplaintCard(Map<String, dynamic> complaint) {
    final status = complaint['complaint_status'] == 1 ? 'Resolved' : 'Pending';
    final statusColor = complaint['complaint_status'] == 1 ? Colors.green : Colors.orange;
    final createdAt = complaint['created_at'] != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(complaint['created_at']))
        : '';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(complaint['complaint_title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(createdAt, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Text(complaint['complaint_content'] ?? ''),
            if ((complaint['complaint_screenshot'] ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.network(complaint['complaint_screenshot'], height: 120),
              ),
            const SizedBox(height: 8),
            if ((complaint['complaint_reply'] ?? '').isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Reply: ${complaint['complaint_reply']}'),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: statusColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        actions: [
          TextButton(
            onPressed: showAddComplaintDialog,
            child: const Text("Report an Issue", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
              ? const Center(child: Text('No complaints found.'))
              : ListView.builder(
                  itemCount: complaints.length,
                  itemBuilder: (context, index) => buildComplaintCard(complaints[index]),
                ),
    );
  }
}