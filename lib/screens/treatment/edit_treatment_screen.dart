import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helper/api_helper.dart';
import '../utils/search_dropdown.dart';

class EditTreatmentScreen extends StatefulWidget {
  final Map<String, dynamic> patient;
  final Map<String, dynamic> treatmentRecord;

  const EditTreatmentScreen({
    super.key,
    required this.patient,
    required this.treatmentRecord,
  });

  @override
  _EditTreatmentScreenState createState() => _EditTreatmentScreenState();
}

class _EditTreatmentScreenState extends State<EditTreatmentScreen> {
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
    _dateController.text = widget.treatmentRecord['Date'] ?? '';
    _timeController.text = widget.treatmentRecord['Time'] ?? '';
    _droidController.text = (widget.treatmentRecord['DROID'] ?? '').toString();
    _doctorName = widget.treatmentRecord['DrName'] ?? '';
    _clinicalNoteController.text = widget.treatmentRecord['ClinicalNote'] ?? '';
    _adviceController.text = widget.treatmentRecord['Advice'] ?? '';
    _rsController.text = widget.treatmentRecord['Rs'] ?? '';
    _cnsController.text = widget.treatmentRecord['Cns'] ?? '';
    _cvsController.text = widget.treatmentRecord['Cvs'] ?? '';
    _paController.text = widget.treatmentRecord['Pa'] ?? '';
    _bslController.text = widget.treatmentRecord['Bsl'] ?? '';
    _gcController.text = widget.treatmentRecord['Gc'] ?? '';
    _spo2Controller.text = widget.treatmentRecord['Spo2'] ?? '';

    // Parse date from the record
    String dateString = (widget.treatmentRecord['Date'] ?? '').toString();
    if (dateString.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(dateString);
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      } catch (e) {
        _selectedDate = DateTime.now();
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      }
    } else {
      _selectedDate = DateTime.now();
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }
    // Time is already set directly from the record, no need for additional parsing
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

  Future<void> _updateTreatment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final Map<String, dynamic> data = {
        'date': _dateController.text,
        'time': _timeController.text,
        'poid': widget.patient['POID'],
        'IPDNo': widget.patient['IPDNO'],
        'name': widget.patient['Name'],
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
        var id = widget.treatmentRecord['TCOID'];
        final response = await ApiHelper.request(
          'treatment/$id',
          method: 'PUT',
          body: data,
        );
        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Treatment record updated successfully!'),
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response?['message'] ?? 'Failed to update treatment record.',
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

  Future<void> _deleteTreatment() async {
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
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await ApiHelper.request(
          'treatment/${widget.treatmentRecord['TCOID']}',
          method: 'DELETE',
        );
        if (response != null &&
            response['message'] == 'Treatment record deleted') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Treatment record deleted successfully!'),
            ),
          );
          Navigator.pop(context, true); // Go back and indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response?['message'] ?? 'Failed to delete treatment record.',
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
        title: Text('${widget.patient['Name']}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTreatment,
          ),
        ],
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
                      initialValue: _droidController.text,
                      initialDisplayText: _doctorName,
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
                        labelText: 'GC',
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
                        onPressed: _updateTreatment,
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
                          'Update Treatment',
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
