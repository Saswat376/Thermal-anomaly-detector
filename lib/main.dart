import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const AnomalyDetectionApp());
}

class AnomalyDetectionApp extends StatelessWidget {
  const AnomalyDetectionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thermal Anomaly Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness:
            Brightness.dark, // Dark theme for better thermal image viewing
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thermal Anomaly Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTIusiFYnRYD4nOOsPt8JVite61b_nDERzFQQ&s', // You'll need to add this asset
              height: 150,
            ),
            const SizedBox(height: 40),
            const Text(
              'Detect anomalies in thermal drone footage',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DetectionPage()),
                );
              },
              child:
                  const Text('Start Detection', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
              child: const Text('About'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetectionPage extends StatefulWidget {
  const DetectionPage({Key? key}) : super(key: key);

  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  List<AnalysisResult> _results = [];
  bool _isProcessing = false;
  bool _isAnalysisComplete = false;

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
          _isAnalysisComplete = false;
          _results = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<void> _pickFolder() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        final directory = Directory(selectedDirectory);
        final List<FileSystemEntity> entities = directory.listSync();
        final imageFiles = entities
            .whereType<File>()
            .where((file) =>
                file.path.endsWith('.jpg') ||
                file.path.endsWith('.jpeg') ||
                file.path.endsWith('.png'))
            .toList();

        setState(() {
          _selectedImages = imageFiles;
          _isAnalysisComplete = false;
          _results = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking folder: $e')),
      );
    }
  }

  Future<void> _analyzeImages() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select images first')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate analysis with mock results
    await Future.delayed(const Duration(seconds: 3));

    // Generate mock analysis results
    final List<AnalysisResult> results = [];
    for (var i = 0; i < _selectedImages.length; i++) {
      final isAnomaly = i % 3 == 0; // Mock: every 3rd image has anomaly
      final confidenceScore =
          isAnomaly ? 0.7 + (i % 3) * 0.1 : 0.2 + (i % 5) * 0.05;

      results.add(AnalysisResult(
        image: _selectedImages[i],
        hasAnomaly: isAnomaly,
        confidenceScore: confidenceScore,
        boundingBoxes: isAnomaly
            ? [
                Rect.fromLTWH(100, 100, 50, 70),
              ]
            : [],
      ));
    }

    // Sort results by confidence score (highest first)
    results.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));

    setState(() {
      _isProcessing = false;
      _isAnalysisComplete = true;
      _results = results;
    });

    // Navigate to results page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(results: _results),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Import Images',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImagesFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Select Images'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickFolder,
                          icon: const Icon(Icons.folder),
                          label: const Text('Select Folder'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Selected: ${_selectedImages.length} images',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedImages.isNotEmpty) ...[
              const Text(
                'Preview:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      _selectedImages.length > 10 ? 10 : _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.file(
                        _selectedImages[index],
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              if (_selectedImages.length > 10)
                Text('+ ${_selectedImages.length - 10} more images'),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _isProcessing ? null : _analyzeImages,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.green,
              ),
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Text('Processing...'),
                      ],
                    )
                  : const Text('Start Analysis'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final List<AnalysisResult> results;

  const ResultsPage({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Count anomalies
    final anomalyCount = results.where((result) => result.hasAnomaly).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.blue.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Analysis Complete',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Analyzed ${results.length} images',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Found $anomalyCount potential anomalies',
                      style: TextStyle(
                        fontSize: 16,
                        color: anomalyCount > 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: result.hasAnomaly
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  child: ListTile(
                    leading: Image.file(
                      result.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      result.hasAnomaly
                          ? 'Potential Person Detected'
                          : 'Normal Image',
                      style: TextStyle(
                        color: result.hasAnomaly ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Confidence: ${(result.confidenceScore * 100).toStringAsFixed(1)}%',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(result: result),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final AnalysisResult result;

  const DetailPage({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(result.hasAnomaly ? 'Anomaly Detail' : 'Normal Image'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Stack(
                children: [
                  Image.file(
                    result.image,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  if (result.hasAnomaly)
                    CustomPaint(
                      size: Size.infinite,
                      painter: BoundingBoxPainter(result.boundingBoxes),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            result.hasAnomaly
                                ? Icons.warning
                                : Icons.check_circle,
                            color:
                                result.hasAnomaly ? Colors.red : Colors.green,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            result.hasAnomaly
                                ? 'Anomaly Detected'
                                : 'Normal Image',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ResultInfoRow(
                        label: 'Confidence Score',
                        value:
                            '${(result.confidenceScore * 100).toStringAsFixed(1)}%',
                      ),
                      const Divider(),
                      ResultInfoRow(
                        label: 'Classification',
                        value: result.hasAnomaly
                            ? 'Potential Person'
                            : 'No Person',
                      ),
                      if (result.hasAnomaly) ...[
                        const Divider(),
                        ResultInfoRow(
                          label: 'Detected Regions',
                          value: '${result.boundingBoxes.length}',
                        ),
                      ],
                      const Divider(),
                      const ResultInfoRow(
                        label: 'Analysis Method',
                        value: 'PatchCore + Transfer Learning',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (result.hasAnomaly)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Here would be code to notify rescue teams
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alert sent to rescue team!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Alert Rescue Team'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ResultInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ResultInfoRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade300,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Rect> boundingBoxes;

  BoundingBoxPainter(this.boundingBoxes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var box in boundingBoxes) {
      canvas.drawRect(box, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Thermal Anomaly Detection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'This application helps search and rescue teams identify potential missing persons in thermal drone footage using AI-powered anomaly detection.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'How it works:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. Upload thermal drone images or folders\n'
              '2. Our AI model analyzes each image\n'
              '3. Potential human signatures are highlighted\n'
              '4. Results are prioritized by confidence\n'
              '5. Rescue teams can be alerted about findings',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Technology:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This app uses transfer learning techniques adapted from industrial anomaly detection models like PatchCore, repurposed for humanitarian search and rescue operations.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalysisResult {
  final File image;
  final bool hasAnomaly;
  final double confidenceScore;
  final List<Rect> boundingBoxes;

  AnalysisResult({
    required this.image,
    required this.hasAnomaly,
    required this.confidenceScore,
    required this.boundingBoxes,
  });
}
