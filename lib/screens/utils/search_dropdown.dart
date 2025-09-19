import 'package:appointment_app/helper/api_helper.dart';
import 'package:flutter/material.dart';

class SearchDropdown extends StatefulWidget {
  final String apiUrl;
  final String hintText;
  final String displayKey;
  final String valueKey;
  final String? initialValue; // New parameter for initial value
  final Function(Map<String, dynamic>) onItemSelected;

  const SearchDropdown({
    Key? key,
    required this.apiUrl,
    required this.hintText,
    required this.displayKey,
    required this.valueKey,
    this.initialValue, // New parameter
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _SearchDropdownState createState() => _SearchDropdownState();
}

class _SearchDropdownState extends State<SearchDropdown> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // 👈 focus control
  List<dynamic> _results = [];
  bool _isLoading = false;
  String? _initialDisplayText; // To store the display text for initial value
  bool _initialValueLoaded =
      false; // To track if we've loaded the initial value

  @override
  void initState() {
    super.initState();

    // Load initial display text if initial value is provided
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _loadInitialDisplayText();
    }

    // Focus आलं की रिकामं असलं तरी default records घे
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _controller.text.isEmpty) {
        _search(""); // सर्व record किंवा default API response
      }
    });
  }

  // Method to load display text for initial value
  Future<void> _loadInitialDisplayText() async {
    setState(() => _isLoading = true);

    try {
      // Fetch the item by its ID/value
      final response = await ApiHelper.request(
        '${widget.apiUrl}?${widget.valueKey}=${widget.initialValue}',
        method: 'GET',
      );

      if (response != null && response is List && response.isNotEmpty) {
        final item = response[0] as Map<String, dynamic>;
        setState(() {
          _initialDisplayText = item[widget.displayKey]?.toString() ?? "";
          _controller.text = _initialDisplayText!;
          _initialValueLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("SearchDropdown initial value error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String query) async {
    // Clear initial display text when user starts typing
    if (_initialValueLoaded && query.isNotEmpty) {
      setState(() {
        _initialValueLoaded = false;
      });
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiHelper.request(
        '${widget.apiUrl}?search=$query',
        method: 'GET',
      );

      if (response != null && response is List) {
        setState(() {
          _results = response;
        });
      } else {
        setState(() {
          _results = [];
        });
      }
    } catch (e) {
      debugPrint("SearchDropdown error: $e");
      setState(() => _results = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode, // 👈 attach focus node
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.blue),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
          ),
          onChanged: _search,
        ),
        const SizedBox(height: 8),
        if (_results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index] as Map<String, dynamic>;
                return ListTile(
                  title: Text(item[widget.displayKey]?.toString() ?? ""),
                  onTap: () {
                    widget.onItemSelected(item);
                    _controller.text =
                        item[widget.displayKey]?.toString() ?? "";
                    setState(() {
                      _results = [];
                      _initialValueLoaded = false; // Clear initial value flag
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
