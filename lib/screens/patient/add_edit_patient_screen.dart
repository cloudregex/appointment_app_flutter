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
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save patient: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'Add Patient' : 'Edit Patient'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.patient == null
                                ? Icons.person_add
                                : Icons.person,
                            color: Theme.of(context).primaryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.patient == null
                                    ? 'Add New Patient'
                                    : 'Edit Patient',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Fill in the patient details below',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Form fields
                _buildSectionTitle('Personal Information'),
                _buildTextField(
                  controller: _regNoController,
                  labelText: 'Registration Number',
                  icon: Icons.confirmation_number,
                  validator: (value) => value!.isEmpty
                      ? 'Please enter registration number'
                      : null,
                ),
                _buildTextField(
                  controller: _pNameController,
                  labelText: 'Full Name',
                  icon: Icons.person,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter full name' : null,
                ),
                _buildTextField(
                  controller: _pGenderController,
                  labelText: 'Gender',
                  icon: Icons.wc,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter gender' : null,
                ),
                _buildTextField(
                  controller: _pAgeController,
                  labelText: 'Age',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter age' : null,
                ),
                _buildTextField(
                  controller: _titleController,
                  labelText: 'Title',
                  icon: Icons.title,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter title' : null,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Contact Information'),
                _buildTextField(
                  controller: _pAddressController,
                  labelText: 'Address',
                  icon: Icons.location_on,
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter address' : null,
                ),
                _buildTextField(
                  controller: _pContactController,
                  labelText: 'Contact Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter contact number' : null,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Medical Information'),
                _buildTextField(
                  controller: _drOidController,
                  labelText: 'Doctor ID',
                  icon: Icons.local_hospital,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter doctor ID' : null,
                ),
                _buildTextField(
                  controller: _memberIdController,
                  labelText: 'Member ID',
                  icon: Icons.badge,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter member ID' : null,
                ),
                _buildTextField(
                  controller: _adharNoController,
                  labelText: 'Aadhar Number',
                  icon: Icons.credit_card,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter aadhar number' : null,
                ),
                const SizedBox(height: 30),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _savePatient,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      widget.patient == null ? 'Add Patient' : 'Update Patient',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          validator: validator,
        ),
      ),
    );
  }
}
