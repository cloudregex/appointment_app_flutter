import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helper/api_helper.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
// import '../utils/search_dropdown.dart'; // Commented out as per user request

class MedicineEntry {
  final TextEditingController medicineNameController;
  final TextEditingController dosageController;
  final TextEditingController durationController;
  int? medicineId; // Added medicineId

  MedicineEntry({
    required String medicineName,
    required String dosage,
    required String duration,
    this.medicineId,
  }) : medicineNameController = TextEditingController(text: medicineName),
       dosageController = TextEditingController(text: dosage),
       durationController = TextEditingController(text: duration);

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId, // Include medicineId
      'medicineName': medicineNameController.text,
      'dosage': dosageController.text,
      'duration': durationController.text,
    };
  }
}

class AddPrescriptionScreen extends StatefulWidget {
  final Map<String, dynamic>? appointmentData;

  const AddPrescriptionScreen({super.key, this.appointmentData});

  @override
  _AddPrescriptionScreenState createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _historyController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _contentNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _adviceController = TextEditingController();
  final TextEditingController _apDateController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _invController = TextEditingController();
  final TextEditingController _generalExaminationController =
      TextEditingController();
  final TextEditingController _clinicalFindingController =
      TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();

  final List<MedicineEntry> _medicineEntries = [];
  List<Map<String, dynamic>> _investigationList = []; // Moved to class level

  bool _isLoading = false;
  final _formBottomSheetKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
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

      final List<Map<String, dynamic>> prescriptionDataList = [];

      for (var entry in _medicineEntries) {
        if (entry.medicineNameController.text.isNotEmpty) {
          prescriptionDataList.add({
            'Date': _dateController.text,
            'POID': widget.appointmentData?['POID'],
            'History': _historyController.text,
            'ItemName': entry.medicineNameController.text,
            'Notes': entry.dosageController.text,
            'Advice': _adviceController.text,
            'ApDate': _apDateController.text.isEmpty
                ? _dateController.text
                : _apDateController.text,
            'cc': _ccController.text,
            'cf': _clinicalFindingController.text,
            'ge': _generalExaminationController.text,
            'inv': _invController.text,
            'Diagnosis': _diagnosisController.text,
            'Name': widget.appointmentData?['Name'] ?? 'N/A',
            'medicineId': entry.medicineId,
            'ContentName': entry.dosageController.text,
            'Total': entry.durationController.text,
          });
        }
      }

      // If no medicines are added, add at least one default entry
      if (prescriptionDataList.isEmpty) {
        prescriptionDataList.add({
          'Date': _dateController.text,
          'POID': widget.appointmentData?['POID'] ?? 0, // Default to 0 if null
          'History': _historyController.text,
          'ItemName': _itemNameController.text,
          'ContentName': _contentNameController.text,
          'Notes': _notesController.text,
          'Advice': _adviceController.text,
          'ApDate': _apDateController.text.isEmpty
              ? _dateController.text
              : _apDateController.text,
          'cc': _ccController.text,
          'cf': _clinicalFindingController.text,
          'ge': _generalExaminationController.text,
          'inv': _invController.text,
          'Diagnosis': _diagnosisController.text,
          'Name': widget.appointmentData?['Name'] ?? 'N/A',
          'medicineId': 0, // Default to 0 instead of null
          'dosage': '', // Default to empty string instead of null
          'duration': '', // Default to empty string instead of null
        });
      }

      // ✅ Properly encode data before sending
      final String jsonData = JsonEncoder.withIndent(
        '  ',
      ).convert(prescriptionDataList);
      try {
        final response = await ApiHelper.request(
          'prescriptions',
          method: 'POST',
          body: jsonData,
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
                (response is Map)
                    ? (response['message'] ??
                          'Failed to create prescription record.')
                    : 'Failed to create prescription record.',
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
                    _buildTextField(
                      'General examination',
                      _generalExaminationController,
                      'Enter general examination',
                      isRequired: false,
                    ),
                    _buildDateField(), // Date field
                    _buildTextField(
                      'History',
                      _historyController,
                      'Enter history',
                      isRequired: false,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                    ),
                    _buildTextField(
                      'Chief Complaints',
                      _ccController,
                      'Enter Chief Complaints',
                      isRequired: false,
                      maxLines: 3,
                    ),
                    _buildTextField(
                      'Clinical Finding',
                      _clinicalFindingController,
                      'Enter Clinical Finding',
                      isRequired: false,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16.0),
                    _buildMedicineTable(),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      'Diagnosis',
                      _diagnosisController,
                      'Enter Diagnosis',
                      isRequired: false,
                      maxLines: 3,
                    ),
                    _buildTextField(
                      'Investigation',
                      _invController,
                      'Enter Investigation',
                      isRequired: false,
                      maxLines: 3,
                      hasAddButton: true,
                      onAddButtonPressed: _showAddInvestigationBottomSheet,
                    ),
                    _buildTextField(
                      'Advice',
                      _adviceController,
                      'Enter Advice',
                      isRequired: false,
                      maxLines: 3,
                      hasAddButton: true,
                      onAddButtonPressed: _showAddAdviceBottomSheet,
                    ),
                    _buildApDateField(), // Appointment Date field
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

  void _confirmDeleteMedicine(int index) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this medicine entry?',
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
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _medicineEntries.removeAt(index);
        });
      }
    });
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isRequired = false,
    bool readOnly = false,
    int? maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool hasAddButton = false,
    VoidCallback? onAddButtonPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          prefixIcon: _getIconForLabel(label),
          suffixIcon: hasAddButton
              ? IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onAddButtonPressed,
                )
              : null,
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
      case 'pt name':
        return const Icon(Icons.person);
      case 'p no':
        return const Icon(Icons.numbers);
      case 'general examination':
        return const Icon(Icons.medical_information);
      case 'clinical finding':
        return const Icon(Icons.find_in_page);
      case 'diagnosis':
        return const Icon(Icons.medical_services);
      case 'investigation':
        return const Icon(Icons.science);
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
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

  Widget _buildMedicineTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Medicine List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _showAddMedicineBottomSheet,
              icon: const Icon(Icons.add),
              label: const Text('Add Medicine'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              Table(
                border: TableBorder.symmetric(
                  inside: const BorderSide(color: Colors.grey, width: 0.5),
                ),
                children: [
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Medicine Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Dosage',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Duration',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ..._medicineEntries.asMap().entries.map((entry) {
                    int index = entry.key;
                    MedicineEntry medicineEntry = entry.value;
                    return TableRow(
                      children: [
                        GestureDetector(
                          onLongPress: () => _confirmDeleteMedicine(index),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              medicineEntry.medicineNameController.text,
                            ), // Display medicine name
                          ),
                        ),
                        GestureDetector(
                          onLongPress: () => _confirmDeleteMedicine(index),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(medicineEntry.dosageController.text),
                          ),
                        ),
                        GestureDetector(
                          onLongPress: () => _confirmDeleteMedicine(index),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(medicineEntry.durationController.text),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddMedicineBottomSheet() {
    final TextEditingController _tempMedicineNameController =
        TextEditingController();
    final TextEditingController _tempDosageController = TextEditingController();
    final TextEditingController _tempDurationController =
        TextEditingController();
    int? _tempMedicineId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Medicine'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formBottomSheetKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TypeAheadField<Map<String, dynamic>>(
                        controller:
                            _tempMedicineNameController, // ✅ persistent controller
                        builder: (context, controller, focusNode) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Medicine Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Medicine name is required';
                              }
                              return null;
                            },
                          );
                        },
                        suggestionsCallback: (pattern) async {
                          final response = await ApiHelper.request(
                            'item-list?search=$pattern',
                            method: 'GET',
                          );
                          if (response != null && response is List) {
                            return response.cast<Map<String, dynamic>>();
                          }
                          return [];
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion['ItemName'] ?? ''),
                          );
                        },
                        onSelected: (suggestion) {
                          setStateDialog(() {
                            _tempMedicineNameController.text =
                                suggestion['ItemName'] ?? '';
                            _tempMedicineId = suggestion['ItemID'];
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tempDosageController,
                        decoration: const InputDecoration(
                          labelText: 'Dosage',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Dosage is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tempDurationController,
                        decoration: const InputDecoration(
                          labelText: 'Duration',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Duration is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formBottomSheetKey.currentState!.validate()) {
                      setState(() {
                        _medicineEntries.add(
                          MedicineEntry(
                            medicineName: _tempMedicineNameController.text,
                            dosage: _tempDosageController.text,
                            duration: _tempDurationController.text,
                            medicineId: _tempMedicineId,
                          ),
                        );
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddInvestigationBottomSheet() {
    final TextEditingController _tempInvestigationNameController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Investigation'),
          content: SingleChildScrollView(
            child: Form(
              key: _formBottomSheetKey, // Reusing the existing form key
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TypeAheadField<Map<String, dynamic>>(
                    builder: (context, controller, focusNode) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Investigation Name',
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                    suggestionsCallback: (pattern) async {
                      final response = await ApiHelper.request(
                        'invention-list?search=$pattern',
                        method: 'GET',
                      );
                      if (response != null && response is List) {
                        return response.cast<Map<String, dynamic>>();
                      }
                      return const <Map<String, dynamic>>[];
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion['TestName'] ?? ''),
                      );
                    },
                    onSelected: (suggestion) {
                      final newInvestigation = suggestion['TestName'] ?? '';
                      setState(() {
                        final currentText = _invController.text;
                        List<String> investigations = currentText
                            .split(RegExp(r'[,;\n]'))
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();

                        if (!investigations.contains(newInvestigation)) {
                          if (currentText.isEmpty ||
                              currentText.endsWith('\n')) {
                            _invController.text += '$newInvestigation, \n';
                          } else {
                            _invController.text += ',\n$newInvestigation, \n';
                          }
                        }
                        _tempInvestigationNameController.clear();
                      });
                      Navigator.pop(
                        context,
                      ); // Close the dialog after selection
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_tempInvestigationNameController.text.isNotEmpty) {
                  setState(() {
                    final currentText = _invController.text;
                    final newInvestigation =
                        _tempInvestigationNameController.text;

                    List<String> investigations = currentText
                        .split(RegExp(r'[,;\n]'))
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();

                    if (!investigations.contains(newInvestigation)) {
                      if (currentText.isEmpty || currentText.endsWith('\n')) {
                        _invController.text += '$newInvestigation, \n';
                      } else {
                        _invController.text += ',\n$newInvestigation, \n';
                      }
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddAdviceBottomSheet() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Advice'),
          content: SingleChildScrollView(
            child: Form(
              key: _formBottomSheetKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TypeAheadField<Map<String, dynamic>>(
                    builder: (context, controller, focusNode) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Advice Name',
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                    suggestionsCallback: (pattern) async {
                      final response = await ApiHelper.request(
                        'advice-list?search=$pattern',
                        method: 'GET',
                      );
                      if (response != null && response is List) {
                        return response.cast<Map<String, dynamic>>();
                      }
                      return const <Map<String, dynamic>>[];
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(title: Text(suggestion['AdvName'] ?? ''));
                    },
                    onSelected: (suggestion) {
                      final newAdvice =
                          '${suggestion['AdvName'] ?? ''}: ${suggestion['AdvNote'] ?? ''}';
                      setState(() {
                        final currentText = _adviceController.text;
                        List<String> adviceList = currentText
                            .split(RegExp(r'[,;\n]'))
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();

                        if (!adviceList.contains(newAdvice)) {
                          if (currentText.isEmpty ||
                              currentText.endsWith('\n')) {
                            _adviceController.text += '$newAdvice, \n';
                          } else {
                            _adviceController.text += ',\n$newAdvice, \n';
                          }
                        }
                      });
                      Navigator.pop(
                        context,
                      ); // Close the dialog after selection
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
