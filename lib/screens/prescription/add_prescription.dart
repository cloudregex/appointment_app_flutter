import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helper/api_helper.dart';

class AddPrescriptionScreen extends StatefulWidget {
  final Map<String, dynamic>? appointmentData;

  const AddPrescriptionScreen({super.key, this.appointmentData});

  @override
  _AddPrescriptionScreenState createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _prescriptionNoController = TextEditingController();
 final TextEditingController _dateController = TextEditingController();
  final TextEditingController _historyController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
 final TextEditingController _contentNameController = TextEditingController();
 final TextEditingController _notesController = TextEditingController();
  final TextEditingController _adviceController = TextEditingController();
  final TextEditingController _apDateController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _cfController = TextEditingController();
   final TextEditingController _geController = TextEditingController();
  final TextEditingController _invController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _prescriptionNoController.dispose();
    _dateController.dispose();
    _historyController.dispose();
    _itemNameController.dispose();
    _contentNameController.dispose();
    _notesController.dispose();
    _adviceController.dispose();
    _apDateController.dispose();
    _ccController.dispose();
    _cfController.dispose();
    _geController.dispose();
    _invController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
 }

 Future<void> _savePrescription() async {
   if (_formKey.currentState!.validate()) {
     setState(() {
       _isLoading = true;
     });

     final Map<String, dynamic> data = {
       'PrescriptionNo': int.tryParse(_prescriptionNoController.text) ?? 0,
       'Date': _dateController.text,
       'POID': widget.appointmentData?['POID'], // Using the appointment data directly
       'History': _historyController.text,
       'ItemName': _itemNameController.text,
       'ContentName': _contentNameController.text,
       'Notes': _notesController.text,
       'Advice': _adviceController.text,
       'ApDate': _apDateController.text.isEmpty ? _dateController.text : _apDateController.text,
       'cc': _ccController.text,
       'cf': _cfController.text,
       'ge': _geController.text,
       'inv': _invController.text,
       'Name':widget.appointmentData?['Name'] ?? 'N/A',
     };

     try {
       final response = await ApiHelper.request(
         'prescriptions',
         method: 'POST',
         body: data,
       );
       if (response != null) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Prescription record created successfully!'),
           ),
         );
         Navigator.pop(context, true);
       } else {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(
               response?['message'] ?? 'Failed to create prescription record.',
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
        title: Text('Add-${widget.appointmentData?['Name'] ?? 'Prescription'}'),
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
                    _buildTextField('Prescription No', _prescriptionNoController, 'Enter prescription number', isRequired: true),
                    _buildDateField(),
                    _buildTextField('History', _historyController, 'Enter history', isRequired: false),
                    _buildTextField('Item Name', _itemNameController, 'Enter item name', isRequired: false),
                    _buildTextField('Content Name', _contentNameController, 'Enter content name', isRequired: false),
                    _buildTextField('Notes', _notesController, 'Enter notes', isRequired: false),
                    _buildTextField('Advice', _adviceController, 'Enter advice', isRequired: false),
                    _buildApDateField(),
                    _buildTextField('CC', _ccController, 'Enter CC', isRequired: false),
                    _buildTextField('CF', _cfController, 'Enter CF', isRequired: false),
                    _buildTextField('GE', _geController, 'Enter GE', isRequired: false),
                    _buildTextField('INV', _invController, 'Enter INV', isRequired: false),
                    _buildTextField('Name', _nameController, 'Enter name', isRequired: false),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _savePrescription,
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
                          'Save Prescription',
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


  Widget _buildTextField(String label, TextEditingController controller, String hint, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          prefixIcon: _getIconForLabel(label),
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Icon _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'prescription no':
        return const Icon(Icons.medication);
      case 'history':
        return const Icon(Icons.history);
      case 'item name':
        return const Icon(Icons.medication_liquid);
      case 'content name':
        return const Icon(Icons.description);
      case 'notes':
        return const Icon(Icons.note_alt_outlined);
      case 'advice':
        return const Icon(Icons.recommend_outlined);
      case 'cc':
        return const Icon(Icons.psychology_outlined);
      case 'cf':
        return const Icon(Icons.monitor_heart_outlined);
      case 'ge':
        return const Icon(Icons.favorite_outlined);
      case 'inv':
        return const Icon(Icons.assignment_outlined);
      default:
        return const Icon(Icons.edit);
    }
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () => _selectDate(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a date';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildApDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _apDateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'ApDate',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null) {
            _apDateController.text = DateFormat('yyyy-MM-dd').format(picked);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an appointment date';
          }
          return null;
        },
      ),
    );
  }


}