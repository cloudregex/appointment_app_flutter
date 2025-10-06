import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helper/api_helper.dart';
import 'add_tpr_screen.dart';
import 'edit_tpr_screen.dart';

class TPRListScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const TPRListScreen({super.key, required this.patient});

  @override
  _TPRListScreenState createState() => _TPRListScreenState();
}

class _TPRListScreenState extends State<TPRListScreen> {
  late Future<Map<String, dynamic>> _tprData;

  @override
  void initState() {
    super.initState();
    _tprData = _fetchTPRRecords();
  }

  Future<Map<String, dynamic>> _fetchTPRRecords() async {
    return await ApiHelper.request('tpr?ipdNo=${widget.patient['IPDNO']}');
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return 'Unknown Date';
    if (rawDate is String) {
      if (rawDate.isEmpty) return 'Unknown Date';
      try {
        final parsed = DateTime.parse(rawDate);
        return DateFormat('dd-MM-yyyy').format(parsed);
      } catch (_) {
        return rawDate;
      }
    }
    if (rawDate is DateTime) {
      return DateFormat('dd-MM-yyyy').format(rawDate);
    }
    return rawDate.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patient['Name']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTPRScreen(patient: widget.patient),
                ),
              ).then((_) {
                setState(() {
                  _tprData = _fetchTPRRecords();
                });
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _tprData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              (snapshot.data!['data'] as List).isEmpty) {
            return const Center(child: Text('No TPR records found.'));
          } else {
            final tprRecords = snapshot.data!['data'] as List;
            return ListView.builder(
              itemCount: tprRecords.length,
              itemBuilder: (context, index) {
                final record = tprRecords[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${record['Date']} - Time: ${record['Time']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        _buildDetailRow(
                          Icons.thermostat,
                          'Temperature',
                          record['T'],
                        ),
                        _buildDetailRow(Icons.favorite, 'Pulse', record['P']),
                        _buildDetailRow(
                          Icons.air,
                          'Respiration Rate',
                          record['R'],
                        ),
                        _buildDetailRow(
                          Icons.speed,
                          'Blood Pressure',
                          record['bp'],
                        ),
                        _buildDetailRow(
                          Icons.local_drink,
                          'Intake (ml)',
                          record['it'],
                        ),
                        _buildDetailRow(
                          Icons.outbox,
                          'Output (ml)',
                          record['op'],
                        ),
                        _buildDetailRow(Icons.notes, 'Condition', record['c']),
                        _buildDetailRow(Icons.lightbulb, 'Advice', record['a']),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditTPRScreen(tprRecord: record),
                                  ),
                                ).then((_) {
                                  setState(() {
                                    _tprData = _fetchTPRRecords();
                                  });
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Deletion'),
                                      content: const Text(
                                        'Are you sure you want to delete this record?',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  final result = await ApiHelper.request(
                                    'tpr/${record['TPROID']}',
                                    method: 'DELETE',
                                  );
                                  if (result != null && context.mounted) {
                                    setState(() {
                                      _tprData = _fetchTPRRecords();
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Record deleted successfully',
                                        ),
                                      ),
                                    );
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to delete: ${result['message']}',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value?.toString() ?? 'N/A')),
        ],
      ),
    );
  }
}
