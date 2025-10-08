import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helper/api_helper.dart';

class EditTPRScreen extends StatefulWidget {
  final Map<String, dynamic> tprRecord;

  const EditTPRScreen({super.key, required this.tprRecord});

  @override
  _EditTPRScreenState createState() => _EditTPRScreenState();
}

class _EditTPRScreenState extends State<EditTPRScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _ipdNoController = TextEditingController();
  final _tController = TextEditingController();
  final _pController = TextEditingController();
  final _rController = TextEditingController();
  final _bpController = TextEditingController();
  final _itController = TextEditingController();
  final _opController = TextEditingController();
  final _cController = TextEditingController();
  final _aController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill form for editing
    _dateController.text = widget.tprRecord['Date'] ?? '';
    _timeController.text = widget.tprRecord['Time'] ?? '';
    _ipdNoController.text = (widget.tprRecord['IPDNo'] ?? '').toString();
    _tController.text = (widget.tprRecord['T'] ?? '').toString();
    _pController.text = (widget.tprRecord['P'] ?? '').toString();
    _rController.text = (widget.tprRecord['R'] ?? '').toString();
    _bpController.text = (widget.tprRecord['bp'] ?? '').toString();
    _itController.text = (widget.tprRecord['it'] ?? '').toString();
    _opController.text = (widget.tprRecord['op'] ?? '').toString();
    _cController.text = (widget.tprRecord['c'] ?? '').toString();
    _aController.text = (widget.tprRecord['a'] ?? '').toString();
  }

  @override
  void dispose() {
    // Dispose controllers
    _dateController.dispose();
    _timeController.dispose();
    _ipdNoController.dispose();
    _tController.dispose();
    _pController.dispose();
    _rController.dispose();
    _bpController.dispose();
    _itController.dispose();
    _opController.dispose();
    _cController.dispose();
    _aController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'tproid': widget.tprRecord['TPROID'],
        'date': _dateController.text,
        'time': _timeController.text,
        'ipdNo': _ipdNoController.text,
        't': _tController.text,
        'p': _pController.text,
        'r': _rController.text,
        'bp': _bpController.text,
        'it': _itController.text,
        'op': _opController.text,
        'c': _cController.text,
        'a': _aController.text,
      };
      final result = await ApiHelper.request(
        'tpr/${widget.tprRecord['TPROID']}',
        method: 'PUT',
        body: data,
      );

      if (result != null) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${result['message']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit TPR Record')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSectionCard(context, 'TPR Details', [
                  _buildDateField(),
                  const SizedBox(height: 20),
                  _buildTimeField(),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _tController,
                    labelText: 'Temperature',
                    icon: Icons.thermostat,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _pController,
                    labelText: 'Pulse',
                    icon: Icons.favorite,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _rController,
                    labelText: 'Respiration Rate',
                    icon: Icons.air,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _bpController,
                    labelText: 'Blood Pressure',
                    icon: Icons.speed,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _itController,
                    labelText: 'Intake (ml)',
                    icon: Icons.local_drink,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _opController,
                    labelText: 'Output (ml)',
                    icon: Icons.outbox,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _cController,
                    labelText: 'Condition',
                    icon: Icons.notes,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _aController,
                    labelText: 'Advice',
                    icon: Icons.lightbulb,
                  ),
                ]),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Date',
        prefixIcon: Icon(
          Icons.calendar_today,
          color: Theme.of(context).primaryColor,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          setState(() {
            _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
    );
  }

  Widget _buildTimeField() {
    return TextFormField(
      controller: _timeController,
      decoration: InputDecoration(
        labelText: 'Time',
        prefixIcon: Icon(
          Icons.access_time,
          color: Theme.of(context).primaryColor,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter time (HH:MM format)';
        }
        // Validate time format (HH:MM)
        if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
          return 'Please enter valid time (HH:MM format)';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
