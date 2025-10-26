import 'package:flutter/material.dart';

import '../app_colors.dart';

class Placeholder2Page extends StatefulWidget {
  const Placeholder2Page({super.key});

  @override
  State<Placeholder2Page> createState() => _Placeholder2PageState();
}

class _Placeholder2PageState extends State<Placeholder2Page> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg, // keep your beige background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(72, 32, 32, 32),
          // leave space for sidebar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Title ---
              const Text(
                "Title",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),

              // --- White Box ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: const Center(
                    child: Text(
                      "Your content here",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
