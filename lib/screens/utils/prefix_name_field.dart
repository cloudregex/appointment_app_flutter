import 'package:flutter/material.dart';

class PrefixNameField extends StatefulWidget {
  final List<String> prefixes;
  final TextEditingController nameController;
  final String? initialPrefix;

  const PrefixNameField({
    Key? key,
    required this.prefixes,
    required this.nameController,
    this.initialPrefix,
  }) : super(key: key);

  @override
  State<PrefixNameField> createState() => _PrefixNameFieldState();
}

class _PrefixNameFieldState extends State<PrefixNameField> {
  String? _selectedPrefix;

  @override
  void initState() {
    super.initState();
    _selectedPrefix = widget.initialPrefix;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.nameController,
      decoration: InputDecoration(
        // rounded border style
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],

        // 👉 left side prefix dropdown
        prefixIcon: DropdownButtonHideUnderline(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _selectedPrefix,
              hint: const Text("Mr."),
              items: widget.prefixes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPrefix = value;
                });
              },
            ),
          ),
        ),

        // 👉 hint style text
        hintText: "Full Name",
      ),
      validator: (value) => value!.isEmpty ? 'Please enter full name' : null,
    );
  }

  /// Helper: Get merged name
  String getFullName() {
    if (_selectedPrefix != null && _selectedPrefix!.isNotEmpty) {
      return '$_selectedPrefix ${widget.nameController.text}'.trim();
    }
    return widget.nameController.text.trim();
  }
}
