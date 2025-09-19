import 'package:flutter/material.dart';

class PrefixNameField extends StatefulWidget {
  final List<String> prefixes;
  final TextEditingController nameController;
  final TextEditingController prefixController; // TextEditingController
  final String? initialPrefix;
  final String? Function(String?)? validator;
  final String hintText;

  const PrefixNameField({
    Key? key,
    required this.prefixes,
    required this.nameController,
    required this.prefixController,
    this.initialPrefix,
    this.validator,
    this.hintText = "Patient full name",
  }) : super(key: key);

  @override
  State<PrefixNameField> createState() => _PrefixNameFieldState();
}

class _PrefixNameFieldState extends State<PrefixNameField> {
  String? _selectedPrefix;

  @override
  void initState() {
    super.initState();

    // Initialize prefix
    _selectedPrefix = widget.initialPrefix ?? widget.prefixController.text;
    widget.prefixController.text = _selectedPrefix ?? "";

    // Listen to prefixController changes
    widget.prefixController.addListener(() {
      if (widget.prefixController.text != _selectedPrefix) {
        setState(() {
          _selectedPrefix = widget.prefixController.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.nameController,
      decoration: InputDecoration(
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
        prefixIcon: DropdownButtonHideUnderline(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value:
                  (widget.prefixes.contains(_selectedPrefix) &&
                      _selectedPrefix != null &&
                      _selectedPrefix!.isNotEmpty)
                  ? _selectedPrefix
                  : null,
              hint: const Text("Prefix"),
              items: widget.prefixes
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPrefix = value;
                  widget.prefixController.text =
                      value ?? ""; // ✅ Correct assignment
                });
              },
            ),
          ),
        ),
        hintText: widget.hintText,
      ),
      validator: widget.validator,
    );
  }
}
