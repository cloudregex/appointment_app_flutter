import 'package:flutter/material.dart';

class EditPrescriptionScreen extends StatefulWidget {
  final Map<String, dynamic> prescription;

  const EditPrescriptionScreen({super.key, required this.prescription});

  @override
  _EditPrescriptionScreenState createState() => _EditPrescriptionScreenState();
}

class _EditPrescriptionScreenState extends State<EditPrescriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Prescription'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prescription Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prescription Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Prescription No: ${widget.prescription['PrescriptionNo'] ?? widget.prescription['id'] ?? widget.prescription['prescription_id'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Patient Information
                _buildDetailCard(
                  'Patient Information',
                  [
                    _buildDetailRow('Name', widget.prescription['Name'] ?? widget.prescription['patient_name'] ?? widget.prescription['PatientName'] ?? 'N/A'),
                    if (widget.prescription['POID'] != null)
                      _buildDetailRow('POID', widget.prescription['POID']),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // Doctor Information
                _buildDetailCard(
                  'Doctor Information',
                  [
                    _buildDetailRow('Name', widget.prescription['doctor_name'] ?? widget.prescription['DoctorName'] ?? 'N/A'),
                    _buildDetailRow('Specialization', widget.prescription['doctor_specialization'] ?? widget.prescription['DoctorSpecialization'] ?? 'N/A'),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // Prescription Details
                _buildDetailCard(
                  'Prescription Details',
                  [
                    _buildDetailRow('Date', widget.prescription['Date'] ?? widget.prescription['date'] ?? widget.prescription['created_at'] ?? 'N/A'),
                    if (widget.prescription['ApDate'] != null)
                      _buildDetailRow('Appointment Date', widget.prescription['ApDate']),
                    if (widget.prescription['History'] != null)
                      _buildDetailRow('History', widget.prescription['History']),
                    if (widget.prescription['ItemName'] != null)
                      _buildDetailRow('Item Name', widget.prescription['ItemName']),
                    if (widget.prescription['ContentName'] != null)
                      _buildDetailRow('Content Name', widget.prescription['ContentName']),
                    if (widget.prescription['Notes'] != null)
                      _buildDetailRow('Notes', widget.prescription['Notes']),
                    if (widget.prescription['Advice'] != null)
                      _buildDetailRow('Advice', widget.prescription['Advice']),
                    if (widget.prescription['cc'] != null)
                      _buildDetailRow('CC', widget.prescription['cc']),
                    if (widget.prescription['cf'] != null)
                      _buildDetailRow('CF', widget.prescription['cf']),
                    if (widget.prescription['ge'] != null)
                      _buildDetailRow('GE', widget.prescription['ge']),
                    if (widget.prescription['inv'] != null)
                      _buildDetailRow('INV', widget.prescription['inv']),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement save functionality
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value?.toString() ?? 'N/A',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}