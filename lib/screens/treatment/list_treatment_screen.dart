import 'dart:async';
import 'package:flutter/material.dart';
import '../../helper/api_helper.dart';
import 'add_treatment_screen.dart';
import 'edit_treatment_screen.dart';

class TreatmentListScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const TreatmentListScreen({super.key, required this.patient});

  @override
  _TreatmentListScreenState createState() => _TreatmentListScreenState();
}

class _TreatmentListScreenState extends State<TreatmentListScreen> {
  late Future<Map<String, dynamic>> _treatmentData;
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _treatmentData = _fetchTreatments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchTreatments({
    int page = 1,
    String? search,
  }) async {
    try {
      String endpoint = 'treatment?IPDNo=${widget.patient['IPDNO']}&page=$page';
      if (search != null && search.isNotEmpty) {
        endpoint += '&search=$search';
      }

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
      throw Exception('Failed to load treatment records: $e');
    }
  }

  // The _selectDate method has been removed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patient['Name']}'),
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
                      AddTreatmentScreen(patient: widget.patient),
                ),
              );
              if (result == true) {
                setState(() {
                  _treatmentData = _fetchTreatments();
                });
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 5),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search treatments...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      setState(() {
                        _currentPage = 1;
                        _treatmentData = _fetchTreatments(
                          page: _currentPage,
                          search: value,
                        );
                      });
                    });
                  },
                ),
                const SizedBox(height: 8),
                // Date filter buttons have been removed
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _treatmentData,
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
                      setState(() {
                        _treatmentData = _fetchTreatments(
                          page: _currentPage,
                          search: _searchController.text,
                        );
                      });
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
                  Icon(
                    Icons.medical_services_outlined,
                    color: Colors.grey[400],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No treatment records found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No treatments recorded for this patient',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final treatmentRecords = snapshot.data!['data'] as List;
            final currentPage = snapshot.data!['current_page'] as int;
            final lastPage = snapshot.data!['last_page'] as int;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _treatmentData = _fetchTreatments(
                    page: _currentPage,
                    search: _searchController.text,
                  );
                });
              },
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(4.0),
                      itemCount: treatmentRecords.length,
                      itemBuilder: (context, index) {
                        final treatmentRecord = treatmentRecords[index];
                        return _buildTreatmentCard(treatmentRecord);
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
                                    setState(() {
                                      _currentPage = currentPage - 1;
                                      _treatmentData = _fetchTreatments(
                                        page: _currentPage,
                                        search: _searchController.text,
                                      );
                                    });
                                  }
                                : null,
                            child: const Text('Previous'),
                          ),
                          Text('Page $currentPage of $lastPage'),
                          ElevatedButton(
                            onPressed: currentPage < lastPage
                                ? () {
                                    setState(() {
                                      _currentPage = currentPage + 1;
                                      _treatmentData = _fetchTreatments(
                                        page: _currentPage,
                                        search: _searchController.text,
                                      );
                                    });
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

  Widget _buildTreatmentCard(Map<String, dynamic> treatmentRecord) {
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
                builder: (context) => EditTreatmentScreen(
                  patient: widget.patient,
                  treatmentRecord: treatmentRecord,
                ),
              ),
            );
            if (result == true) {
              setState(() {
                _treatmentData = _fetchTreatments();
              });
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
                    Text(
                      (treatmentRecord['DrName'] ?? 'N/A').toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      (treatmentRecord['Date'] ?? 'N/A').toString().split(
                        ' ',
                      )[0],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                _buildDetailRow(
                  Icons.medical_information_outlined,
                  'Time',
                  (treatmentRecord['Time'] ?? 'N/A').toString(),
                ),
                _buildDetailRow(
                  Icons.note_alt_outlined,
                  'Clinical Note',
                  (treatmentRecord['ClinicalNote'] ?? 'N/A').toString(),
                ),
                _buildDetailRow(
                  Icons.recommend_outlined,
                  'Advice',
                  (treatmentRecord['Advice'] ?? 'N/A').toString(),
                ),
                _buildDetailRow(
                  Icons.monitor_heart_outlined,
                  'RS',
                  (treatmentRecord['Rs'] ?? 'N/A').toString(),
                ),
                _buildDetailRow(
                  Icons.psychology_outlined,
                  'CNS',
                  (treatmentRecord['Cns'] ?? 'N/A').toString(),
                ),
                _buildDetailRow(
                  Icons.favorite_outlined,
                  'CVS',
                  (treatmentRecord['Cvs'] ?? 'N/A').toString(),
                ),
                _buildDetailRow(
                  Icons.monitor_heart_outlined,
                  'PA',
                  (treatmentRecord['PA'] ?? 'N/A').toString(),
                ),
                _buildDetailRow(
                  Icons.monitor_heart_outlined,
                  'BSL',
                  (treatmentRecord['BSL'] ?? 'N/A').toString(),
                ),
                _buildDetailRow(
                  Icons.monitor_heart_outlined,
                  'General Condition',
                  (treatmentRecord['GC'] ?? 'N/A').toString(),
                ),
                _buildDetailRow(
                  Icons.monitor_heart_outlined,
                  'SPO2',
                  (treatmentRecord['SPO2'] ?? 'N/A').toString(),
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
                            builder: (context) => EditTreatmentScreen(
                              patient: widget.patient,
                              treatmentRecord: treatmentRecord,
                            ),
                          ),
                        );
                        if (result == true) {
                          setState(() {
                            _treatmentData = _fetchTreatments();
                          });
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
                                'Are you sure you want to delete this treatment record?',
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
                              'treatment/${treatmentRecord['TCOID']}',
                              method: 'DELETE',
                            );
                            if (response != null &&
                                response['message'] ==
                                    'Treatment record deleted') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Treatment record deleted successfully!',
                                  ),
                                ),
                              );
                              setState(() {
                                _treatmentData = _fetchTreatments();
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response?['message'] ??
                                        'Failed to delete treatment record.',
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
}
