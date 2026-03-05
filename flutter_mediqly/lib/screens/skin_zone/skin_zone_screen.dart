// ─── Skin Zone Screen ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../services/gemini_service.dart';

class SkinZoneScreen extends StatefulWidget {
  const SkinZoneScreen({super.key});
  @override State<SkinZoneScreen> createState() => _SkinZoneScreenState();
}

class _SkinZoneScreenState extends State<SkinZoneScreen> {
  File? _image;
  String _analysis = '';
  bool _loading = false;

  Future<void> _pickImage(ImageSource src) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: src, imageQuality: 80);
    if (xFile == null || !mounted) return;
    setState(() { _image = File(xFile.path); _analysis = ''; });
  }

  Future<void> _analyze() async {
    if (_image == null || !GeminiService.instance.hasKey) return;
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final bytes = await _image!.readAsBytes();
      final result = await GeminiService.instance.analyzeImage(
        bytes.toList(), 'image/jpeg',
        'Analyze this skin image as a dermatology AI. Identify possible conditions, severity (mild/moderate/severe), and provide care recommendations. Always advise consulting a dermatologist for proper diagnosis.',
      );
      if (!mounted) return;
      setState(() => _analysis = result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _analysis = 'Analysis failed. Please check your API key and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SingleChildScrollView(
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFEF4444)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18), onPressed: context.read<NavigationProvider>().goBack, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              const SizedBox(width: 8),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Skin Zone AI', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                Text('AI-Powered Dermatology Analysis', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Camera/gallery buttons
              Row(children: [
                Expanded(child: _PickButton(icon: Icons.camera_alt_rounded, label: 'Take Photo', onTap: () => _pickImage(ImageSource.camera))),
                const SizedBox(width: 10),
                Expanded(child: _PickButton(icon: Icons.photo_library_rounded, label: 'Gallery', onTap: () => _pickImage(ImageSource.gallery))),
              ]),
              const SizedBox(height: 16),

              // Image preview
              if (_image != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _analyze,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899)),
                    child: _loading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Analyze Skin'),
                  ),
                ),
              ],

              if (_analysis.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [Icon(Icons.biotech_rounded, color: Color(0xFFEC4899), size: 16), SizedBox(width: 8), Text('AI Dermatology Analysis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))]),
                    const SizedBox(height: 10),
                    Text(_analysis, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.6)),
                  ]),
                ),
              ],

              if (_image == null) ...[
                const SizedBox(height: 24),
                Container(
                  height: 160,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, style: BorderStyle.solid)),
                  child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.face_retouching_natural, size: 48, color: AppColors.textSecondary),
                    SizedBox(height: 10),
                    Text('Upload a skin photo for AI analysis', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ]),
                ),
              ],
              const SizedBox(height: 80),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _PickButton extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _PickButton({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Column(children: [Icon(icon, color: AppColors.primaryBlue, size: 22), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))]),
    ),
  );
}
