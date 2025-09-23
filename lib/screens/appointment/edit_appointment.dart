import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helper/api_helper.dart';
import '../utils/search_dropdown.dart';

class EditAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic>? appointment;

  const EditAppointmentScreen({super.key, this.appointment});

  @override
  _EditAppointmentScreenState createState() => _EditAppointmentScreenState();
}

/// ✅ Date formatter: show only dd-MM-yyyy
String _formatDate(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty) return '';
  try {
    final parsed = DateTime.parse(rawDate);
    return DateFormat('dd-MM-yyyy').format(parsed); // only date
  } catch (e) {
    return rawDate; // fallback
  }
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _poidController;
  late TextEditingController _contactController;
  late TextEditingController _droidController;
  String _patientName = '';
  String _doctorName = '';

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: _formatDate(widget.appointment?['Date']),
    );
    _poidController = TextEditingController(
      text: widget.appointment?['POID']?.toString() ?? '',
    );
    _contactController = TextEditingController(
      text: widget.appointment?['Contact'] ?? '',
    );
    _droidController = TextEditingController(
      text: widget.appointment?['DROID']?.toString() ?? '',
    );
    _patientName = widget.appointment?['Name']?.toString() ?? '';
    _doctorName = widget.appointment?['DrName']?.toString() ?? '';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _poidController.dispose();
    _contactController.dispose();
    _droidController.dispose();
    super.dispose();
  }

  Future<void> _saveAppointment() async {
    if (_formKey.currentState!.validate()) {
      final appointmentData = {
        'Date': _dateController.text,
        'POID': _poidController.text,
        'Name': _patientName,
        'Contact': _contactController.text,
        'DROID': _droidController.text,
        'DrName': _doctorName,
      };

      try {
        if (widget.appointment == null) {
          await ApiHelper.request(
            'appointments',
            method: 'POST',
            body: appointmentData,
          );
        } else {
          await ApiHelper.request(
            'appointments/${widget.appointment!['APPOID']}',
            method: 'PUT',
            body: appointmentData,
          );
        }

        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          print(e);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save appointment')),
          );
        }
      }
    }
  }

  Future<void> _deleteAppointment(BuildContext context) async {
    try {
      await ApiHelper.request(
        'appointments/${widget.appointment!['APPOID']}',
        method: 'DELETE',
      );
      if (context.mounted) {
        // Pop back to the list screen
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete appointment')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Appointment'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.appointment != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteAppointment(context);
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Form fields
                  _buildSectionCard(context, 'Appointment Details', [
                    _buildDateField(),
                    const SizedBox(height: 20),
                    SearchDropdown(
                      apiUrl: "patients-list",
                      hintText: "Search Patient",
                      displayKey: "Pname",
                      valueKey: "POID",
                      initialValue: widget.appointment?['POID']?.toString(),
                      initialDisplayText: widget
                          .appointment?['Name'], // Assuming this field exists
                      onItemSelected: (patient) {
                        setState(() {
                          _poidController.text = patient['POID'].toString();
                          _contactController.text =
                              patient['Pcontact']?.toString() ?? '';
                          _patientName = patient['Pname']?.toString() ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _contactController,
                      labelText: 'Contact',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      readOnly:
                          true, // Make it non-editable as it's auto-populated
                    ),
                    const SizedBox(height: 20),
                    SearchDropdown(
                      apiUrl: "doctors-list",
                      hintText: "Search Doctor",
                      displayKey: "Name",
                      valueKey: "DrOID",
                      initialValue: widget.appointment?['DrOID']?.toString(),
                      initialDisplayText: widget
                          .appointment?['DrName'], // Assuming this field exists
                      onItemSelected: (doctor) {
                        setState(() {
                          _droidController.text = doctor['DrOID'].toString();
                          _doctorName = doctor['Name']?.toString() ?? '';
                        });
                      },
                    ),
                  ]),
                  const SizedBox(height: 30),
                  // Save button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveAppointment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: const Text(
                          'Update Appointment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: _dateController,
        decoration: InputDecoration(
          labelText: 'Date',
          labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
          prefixIcon: Icon(
            Icons.calendar_today,
            color: Theme.of(context).primaryColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2.0,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        readOnly: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please select a date";
          }
          return null;
        },
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );

          if (pickedDate != null) {
            setState(() {
              _dateController.text = _formatDate(pickedDate.toIso8601String());
            });
          }
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2.0,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        validator: validator,
        readOnly: readOnly,
      ),
    );
  }
}
