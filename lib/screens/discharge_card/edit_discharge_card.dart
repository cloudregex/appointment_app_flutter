import 'package:flutter/material.dart';
import '../../helper/api_helper.dart';
import '../utils/search_dropdown.dart';

class EditDischargeCardScreen extends StatefulWidget {
  final Map<String, dynamic> patient;
  final Map<String, dynamic> dischargeRecord;

  const EditDischargeCardScreen({
    super.key,
    required this.patient,
    required this.dischargeRecord,
  });

  @override
  _EditDischargeCardScreenState createState() =>
      _EditDischargeCardScreenState();
}

class _EditDischargeCardScreenState extends State<EditDischargeCardScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _doaController = TextEditingController();
  final TextEditingController _dodController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _hisController = TextEditingController();
  final TextEditingController _investigationController =
      TextEditingController();
  final TextEditingController _adviceController = TextEditingController();
  final TextEditingController _followupController = TextEditingController();
  final TextEditingController _t1Controller = TextEditingController();
  final TextEditingController _t2Controller = TextEditingController();
  final TextEditingController _tgController = TextEditingController();
  final TextEditingController _siController = TextEditingController();
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _cithController = TextEditingController();
  final TextEditingController _codController = TextEditingController();
  final TextEditingController _drController = TextEditingController();
  final TextEditingController _otNoteController = TextEditingController();
  final TextEditingController _mlcNoController = TextEditingController();
  String _inchargeDoctorName = '';
  String _rmoDoctorName = '';
  final TextEditingController _pdController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _prController = TextEditingController();
  final TextEditingController _rrController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _pallorController = TextEditingController();
  final TextEditingController _cynController = TextEditingController();
  final TextEditingController _cluController = TextEditingController();
  final TextEditingController _spo2Controller = TextEditingController();
  final TextEditingController _ictController = TextEditingController();
  final TextEditingController _adeController = TextEditingController();
  final TextEditingController _edemaController = TextEditingController();
  final TextEditingController _cnsController = TextEditingController();
  final TextEditingController _cvsController = TextEditingController();
  final TextEditingController _rsController = TextEditingController();

  DateTime? _selectedDOA;
  DateTime? _selectedDOD;

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  void _initializeFormFields() {
    // Initialize controllers with existing data
    _doaController.text = widget.dischargeRecord['DOA']?.toString() ?? '';
    _dodController.text = widget.dischargeRecord['DOD']?.toString() ?? '';
    _diagnosisController.text =
        widget.dischargeRecord['Daignosis']?.toString() ?? '';
    _hisController.text = widget.dischargeRecord['His']?.toString() ?? '';
    _investigationController.text =
        widget.dischargeRecord['Investigation']?.toString() ?? '';
    _adviceController.text = widget.dischargeRecord['Advice']?.toString() ?? '';
    _followupController.text =
        widget.dischargeRecord['Followup']?.toString() ?? '';
    _t1Controller.text = widget.dischargeRecord['T1']?.toString() ?? '';
    _t2Controller.text = widget.dischargeRecord['T2']?.toString() ?? '';
    _tgController.text = widget.dischargeRecord['TG']?.toString() ?? '';
    _siController.text = widget.dischargeRecord['SI']?.toString() ?? '';
    _aController.text = widget.dischargeRecord['a']?.toString() ?? '';
    _ccController.text = widget.dischargeRecord['cc']?.toString() ?? '';
    _cithController.text = widget.dischargeRecord['CITH']?.toString() ?? '';
    _codController.text = widget.dischargeRecord['COD']?.toString() ?? '';
    _drController.text = widget.dischargeRecord['DR']?.toString() ?? '';
    _otNoteController.text = widget.dischargeRecord['OTNote']?.toString() ?? '';
    _mlcNoController.text = widget.dischargeRecord['MLCNo']?.toString() ?? '';
    _inchargeDoctorName = widget.dischargeRecord['Dr1']?.toString() ?? '';
    _rmoDoctorName = widget.dischargeRecord['Dr2']?.toString() ?? '';
    _pdController.text = widget.dischargeRecord['PD']?.toString() ?? '';
    _tempController.text = widget.dischargeRecord['Temp']?.toString() ?? '';
    _prController.text = widget.dischargeRecord['PR']?.toString() ?? '';
    _rrController.text = widget.dischargeRecord['RR']?.toString() ?? '';
    _bpController.text = widget.dischargeRecord['BP']?.toString() ?? '';
    _pallorController.text = widget.dischargeRecord['PALLOR']?.toString() ?? '';
    _cynController.text = widget.dischargeRecord['CYN']?.toString() ?? '';
    _cluController.text = widget.dischargeRecord['CLU']?.toString() ?? '';
    _spo2Controller.text = widget.dischargeRecord['SPO2']?.toString() ?? '';
    _ictController.text = widget.dischargeRecord['ICT']?.toString() ?? '';
    _adeController.text = widget.dischargeRecord['ADE']?.toString() ?? '';
    _edemaController.text = widget.dischargeRecord['EDEMA']?.toString() ?? '';
    _cnsController.text = widget.dischargeRecord['CNS']?.toString() ?? '';
    _cvsController.text = widget.dischargeRecord['CVS']?.toString() ?? '';
    _rsController.text = widget.dischargeRecord['RS']?.toString() ?? '';

    // Parse dates if they exist
    if (widget.dischargeRecord['DOA'] != null &&
        widget.dischargeRecord['DOA'] != '') {
      try {
        DateTime doa = DateTime.parse(widget.dischargeRecord['DOA'].toString());
        _selectedDOA = doa;
        _doaController.text = '${doa.day}/${doa.month}/${doa.year}';
      } catch (e) {
        // If parsing fails, try to handle Y-m-d format specifically
        try {
          // Handle the case where the date is in Y-m-d format
          String dateStr = widget.dischargeRecord['DOA'].toString();
          if (dateStr.contains('-')) {
            List<String> parts = dateStr.split('-');
            if (parts.length == 3) {
              int year = int.parse(parts[0]);
              int month = int.parse(parts[1]);
              int day = int.parse(parts[2]);
              DateTime doa = DateTime(year, month, day);
              _selectedDOA = doa;
              _doaController.text = '${doa.day}/${doa.month}/${doa.year}';
            }
          }
        } catch (e2) {
          // Handle invalid date format
        }
      }
    }

    if (widget.dischargeRecord['DOD'] != null &&
        widget.dischargeRecord['DOD'] != '') {
      try {
        DateTime dod = DateTime.parse(widget.dischargeRecord['DOD'].toString());
        _selectedDOD = dod;
        _dodController.text = '${dod.day}/${dod.month}/${dod.year}';
      } catch (e) {
        // If parsing fails, try to handle Y-m-d format specifically
        try {
          // Handle the case where the date is in Y-m-d format
          String dateStr = widget.dischargeRecord['DOD'].toString();
          if (dateStr.contains('-')) {
            List<String> parts = dateStr.split('-');
            if (parts.length == 3) {
              int year = int.parse(parts[0]);
              int month = int.parse(parts[1]);
              int day = int.parse(parts[2]);
              DateTime dod = DateTime(year, month, day);
              _selectedDOD = dod;
              _dodController.text = '${dod.day}/${dod.month}/${dod.year}';
            }
          }
        } catch (e2) {
          // Handle invalid date format
        }
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _doaController.dispose();
    _dodController.dispose();
    _diagnosisController.dispose();
    _hisController.dispose();
    _investigationController.dispose();
    _adviceController.dispose();
    _followupController.dispose();
    _t1Controller.dispose();
    _t2Controller.dispose();
    _tgController.dispose();
    _siController.dispose();
    _aController.dispose();
    _ccController.dispose();
    _cithController.dispose();
    _codController.dispose();
    _drController.dispose();
    _otNoteController.dispose();
    _mlcNoController.dispose();
    _pdController.dispose();
    _tempController.dispose();
    _prController.dispose();
    _rrController.dispose();
    _bpController.dispose();
    _pallorController.dispose();
    _cynController.dispose();
    _cluController.dispose();
    _spo2Controller.dispose();
    _ictController.dispose();
    _adeController.dispose();
    _edemaController.dispose();
    _cnsController.dispose();
    _cvsController.dispose();
    _rsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isDOA}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDOA
          ? _selectedDOA ?? DateTime.now()
          : _selectedDOD ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (isDOA) {
        _selectedDOA = picked;
        _doaController.text = '${picked.day}/${picked.month}/${picked.year}';
      } else {
        _selectedDOD = picked;
        _dodController.text = '${picked.day}/${picked.month}/${picked.year}';
      }
      setState(() {});
    }
  }

  Future<void> _selectTime({required bool isT1}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      if (isT1) {
        _t1Controller.text = picked.format(context);
      } else {
        _t2Controller.text = picked.format(context);
      }
      setState(() {});
    }
  }

  Future<void> _updateForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'name': widget.patient['Name']?.toString() ?? '',
          'poid': widget.patient['POID']?.toString() ?? '',
          'ipdNo': widget.patient['IPDNO']?.toString() ?? '',
          'doa': _selectedDOA != null
              ? '${_selectedDOA!.year}-${_selectedDOA!.month.toString().padLeft(2, '0')}-${_selectedDOA!.day.toString().padLeft(2, '0')}'
              : null,
          'dod': _selectedDOD != null
              ? '${_selectedDOD!.year}-${_selectedDOD!.month.toString().padLeft(2, '0')}-${_selectedDOD!.day.toString().padLeft(2, '0')}'
              : null,
          'daignosis': _diagnosisController.text,
          'his': _hisController.text,
          'investigation': _investigationController.text,
          'advice': _adviceController.text,
          'followup': _followupController.text,
          't1': _t1Controller.text,
          't2': _t2Controller.text,
          'tg': _tgController.text,
          'si': _siController.text,
          'a': _aController.text,
          'cc': _ccController.text,
          'cith': _cithController.text,
          'cod': _codController.text,
          'dr': _drController.text,
          'otNote': _otNoteController.text,
          'mlcNo': _mlcNoController.text,
          'dr1': _inchargeDoctorName,
          'dr2': _rmoDoctorName,
          'pd': _pdController.text,
          'temp': _tempController.text,
          'pr': _prController.text,
          'rr': _rrController.text,
          'bp': _bpController.text,
          'pallor': _pallorController.text,
          'cyn': _cynController.text,
          'clu': _cluController.text,
          'spo2': _spo2Controller.text,
          'ict': _ictController.text,
          'ade': _adeController.text,
          'edema': _edemaController.text,
          'cns': _cnsController.text,
          'cvs': _cvsController.text,
          'rs': _rsController.text,
        };

        final response = await ApiHelper.request(
          'discharge-card/${widget.dischargeRecord['DisOID']}',
          method: 'PUT',
          body: data,
        );

        if (response != null && response['message'] != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response['message'])));
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update discharge card')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Discharge - ${widget.patient['Name']?.toString()}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildDateField(
                  controller: _doaController,
                  labelText: 'DOA',
                  onTap: () => _selectDate(isDOA: true),
                ),
                _buildTimeField(
                  controller: _t1Controller,
                  labelText: 'Time',
                  onTap: () => _selectTime(isT1: true),
                ),
                _buildDateField(
                  controller: _dodController,
                  labelText: 'DOD',
                  onTap: () => _selectDate(isDOA: false),
                ),
                _buildTimeField(
                  controller: _t2Controller,
                  labelText: 'Time',
                  onTap: () => _selectTime(isT1: false),
                ),

                _buildTextFormField(
                  controller: _mlcNoController,
                  labelText: 'MLC No',
                ),

                _buildTextFormField(
                  controller: _aController,
                  labelText: 'Allergic To',
                  maxLines: 3,
                ),

                SearchDropdown(
                  apiUrl: "doctors-list",
                  hintText: "Search Incharge Doctor",
                  displayKey: "Name",
                  valueKey: "DrOID",
                  initialDisplayText:
                      widget.dischargeRecord['Dr1']?.toString() ?? '',
                  onItemSelected: (doctor) {
                    setState(() {
                      _inchargeDoctorName = doctor['Name']?.toString() ?? '';
                    });
                  },
                ),
                const SizedBox(height: 10),
                SearchDropdown(
                  apiUrl: "doctors-list",
                  hintText: "Search RMO Doctor",
                  displayKey: "Name",
                  valueKey: "DrOID",
                  initialDisplayText:
                      widget.dischargeRecord['Dr2']?.toString() ?? '',
                  onItemSelected: (doctor) {
                    setState(() {
                      _rmoDoctorName = doctor['Name']?.toString() ?? '';
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: _pdController,
                  labelText: 'Provisional Diagnosis',
                ),

                _buildTextFormField(
                  controller: _diagnosisController,
                  labelText: 'Diagnosis',
                  maxLines: 3,
                ),

                _buildTextFormField(
                  controller: _ccController,
                  labelText: 'Chief Complaint',
                  maxLines: 3,
                ),

                _buildTextFormField(
                  controller: _hisController,
                  labelText: 'Past History',
                  maxLines: 3,
                ),

                _buildTextFormField(
                  controller: _investigationController,
                  labelText: 'Investigation',
                  maxLines: 3,
                ),

                _buildTextFormField(
                  controller: _siController,
                  labelText: 'Special Investigation',
                  maxLines: 6,
                ),

                _buildTextFormField(
                  controller: _cithController,
                  labelText: 'Course In Hospital',
                  maxLines: 3,
                ),

                _buildTextFormField(
                  controller: _tgController,
                  labelText: 'Treatment Given',
                  maxLines: 3,
                ),

                _buildTextFormField(
                  controller: _codController,
                  labelText: 'Condition On Discharge',
                  maxLines: 3,
                ),

                _buildTextFormField(
                  controller: _otNoteController,
                  labelText: 'OT Note',
                  maxLines: 4,
                ),

                SearchDropdown(
                  apiUrl: "doctors-list",
                  hintText: "Search Diet Recommendation Doctor",
                  displayKey: "Name",
                  valueKey: "DrOID",
                  onItemSelected: (doctor) {
                    setState(() {
                      _drController.text = doctor['Name']?.toString() ?? '';
                    });
                  },
                ),

                _buildTextFormField(
                  controller: _followupController,
                  labelText: 'Follow-up',
                  maxLines: 3,
                ),

                _buildTextFormField(
                  controller: _adviceController,
                  labelText: 'Advice On Discharge',
                  maxLines: 3,
                ),
                _buildTextFormField(
                  controller: _tempController,
                  labelText: 'Temp',
                ),
                _buildTextFormField(
                  controller: _bpController,
                  labelText: 'B.P',
                ),

                _buildTextFormField(
                  controller: _cynController,
                  labelText: 'Cyanosis',
                ),

                _buildTextFormField(
                  controller: _ictController,
                  labelText: 'Icterus',
                ),

                _buildTextFormField(
                  controller: _cnsController,
                  labelText: 'CNS',
                ),
                _buildTextFormField(
                  controller: _prController,
                  labelText: 'Pulse Rate',
                ),

                _buildTextFormField(
                  controller: _pallorController,
                  labelText: 'Pallor',
                ),

                _buildTextFormField(
                  controller: _cluController,
                  labelText: 'Clubbing',
                ),

                _buildTextFormField(
                  controller: _adeController,
                  labelText: 'Adenopathy',
                ),

                _buildTextFormField(
                  controller: _cvsController,
                  labelText: 'CVS',
                ),

                _buildTextFormField(controller: _rrController, labelText: 'RR'),

                _buildTextFormField(
                  controller: _spo2Controller,
                  labelText: 'SpO2',
                ),

                _buildTextFormField(
                  controller: _edemaController,
                  labelText: 'Edema',
                ),
                _buildTextFormField(controller: _rsController, labelText: 'RS'),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: const Text('Update Discharge Card'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (maxLines == 1 &&
              labelText != 'IPD No' &&
              labelText != 'Patient Name' &&
              !readOnly) {
            if (value == null || value.isEmpty) {
              return 'Please enter $labelText';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String labelText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: onTap,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $labelText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String labelText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: onTap,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $labelText';
          }
          return null;
        },
      ),
    );
  }
}
