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

        // 👉 Prefix dropdown left side
        prefixIcon: DropdownButtonHideUnderline(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _selectedPrefix,
              hint: const Text("Prefix"),
              items: widget.prefixes
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPrefix = value;
                });
              },
            ),
          ),
        ),
        hintText: "Full Name",
      ),
      validator: (value) => value!.isEmpty ? 'Please enter full name' : null,
    );
  }

  /// 👉 फक्त prefix मिळवण्यासाठी
  String? getPrefix() => _selectedPrefix;

  /// 👉 फक्त नाव (TextField मध्ये typed केलेलं) मिळवण्यासाठी
  String getNameOnly() => widget.nameController.text.trim();

  /// 👉 जर तुला combined हवं असेल तर
  String getFullName() {
    if (_selectedPrefix != null && _selectedPrefix!.isNotEmpty) {
      return '$_selectedPrefix ${widget.nameController.text}'.trim();
    }
    return widget.nameController.text.trim();
  }
}
