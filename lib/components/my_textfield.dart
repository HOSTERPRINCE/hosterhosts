
// Modern TextField Component
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


// Responsive TextField Component
class ResponsiveTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final IconData icon;
  final bool isDesktop;

  const ResponsiveTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.icon,
    required this.isDesktop,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isDesktop ? 50 : 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        focusNode: focusNode,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: isDesktop ? 14 : 13,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.cyan,
            size: isDesktop ? 20 : 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.cyan,
              width: 2,
            ),
          ),
          fillColor: Colors.white.withOpacity(0.08),
          filled: true,
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: isDesktop ? 14 : 13,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 12,
            vertical: isDesktop ? 16 : 14,
          ),
        ),
      ),
    );
  }
}