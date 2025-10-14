import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helper/api_helper.dart';
import '../utils/search_dropdown.dart';

class AddTreatmentScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const AddTreatmentScreen({super.key, required this.patient});

  @override
  _AddTreatmentScreenState createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends State<AddTreatmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _droidController = TextEditingController();
  final TextEditingController _clinicalNoteController = TextEditingController();
  final TextEditingController _adviceController = TextEditingController();
  final TextEditingController _rsController = TextEditingController();
  final TextEditingController _cnsController = TextEditingController();
  final TextEditingController _cvsController = TextEditingController();
  final TextEditingController _paController = TextEditingController();
  final TextEditingController _bslController = TextEditingController();
  final TextEditingController _gcController = TextEditingController();
  final TextEditingController _spo2Controller = TextEditingController();

  DateTime? _selectedDate;
  String _doctorName = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    _timeController.text = DateFormat(
      'HH:mm',
    ).format(DateTime.now()); // Use simple time format
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveTreatment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final Map<String, dynamic> data = {
        'date': _dateController.text,
        'time': _timeController.text,
        'poid': widget.patient['POID'],
        'name': widget.patient['Name'],
        'IPDNo': widget.patient['IPDNO'],
        'DROID': _droidController.text,
        'drName': _doctorName,
        'clinicalNote': _clinicalNoteController.text,
        'advice': _adviceController.text,
        'rs': _rsController.text,
        'cns': _cnsController.text,
        'cvs': _cvsController.text,
        'pa': _paController.text,
        'bsl': _bslController.text,
        'gc': _gcController.text,
        'spo2': _spo2Controller.text,
      };
      try {
        final response = await ApiHelper.request(
          'treatment',
          method: 'POST',
          body: data,
        );
        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Treatment record created successfully!'),
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response?['message'] ?? 'Failed to create treatment record.',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add-${widget.patient['Name']}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter time (HH:MM format)';
                        }
                        // Validate time format (HH:MM)
                        if (!RegExp(
                          r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$',
                        ).hasMatch(value)) {
                          return 'Please enter valid time (HH:MM format)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SearchDropdown(
                      apiUrl: "doctors-list",
                      hintText: "Search Doctor",
                      displayKey: "Name",
                      valueKey: "DrOID",
                      onItemSelected: (doctor) {
                        setState(() {
                          _droidController.text = doctor['DrOID'].toString();
                          _doctorName = doctor['Name']?.toString() ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _clinicalNoteController,
                      decoration: InputDecoration(
                        labelText: 'Clinical Note',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.note_alt),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _adviceController,
                      decoration: InputDecoration(
                        labelText: 'Advice',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.recommend),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _rsController,
                      decoration: InputDecoration(
                        labelText: 'RS',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.monitor_heart),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cnsController,
                      decoration: InputDecoration(
                        labelText: 'CNS',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.psychology),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cvsController,
                      decoration: InputDecoration(
                        labelText: 'CVS',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.favorite),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _paController,
                      decoration: InputDecoration(
                        labelText: 'PA',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.monitor_heart),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bslController,
                      decoration: InputDecoration(
                        labelText: 'BSL',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.monitor_heart),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _gcController,
                      decoration: InputDecoration(
                        labelText: 'General Condition',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.monitor_heart),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _spo2Controller,
                      decoration: InputDecoration(
                        labelText: 'SPO2',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.monitor_heart),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveTreatment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Save Treatment',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
