import 'dart:async';
import 'package:flutter/material.dart';
import '../../helper/api_helper.dart';
import 'add_discharge_card.dart';
import 'edit_discharge_card.dart';
import 'package:intl/intl.dart';

class DischargeCardListScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const DischargeCardListScreen({super.key, required this.patient});

  @override
  _DischargeCardListScreenState createState() =>
      _DischargeCardListScreenState();
}

class _DischargeCardListScreenState extends State<DischargeCardListScreen> {
  late Future<Map<String, dynamic>> _dischargeData;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _dischargeData = _fetchDischargeCards();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchDischargeCards({int page = 1}) async {
    try {
      String endpoint =
          'discharge-card?ipdNo=${widget.patient['IPDNO']?.toString()}&page=$page';

      final response = await ApiHelper.request(endpoint);
      if (response != null) {
        return {
          'data': response['data'] as List<dynamic>? ?? [],
          'current_page': response['current_page'] ?? 1,
          'last_page': response['last_page'] ?? 1,
          'per_page': response['per_page'] ?? 20,
          'total': response['total'] ?? 0,
        };
      } else {
        return {
          'data': [],
          'current_page': 1,
          'last_page': 1,
          'per_page': 20,
          'total': 0,
        };
      }
    } catch (e) {
      throw Exception('Failed to load discharge card records: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patient['Name']?.toString()} - Discharge'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddDischargeCardScreen(patient: widget.patient),
                ),
              );
              if (result == true) {
                _dischargeData = _fetchDischargeCards();
                if (mounted) {
                  setState(() {});
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dischargeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _dischargeData = _fetchDischargeCards(page: _currentPage);
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData ||
              snapshot.data!['data'] == null ||
              (snapshot.data!['data'] as List).isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_hospital, color: Colors.grey[400], size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'No discharge records found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No discharge records for this patient',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final dischargeRecords = snapshot.data!['data'] as List;
            final currentPage = snapshot.data!['current_page'] as int;
            final lastPage = snapshot.data!['last_page'] as int;

            return RefreshIndicator(
              onRefresh: () async {
                _dischargeData = _fetchDischargeCards(page: _currentPage);
                if (mounted) {
                  setState(() {});
                }
                return;
              },
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(4.0),
                      itemCount: dischargeRecords.length,
                      itemBuilder: (context, index) {
                        final dischargeRecord = dischargeRecords[index];
                        return _buildDischargeCard(dischargeRecord);
                      },
                    ),
                  ),
                  if (lastPage > 1)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: currentPage > 1
                                ? () {
                                    _currentPage = currentPage - 1;
                                    _dischargeData = _fetchDischargeCards(
                                      page: _currentPage,
                                    );
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  }
                                : null,
                            child: const Text('Previous'),
                          ),
                          Text('Page $currentPage of $lastPage'),
                          ElevatedButton(
                            onPressed: currentPage < lastPage
                                ? () {
                                    _currentPage = currentPage + 1;
                                    _dischargeData = _fetchDischargeCards(
                                      page: _currentPage,
                                    );
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  }
                                : null,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDischargeCard(Map<String, dynamic> dischargeRecord) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditDischargeCardScreen(
                  patient: widget.patient,
                  dischargeRecord: dischargeRecord,
                ),
              ),
            );
            if (result == true) {
              _dischargeData = _fetchDischargeCards();
              if (mounted) {
                setState(() {});
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        (dischargeRecord['Daignosis'] ?? 'N/A').toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatDate(dischargeRecord['DOD']),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                _buildDetailRow(
                  Icons.confirmation_number_outlined,
                  'IPD No',
                  (dischargeRecord['IpdNo'] ?? 'N/A').toString(),
                ),
                _buildDetailRow(
                  Icons.date_range_outlined,
                  'Date of Admission',
                  _formatDate(dischargeRecord['DOA']),
                ),
                _buildDetailRow(
                  Icons.date_range_outlined,
                  'Date of Discharge',
                  _formatDate(dischargeRecord['DOD']),
                ),
                _buildDetailRow(
                  Icons.person,
                  'Incharge Dr',
                  (dischargeRecord['Dr1'] ?? 'N/A').toString(),
                ),
                _buildDetailRow(
                  Icons.person,
                  'RMO Dr',
                  (dischargeRecord['Dr2'] ?? 'N/A').toString(),
                ),
                _buildDetailRow(
                  Icons.medical_services,
                  'Diet Recommendation',
                  (dischargeRecord['DR'] ?? 'N/A').toString(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditDischargeCardScreen(
                              patient: widget.patient,
                              dischargeRecord: dischargeRecord,
                            ),
                          ),
                        );
                        if (result == true) {
                          _dischargeData = _fetchDischargeCards();
                          if (mounted) {
                            setState(() {});
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text(
                                'Are you sure you want to delete this discharge record?',
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
                          try {
                            final response = await ApiHelper.request(
                              'discharge-card/${dischargeRecord['DisOID']?.toString() ?? ''}',
                              method: 'DELETE',
                            );
                            print(response);
                            if (response != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Discharge record deleted successfully!',
                                  ),
                                ),
                              );
                              // Refresh the data to remove the deleted record
                              setState(() {
                                _dischargeData = _fetchDischargeCards(
                                  page: _currentPage,
                                );
                              });
                              if (mounted) {
                                setState(() {});
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response?['message'] ??
                                        'Failed to delete discharge record.',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
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
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';

    try {
      DateTime date;
      if (dateString.contains(' ')) {
        // Extract only date part if time exists
        String datePart = dateString.split(' ')[0];
        date = DateTime.parse(datePart);
      } else {
        date = DateTime.parse(dateString);
      }

      // ✅ Format as "15-10-2025"
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      // If parsing fails, return original value
      return dateString;
    }
  }
}
