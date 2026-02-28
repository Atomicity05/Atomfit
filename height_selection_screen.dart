import 'package:flutter/material.dart';
import 'weight_selection_screen.dart';

class HeightSelectionScreen extends StatefulWidget {
  const HeightSelectionScreen({super.key});

  @override
  State<HeightSelectionScreen> createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  bool isMetric = false;

  final TextEditingController feetController = TextEditingController();
  final TextEditingController inchController = TextEditingController();
  final TextEditingController cmController = TextEditingController();

  bool get isHeightValid {
    if (isMetric) {
      return cmController.text.isNotEmpty &&
          double.tryParse(cmController.text) != null;
    } else {
      return feetController.text.isNotEmpty &&
          double.tryParse(feetController.text) != null;
    }
  }

  @override
  void dispose() {
    feetController.dispose();
    inchController.dispose();
    cmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.95,
                minHeight: 6,
                backgroundColor: Colors.grey.shade300,
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFF1E7F5C)),
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              "How tall are you?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              "Your height will help us calculate important body stats to help you reach your goals faster.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            if (!isMetric)
              Row(
                children: [
                  _unitField(
                    controller: feetController,
                    label: "Ft",
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _inputField(
                      controller: inchController,
                      hint: "Enter Your Height",
                      suffix: "In",
                    ),
                  ),
                ],
              )
            else
              _inputField(
                controller: cmController,
                hint: "Enter Your Height",
                suffix: "Cm",
              ),

            const SizedBox(height: 24),

            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _toggleButton("Ft/In", !isMetric, () {
                      setState(() => isMetric = false);
                    }),
                    _toggleButton("Cm", isMetric, () {
                      setState(() => isMetric = true);
                    }),
                  ],
                ),
              ),
            ),

            const Spacer(),

            const Text(
              "Don’t worry if you don’t know it precisely – you can change this later from settings.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isHeightValid
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WeightSelectionScreen(),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHeightValid
                      ? const Color(0xFF1E7F5C)
                      : Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required String suffix,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          suffixText: suffix,
        ),
      ),
    );
  }

  Widget _unitField({
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      width: 80,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E7F5C), width: 2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          border: InputBorder.none,
          suffixText: label,
        ),
      ),
    );
  }

  Widget _toggleButton(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E7F5C) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF1E7F5C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
