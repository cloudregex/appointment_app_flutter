import 'package:flutter/material.dart';
import '../../helper/api_helper.dart';

class AddEditPatientScreen extends StatefulWidget {
  final Map<String, dynamic>? patient;

  const AddEditPatientScreen({super.key, this.patient});

  @override
  _AddEditPatientScreenState createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _regNoController;
  late TextEditingController _pNameController;
  late TextEditingController _pAddressController;
  late TextEditingController _pContactController;
  late TextEditingController _pGenderController;
  late TextEditingController _pAgeController;
  late TextEditingController _drOidController;
  late TextEditingController _titleController;
  late TextEditingController _memberIdController;
  late TextEditingController _adharNoController;

  @override
  void initState() {
    super.initState();
    _regNoController = TextEditingController(
      text: widget.patient?['RegNo'] ?? '',
    );
    _pNameController = TextEditingController(
      text: widget.patient?['Pname'] ?? '',
    );
    _pAddressController = TextEditingController(
      text: widget.patient?['Paddress'] ?? '',
    );
    _pContactController = TextEditingController(
      text: widget.patient?['Pcontact'] ?? '',
    );
    _pGenderController = TextEditingController(
      text: widget.patient?['Pgender'] ?? '',
    );
    _pAgeController = TextEditingController(
      text: widget.patient?['Page']?.toString() ?? '',
    );
    _drOidController = TextEditingController(
      text: widget.patient?['DrOID']?.toString() ?? '',
    );
    _titleController = TextEditingController(
      text: widget.patient?['Tital'] ?? '',
    );
    _memberIdController = TextEditingController(
      text: widget.patient?['MemberID']?.toString() ?? '',
    );
    _adharNoController = TextEditingController(
      text: widget.patient?['AdharNo'] ?? '',
    );
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _pNameController.dispose();
    _pAddressController.dispose();
    _pContactController.dispose();
    _pGenderController.dispose();
    _pAgeController.dispose();
    _drOidController.dispose();
    _titleController.dispose();
    _memberIdController.dispose();
    _adharNoController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      final patientData = {
        'RegNo': _regNoController.text,
        'Pname': _pNameController.text,
        'Paddress': _pAddressController.text,
        'Pcontact': _pContactController.text,
        'Pgender': _pGenderController.text,
        'Page': _pAgeController.text,
        'DrOID': int.tryParse(_drOidController.text) ?? 0,
        'Tital': _titleController.text,
        'MemberID': int.tryParse(_memberIdController.text) ?? 0,
        'AdharNo': _adharNoController.text,
      };

      try {
        if (widget.patient == null) {
          await ApiHelper.request(
            'patients',
            method: 'POST',
            body: patientData,
          );
        } else {
          await ApiHelper.request(
            'patients/${widget.patient!['POID']}',
            method: 'PUT',
            body: patientData,
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save patient: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'Add Patient' : 'Edit Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _regNoController,
                  decoration: const InputDecoration(labelText: 'RegNo'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter RegNo' : null,
                ),
                TextFormField(
                  controller: _pNameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter name' : null,
                ),
                TextFormField(
                  controller: _pAddressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter address' : null,
                ),
                TextFormField(
                  controller: _pContactController,
                  decoration: const InputDecoration(labelText: 'Contact'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter contact' : null,
                ),
                TextFormField(
                  controller: _pGenderController,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter gender' : null,
                ),
                TextFormField(
                  controller: _pAgeController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter age' : null,
                ),
                TextFormField(
                  controller: _drOidController,
                  decoration: const InputDecoration(labelText: 'DrOID'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter DrOID' : null,
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter title' : null,
                ),
                TextFormField(
                  controller: _memberIdController,
                  decoration: const InputDecoration(labelText: 'MemberID'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter MemberID' : null,
                ),
                TextFormField(
                  controller: _adharNoController,
                  decoration: const InputDecoration(labelText: 'AdharNo'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter AdharNo' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _savePatient,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
