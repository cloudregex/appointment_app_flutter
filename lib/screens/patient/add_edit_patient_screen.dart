import 'package:appointment_app/screens/utils/search_dropdown.dart';
import 'package:flutter/material.dart';
import '../../helper/api_helper.dart';
import '../utils/prefix_name_field.dart';

class AddEditPatientScreen extends StatefulWidget {
  final Map<String, dynamic>? patient;

  const AddEditPatientScreen({super.key, this.patient});

  @override
  _AddEditPatientScreenState createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _pNameController;
  late TextEditingController _pAddressController;
  late TextEditingController _pContactController;
  late TextEditingController _pGenderController;
  late TextEditingController _pAgeController;
  late TextEditingController _drOidController;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
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
      text: widget.patient?['Pgender'] ?? 'Male',
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
  }

  @override
  void dispose() {
    _pNameController.dispose();
    _pAddressController.dispose();
    _pContactController.dispose();
    _pGenderController.dispose();
    _pAgeController.dispose();
    _drOidController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      // Get the full name from the PrefixNameField
      final patientData = {
        'Pname': _pNameController.text,
        'Paddress': _pAddressController.text,
        'Pcontact': _pContactController.text,
        'Pgender': _pGenderController.text,
        'Page': _pAgeController.text,
        'DrOID': _drOidController.text,
        'Tital': _titleController.text,
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
          print(e);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save patient')));
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
        elevation: 0,
        actions: [
          if (widget.patient != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Add delete functionality
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
                  // Header card with improved design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Form fields with improved UX
                  _buildSectionCard(
                    context,
                    widget.patient == null ? 'Add Patient' : 'Update Patient',
                    [
                      PrefixNameField(
                        prefixes: [
                          'Mr.',
                          'Mrs.',
                          'Ms.',
                          'Dr.',
                          'Prof.',
                        ], // Dropdown items
                        nameController: _pNameController,
                        prefixController: _titleController,
                        hintText: "Enter patient full name",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter full name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownField(
                        controller: _pGenderController,
                        labelText: 'Gender',
                        icon: Icons.wc,
                        items: ['Male', 'Female', 'Other'],
                      ),
                      _buildTextField(
                        controller: _pAgeController,
                        labelText: 'Age',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                      ),
                      _buildTextField(
                        controller: _pContactController,
                        labelText: 'Contact Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      SearchDropdown(
                        apiUrl: "doctors-list",
                        hintText: "Search Doctor",
                        displayKey: "Name",
                        valueKey: "DrOID",
                        initialValue: widget.patient?['DrOID']
                            ?.toString(), // Pass initial value
                        onItemSelected: (doctor) {
                          setState(() {
                            _drOidController.text = doctor['DrOID'].toString();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _pAddressController,
                        labelText: 'Address',
                        icon: Icons.location_on,
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Save button with improved design
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
                        onPressed: _savePatient,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: Text(
                          widget.patient == null
                              ? 'Add Patient'
                              : 'Update Patient',
                          style: const TextStyle(
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
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
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required List<String> items,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
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
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            controller.text = newValue;
          }
        },
        validator: validator,
      ),
    );
  }
}
