import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../helper/api_helper.dart';
import './add_appointment.dart';
import './edit_appointment.dart';
import './view_appointment.dart';
import '../prescription/list_prescription.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  late Future<Map<String, dynamic>> _appointmentsData;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  int _currentPage = 1;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _appointmentsData = _fetchAppointments(
      search: _searchController.text,
      page: _currentPage,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchAppointments({
    String? search,
    int page = 1,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String endpoint = 'appointments?page=$page';
      if (search != null && search.isNotEmpty) {
        endpoint += '&search=$search';
      }
      if (startDate != null) {
        endpoint += '&start_date=${DateFormat('yyyy-MM-dd').format(startDate)}';
      }
      if (endDate != null) {
        endpoint += '&end_date=${DateFormat('yyyy-MM-dd').format(endDate)}';
      }

      final response = await ApiHelper.request(endpoint);
      if (response != null) {
        return {
          'data': response['data'] as List<dynamic> ?? [],
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
      throw Exception('Failed to load appointments');
    }
  }

  void _navigateToAddAppointmentScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAppointmentScreen()),
    );
    setState(() {
      _appointmentsData = _fetchAppointments(
        search: _searchController.text,
        page: _currentPage,
        startDate: _startDate,
        endDate: _endDate,
      );
    });
  }

  void _navigateToEditAppointmentScreen(
    Map<String, dynamic> appointment,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAppointmentScreen(appointment: appointment),
      ),
    );
    setState(() {
      _appointmentsData = _fetchAppointments(
        search: _searchController.text,
        page: _currentPage,
        startDate: _startDate,
        endDate: _endDate,
      );
    });
  }

  void _navigateToViewAppointmentScreen(
    Map<String, dynamic> appointment,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewAppointmentScreen(appointment: appointment),
      ),
    );
    setState(() {
      _appointmentsData = _fetchAppointments(
        search: _searchController.text,
        page: _currentPage,
        startDate: _startDate,
        endDate: _endDate,
      );
    });
  }

  void _showDateFilterBottomSheet() {
    DateTime? selectedStartDate = _startDate;
    DateTime? selectedEndDate = _endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Filter by Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Start Date'),
                      subtitle: Text(
                        selectedStartDate != null
                            ? DateFormat(
                                'dd-MM-yyyy',
                              ).format(selectedStartDate!)
                            : 'Select date',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedStartDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedStartDate = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('End Date'),
                      subtitle: Text(
                        selectedEndDate != null
                            ? DateFormat('dd-MM-yyyy').format(selectedEndDate!)
                            : 'Select date',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedEndDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedEndDate = picked;
                          });
                        }
                      },
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Reset dates to current
                            setModalState(() {
                              selectedStartDate = DateTime.now();
                              selectedEndDate = DateTime.now();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text('Reset'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Validate date range
                            if (selectedStartDate != null &&
                                selectedEndDate != null &&
                                selectedStartDate!.isAfter(selectedEndDate!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'End date cannot be before start date',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Apply filter
                            Navigator.of(context).pop();
                            setState(() {
                              _startDate = selectedStartDate;
                              _endDate = selectedEndDate;
                              _currentPage = 1;
                              _appointmentsData = _fetchAppointments(
                                search: _searchController.text,
                                page: _currentPage,
                                startDate: _startDate,
                                endDate: _endDate,
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Apply Filter'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ✅ Date formatter: show only dd-MM-yyyy
  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return 'Unknown Date';

    // Handle string dates
    if (rawDate is String) {
      if (rawDate.isEmpty) return 'Unknown Date';
      try {
        final parsed = DateTime.parse(rawDate);
        return DateFormat('dd-MM-yyyy').format(parsed);
      } catch (_) {
        return rawDate;
      }
    }

    // Handle DateTime objects
    if (rawDate is DateTime) {
      return DateFormat('dd-MM-yyyy').format(rawDate);
    }

    // Handle other types (int timestamps, etc.)
    return rawDate.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddAppointmentScreen,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showDateFilterBottomSheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 5),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search appointments...',
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
                    _appointmentsData = _fetchAppointments(
                      search: value,
                      page: _currentPage,
                      startDate: _startDate,
                      endDate: _endDate,
                    );
                  });
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _appointmentsData,
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
                        _appointmentsData = _fetchAppointments(
                          search: _searchController.text,
                          page: _currentPage,
                          startDate: _startDate,
                          endDate: _endDate,
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
                  Icon(Icons.calendar_today, color: Colors.grey[400], size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'No appointments found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your first appointment using the button below',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final appointments = snapshot.data!['data'] as List;
            final currentPage = snapshot.data!['current_page'] as int;
            final lastPage = snapshot.data!['last_page'] as int;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _appointmentsData = _fetchAppointments(
                    search: _searchController.text,
                    page: _currentPage,
                    startDate: _startDate,
                    endDate: _endDate,
                  );
                });
              },
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(4.0),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        return _buildAppointmentCard(appointment);
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
                                      _appointmentsData = _fetchAppointments(
                                        search: _searchController.text,
                                        page: _currentPage,
                                        startDate: _startDate,
                                        endDate: _endDate,
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
                                      _appointmentsData = _fetchAppointments(
                                        search: _searchController.text,
                                        page: _currentPage,
                                        startDate: _startDate,
                                        endDate: _endDate,
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

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () => _navigateToViewAppointmentScreen(appointment),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with date and POID
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(
                              appointment['date'] ??
                                  appointment['Date'] ??
                                  appointment['appointment_date'],
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Appointment No: ${appointment['id'] ?? appointment['APPID'] ?? appointment['appointment_id'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      onPressed: () =>
                          _navigateToEditAppointmentScreen(appointment),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Appointment details with improved info chips (WRAP instead of ROW)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.phone,
                      appointment['Contact'] ?? 'N/A',
                      context,
                      Colors.green,
                    ),
                    _buildInfoChip(
                      Icons.person,
                      appointment['Name'] ?? 'N/A',
                      context,
                      Colors.blue,
                    ),
                    _buildInfoChip(
                      Icons.local_hospital,
                      appointment['DrName'] ?? 'N/A',
                      context,
                      Colors.deepPurple,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () =>
                          _navigateToViewAppointmentScreen(appointment),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () =>
                          _navigateToEditAppointmentScreen(appointment),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrescriptionListScreen(
                              appointmentData: appointment,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Add Presc.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildInfoChip(
    IconData icon,
    String text,
    BuildContext context, [
    Color? color,
  ]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? Theme.of(context).primaryColor).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color ?? Theme.of(context).primaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
