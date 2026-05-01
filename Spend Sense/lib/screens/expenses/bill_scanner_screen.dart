import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class BillScannerScreen extends StatefulWidget {
  const BillScannerScreen({super.key});

  @override
  State<BillScannerScreen> createState() => _BillScannerScreenState();
}

class _BillScannerScreenState extends State<BillScannerScreen> {
  File? _imageFile;
  String _extractedText = '';
  String _detectedAmount = '';
  String _detectedDate = '';
  String _detectedCategory = '';
  bool _isProcessing = false;

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _captureAndProcessImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isProcessing = true;
          _extractedText = '';
          _detectedAmount = '';
          _detectedDate = '';
          _detectedCategory = '';
        });
        await _processImage();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera error: Please ensure you have granted camera permissions.')),
        );
      }
    }
  }

  Future<void> _processImage() async {
    if (_imageFile == null) return;

    try {
      final inputImage = InputImage.fromFile(_imageFile!);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No text could be found in the image. Please try a clearer picture.')),
          );
        }
      }

      setState(() {
        _extractedText = recognizedText.text;
      });
      
      _extractData();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OCR failed to read the image. Please try a clearer picture.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _extractData() {
    final text = _extractedText.toLowerCase();
    
    // 1. Amount Extraction
    final RegExp amountRegex = RegExp(r'\$?\d+(?:,\d{3})*(?:\.\d{2})?\b');
    final Iterable<Match> amountMatches = amountRegex.allMatches(_extractedText);
    
    double maxAmount = 0.0;
    for (final Match match in amountMatches) {
      final String matchStr = match.group(0) ?? '';
      final String cleanStr = matchStr.replaceAll('\$', '').replaceAll(',', '');
      final double? amount = double.tryParse(cleanStr);
      if (amount != null && amount > maxAmount) {
        maxAmount = amount;
      }
    }
    
    // 2. Date Extraction (e.g. 12/04/2023, 12-04-2023)
    final RegExp dateRegex = RegExp(r'\b(\d{1,4}[/-]\d{1,2}[/-]\d{1,4})\b');
    final Match? dateMatch = dateRegex.firstMatch(_extractedText);
    String foundDate = '';
    if (dateMatch != null) {
      foundDate = dateMatch.group(1) ?? '';
      try {
        final parts = foundDate.split(RegExp(r'[/-]'));
        if (parts.length == 3) {
          if (parts[0].length == 4) {
             foundDate = '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
          } else if (parts[2].length == 4) {
             foundDate = '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
          }
        }
      } catch (e) {}
    }

    // 3. Category Extraction
    String foundCategory = '';
    if (text.contains('food') || text.contains('restaurant') || text.contains('meal') || text.contains('lunch') || text.contains('cafe')) {
      foundCategory = 'Food';
    } else if (text.contains('bus') || text.contains('uber') || text.contains('taxi') || text.contains('flight') || text.contains('train') || text.contains('travel') || text.contains('cab')) {
      foundCategory = 'Travel';
    } else if (text.contains('shopping') || text.contains('clothes') || text.contains('shoes') || text.contains('mall') || text.contains('store')) {
      foundCategory = 'Shopping';
    } else if (text.contains('bill') || text.contains('electricity') || text.contains('water') || text.contains('internet') || text.contains('rent')) {
      foundCategory = 'Bills';
    }

    setState(() {
      _detectedAmount = maxAmount > 0 ? maxAmount.toStringAsFixed(2) : 'No amount detected';
      _detectedDate = foundDate;
      _detectedCategory = foundCategory;
    });
  }
  
  void _returnData() {
    if (_detectedAmount.isNotEmpty && _detectedAmount != 'No amount detected') {
      Navigator.pop(context, {
        'amount': _detectedAmount,
        'date': _detectedDate,
        'category': _detectedCategory,
        'rawText': _extractedText,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please detect a valid amount first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Bill'),
        actions: [
          if (_detectedAmount.isNotEmpty && _detectedAmount != 'No amount detected')
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _returnData,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _imageFile!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: const Center(
                  child: Text(
                    'No image captured',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _captureAndProcessImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Receipt'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else if (_extractedText.isNotEmpty) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detected Data',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Amount: ${_detectedAmount.isNotEmpty && _detectedAmount != 'No amount detected' ? '\$$_detectedAmount' : _detectedAmount}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_detectedDate.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Date: $_detectedDate', style: Theme.of(context).textTheme.titleMedium),
                      ],
                      if (_detectedCategory.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Category: $_detectedCategory', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Extracted Text:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  _extractedText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              if (_detectedAmount.isNotEmpty && _detectedAmount != 'No amount detected')
                ElevatedButton(
                  onPressed: _returnData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Use Extracted Data', style: TextStyle(fontSize: 16)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
