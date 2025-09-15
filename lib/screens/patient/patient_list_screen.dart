import 'package:flutter/material.dart';
import '../../helper/api_helper.dart';
import './add_edit_patient_screen.dart';
import './patient_details_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  late Future<List<dynamic>> _patients;

  @override
  void initState() {
    super.initState();
    _patients = _fetchPatients();
  }

  Future<List<dynamic>> _fetchPatients() async {
    try {
      final response = await ApiHelper.request('patients');
      if (response != null && response['data'] != null) {
        return response['data'] as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load patients: $e');
    }
  }

  void _navigateToAddEditScreen({Map<String, dynamic>? patient}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPatientScreen(patient: patient),
      ),
    );
    setState(() {
      _patients = _fetchPatients();
    });
  }

  void _navigateToDetailsScreen(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsScreen(patient: patient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
      body: FutureBuilder<List<dynamic>>(
        future: _patients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No patients found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final patient = snapshot.data![index];
                return ListTile(
                  title: Text(patient['Pname'] ?? 'Unknown'),
                  subtitle: Text('Reg No: ${patient['RegNo'] ?? 'N/A'}'),
                  onTap: () => _navigateToDetailsScreen(patient),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToAddEditScreen(patient: patient),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
