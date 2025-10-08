import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helper/api_helper.dart';
import '../utils/search_dropdown.dart';

class DuplicateDrugChartScreen extends StatefulWidget {
  final Map<String, dynamic> patient;
  final Map<String, dynamic> drugRecord;

  const DuplicateDrugChartScreen({
    super.key,
    required this.patient,
    required this.drugRecord,
  });

  @override
  _DuplicateDrugChartScreenState createState() =>
      _DuplicateDrugChartScreenState();
}

class _DuplicateDrugChartScreenState extends State<DuplicateDrugChartScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _medicineController.text = widget.drugRecord['Medicine'] ?? '';
    _dosageController.text = widget.drugRecord['Dosage'] ?? '';

    // Set current date as default
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
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

  Future<void> _duplicateDrugRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final Map<String, dynamic> data = {
        'IPDNo': widget.patient['IPDNO'],
        'POID': widget.patient['POID'],
        'Name': widget.patient['Name'],
        'Date': _dateController.text,
        'Medicine': _medicineController.text,
        'Dosage': _dosageController.text,
      };
      try {
        final response = await ApiHelper.request(
          'drug-chart',
          method: 'POST',
          body: data,
        );
        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Drug record duplicated successfully!'),
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response?['message'] ?? 'Failed to duplicate drug record.',
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
                    SearchDropdown(
                      apiUrl: 'item-list',
                      hintText: 'Medicine Name',
                      displayKey: 'Name',
                      valueKey: 'Id',
                      initialDisplayText: _medicineController.text,
                      onItemSelected: (item) {
                        setState(() {
                          _medicineController.text = item['Name'] ?? '';
                        });
                      },
                      onSearchTextChanged: (text) {
                        setState(() {
                          _medicineController.text = text;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SearchDropdown(
                      apiUrl: 'content-list',
                      hintText: 'Dosage',
                      displayKey: 'Name',
                      valueKey: 'Id',
                      initialDisplayText: _dosageController.text,
                      onItemSelected: (item) {
                        setState(() {
                          _dosageController.text = item['Name'] ?? '';
                        });
                      },
                      onSearchTextChanged: (text) {
                        setState(() {
                          _dosageController.text = text;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _duplicateDrugRecord,
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
                          'Duplicate Drug Record',
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
