import 'package:flutter/material.dart';
import '../../helper/api_helper.dart';
import './add_appointment.dart';
import './view_appointment.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  late Future<List<dynamic>> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = _fetchAppointments();
  }

  Future<List<dynamic>> _fetchAppointments() async {
    try {
      final response = await ApiHelper.request('appointments');
      if (response != null && response['data'] != null) {
        return response['data'] as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load appointments');
    }
  }

  void _navigateToAddAppointmentScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAppointmentScreen()),
    );
    setState(() {
      _appointments = _fetchAppointments();
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
      _appointments = _fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _appointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red[30], size: 48),
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
                        _appointments = _fetchAppointments();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _appointments = _fetchAppointments();
                });
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final appointment = snapshot.data![index];
                  return _buildAppointmentCard(appointment);
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAppointmentScreen,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment['Date'] ?? 'Unknown Date',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'POID: ${appointment['POID'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Appointment details with improved info chips
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.phone,
                      appointment['Contact'] ?? 'N/A',
                      context,
                      Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _buildInfoChip(
                      Icons.medical_information,
                      'DROID: ${appointment['DROID'] ?? 'N/A'}',
                      context,
                      Colors.purple,
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
