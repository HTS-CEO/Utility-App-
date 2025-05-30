// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, unused_local_variable, use_build_context_synchronously, unnecessary_to_list_in_spreads

import 'package:app/chat_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeAppTheme();
  runApp(const ScreenSelectionApp());
}

Future<void> _initializeAppTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;
  SystemChrome.setSystemUIOverlayStyle(
    isDarkMode 
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark,
  );
}

class ScreenSelectionApp extends StatelessWidget {
  const ScreenSelectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        final prefs = snapshot.data as SharedPreferences;
        final isDarkMode = prefs.getBool('darkMode') ?? false;
        
        return MaterialApp(
          title: 'Screen Selection',
          debugShowCheckedModeBanner: false,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          home: const OnboardingScreen(),
        );
      },
    );
  }
}

class AppThemes {
  static final lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    dividerColor: Colors.grey[300],
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    ).apply(
      bodyColor: Colors.grey[800],
      displayColor: Colors.black,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: Colors.grey[800],
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: Colors.grey[300],
      displayColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: 'assets/logo.png',
      title: 'Screen Selection',
      description: 'Create detailed questionnaires for screen selection projects with our intuitive interface',
      color: const Color(0xFF1E88E5),
    ),
    OnboardingPage(
      icon: 'assets/reports.png',
      title: 'PDF Export',
      description: 'Generate professional PDF reports with all your data in one click',
      color: const Color(0xFF00ACC1),
    ),
    OnboardingPage(
      icon: 'assets/security.png',
      title: 'Secure Storage',
      description: 'All your data is encrypted and stored securely on your device',
      color: const Color(0xFF5E35B1),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: 500.ms,
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pages[_currentPage].color,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(page: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: 300.ms,
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _currentPage == index 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _pages[_currentPage].color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 
                            ? 'Get Started' 
                            : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SplashScreen()),
                    ),
                    child: Text(
                      'Skip Introduction',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: page.color,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            page.icon,
            height: 200,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.9), 
              BlendMode.srcIn),
          ).animate().scale(duration: 600.ms).shake(),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideY(),
        ],
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(2000.ms, () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: 800.ms,
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              ),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'app-logo',
              child: SvgPicture.asset(
                'assets/logo.png',
                height: 120,
                colorFilter: const ColorFilter.mode(
                  Colors.white, 
                  BlendMode.srcIn),
              ),
            ).animate()
             .scale(duration: 500.ms, curve: Curves.elasticOut)
             .then(delay: 200.ms)
             .shake(),
            const SizedBox(height: 24),
            Text(
              'Screen Selection',
              style: GoogleFonts.poppins(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn().slideY(),
            Text(
              'Professional Questionnaire',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Questionnaire>> _questionnairesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _questionnairesFuture = QuestionnaireStorage().getQuestionnaires();
  }

  void _refreshQuestionnaires() {
    setState(() {
      _questionnairesFuture = QuestionnaireStorage().getQuestionnaires();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaires'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
           IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToQuestionnaireScreen(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ).animate().scale(delay: 300.ms),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Create New Questionnaire',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start a new screen selection assessment',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('New Questionnaire'),
                      onPressed: () => _navigateToQuestionnaireScreen(),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refreshQuestionnaires(),
                child: FutureBuilder<List<Questionnaire>>(
                  future: _questionnairesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading questionnaires',
                              style: GoogleFonts.poppins(fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _refreshQuestionnaires,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No questionnaires yet',
                              style: GoogleFonts.poppins(fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to create one',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      final questionnaires = _searchQuery.isEmpty
                          ? snapshot.data!
                          : snapshot.data!.where((q) => 
                              q.customer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              q.application.toLowerCase().contains(_searchQuery.toLowerCase()))
                            .toList();

                      return ListView.builder(
                        itemCount: questionnaires.length,
                        itemBuilder: (context, index) {
                          final questionnaire = questionnaires[index];
                          return _buildQuestionnaireCard(questionnaire, index);
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionnaireCard(Questionnaire questionnaire, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToQuestionnaireScreen(questionnaire),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      questionnaire.customer.isNotEmpty
                          ? questionnaire.customer
                          : 'Unnamed Questionnaire',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    questionnaire.createdAt.toString().substring(0, 10),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (questionnaire.application.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.construction_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        questionnaire.application,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (questionnaire.material.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        questionnaire.material,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${questionnaire.numberOfDecks} deck${questionnaire.numberOfDecks > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1);
  }

  void _navigateToQuestionnaireScreen([Questionnaire? questionnaire]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionnaireScreen(
          questionnaire: questionnaire,
          onSave: _refreshQuestionnaires,
        ),
      ),
    ).then((_) => _refreshQuestionnaires());
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Questionnaires'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by customer or application...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class QuestionnaireScreen extends StatefulWidget {
  final Questionnaire? questionnaire;
  final VoidCallback? onSave;

  const QuestionnaireScreen({super.key, this.questionnaire, this.onSave});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  late Questionnaire _questionnaire;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _particleSizeDistribution = {};
  int _numberOfDecks = 1;
  bool _isolationBase = false;
  bool _dustCover = false;
  bool _sprayBars = false;
  bool _motorSupplied = false;
  String _linerRequirements = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questionnaire = widget.questionnaire ??
        Questionnaire(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now(),
        );

    _initializeControllers();
  }

  void _initializeControllers() {
    final fields = [
      'customer', 'plant', 'contactPerson', 'name', 'email', 'phone',
      'application', 'material', 'projectType', 'existingScreen', 'capacity',
      'feedToScreen', 'maxLoad', 'maxPieceSize', 'materialTemp', 'phLevel',
      'moisture', 'bulkDensity', 'topDeckAperture', 'middleDeckAperture',
      'bottomDeckAperture', 'topDeckMaterial', 'middleDeckMaterial',
      'bottomDeckMaterial', 'maxHeight', 'maxWidth', 'maxLength', 'maxWeight'
    ];

    for (var field in fields) {
      _controllers[field] = TextEditingController(
        text: widget.questionnaire?.toJson()[field] ?? '',
      );
    }

    if (widget.questionnaire != null) {
      _numberOfDecks = _questionnaire.numberOfDecks;
      _isolationBase = _questionnaire.isolationBase;
      _dustCover = _questionnaire.dustCover;
      _sprayBars = _questionnaire.sprayBars;
      _motorSupplied = _questionnaire.motorSupplied;
      _linerRequirements = _questionnaire.linerRequirements;
      _particleSizeDistribution.addAll(_questionnaire.particleSizeDistribution);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveQuestionnaire() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() => _isSaving = true);

      _questionnaire = _questionnaire.copyWith(
        customer: _controllers['customer']!.text,
        plant: _controllers['plant']!.text,
        contactPerson: _controllers['contactPerson']!.text,
        name: _controllers['name']!.text,
        email: _controllers['email']!.text,
        phone: _controllers['phone']!.text,
        application: _controllers['application']!.text,
        material: _controllers['material']!.text,
        projectType: _controllers['projectType']!.text,
        existingScreen: _controllers['existingScreen']!.text,
        capacity: _controllers['capacity']!.text,
        feedToScreen: _controllers['feedToScreen']!.text,
        maxLoad: _controllers['maxLoad']!.text,
        maxPieceSize: _controllers['maxPieceSize']!.text,
        materialTemp: _controllers['materialTemp']!.text,
        phLevel: _controllers['phLevel']!.text,
        moisture: _controllers['moisture']!.text,
        bulkDensity: _controllers['bulkDensity']!.text,
        topDeckAperture: _controllers['topDeckAperture']!.text,
        middleDeckAperture: _controllers['middleDeckAperture']!.text,
        bottomDeckAperture: _controllers['bottomDeckAperture']!.text,
        topDeckMaterial: _controllers['topDeckMaterial']!.text,
        middleDeckMaterial: _controllers['middleDeckMaterial']!.text,
        bottomDeckMaterial: _controllers['bottomDeckMaterial']!.text,
        maxHeight: _controllers['maxHeight']!.text,
        maxWidth: _controllers['maxWidth']!.text,
        maxLength: _controllers['maxLength']!.text,
        maxWeight: _controllers['maxWeight']!.text,
        numberOfDecks: _numberOfDecks,
        isolationBase: _isolationBase,
        dustCover: _dustCover,
        sprayBars: _sprayBars,
        motorSupplied: _motorSupplied,
        linerRequirements: _linerRequirements,
        particleSizeDistribution: _particleSizeDistribution,
        updatedAt: DateTime.now(),
      );

      await QuestionnaireStorage().saveQuestionnaire(_questionnaire);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Questionnaire saved successfully'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      
      widget.onSave?.call();
      setState(() => _isSaving = false);
    }
  }

 Future<void> _exportToPDF() async {
  final status = await Permission.storage.request();
  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Storage permission denied')),
    );
    return;
  }

  setState(() => _isSaving = true);
  
  final pdf = pw.Document();
  final logo = await rootBundle.load('assets/logo.png');
  final logoImage = pw.MemoryImage(logo.buffer.asUint8List());

  // Define styles
  final headerStyle = pw.TextStyle(
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue800,
  );

  final tableHeaderStyle = pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.white,
  );

  final tableHeaderDecoration = pw.BoxDecoration(
    color: PdfColors.blue800,
  );

  final tableCellStyle = pw.TextStyle(
    fontSize: 10,
  );

  // Build PDF content
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with logo and document info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(logoImage, width: 100, height: 40),
                pw.Text(
                  'Questionnaire #${_questionnaire.id.substring(0, 8)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            
            // Title
            pw.Text(
              'Screen Selection Questionnaire',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(),
            pw.SizedBox(height: 10),
            
            // 1. Customer Information
            pw.Text('1. Customer Information', style: headerStyle),
            pw.SizedBox(height: 8),
            _buildInfoTable([
              {'Customer': _questionnaire.customer},
              {'Plant': _questionnaire.plant},
              {'Contact Person': _questionnaire.contactPerson},
              {'Email': _questionnaire.email},
              {'Phone': _questionnaire.phone},
            ], tableHeaderStyle, tableHeaderDecoration, tableCellStyle),
            pw.SizedBox(height: 16),
            
            // 2. Technical Specifications
            pw.Text('2. Technical Specifications', style: headerStyle),
            pw.SizedBox(height: 8),
            _buildInfoTable([
              {'Application': _questionnaire.application},
              {'Material': _questionnaire.material},
              {'Project Type': _questionnaire.projectType},
              {'Existing Screen': _questionnaire.existingScreen},
              {'Capacity (TPH)': _questionnaire.capacity},
              {'Feed to Screen (TPH)': _questionnaire.feedToScreen},
              {'Max Load (TPH)': _questionnaire.maxLoad},
              {'Max Piece Size': _questionnaire.maxPieceSize},
              {'Material Temp (°C)': _questionnaire.materialTemp},
              {'pH Level': _questionnaire.phLevel},
              {'Moisture (%)': _questionnaire.moisture},
              {'Bulk Density': _questionnaire.bulkDensity},
            ], tableHeaderStyle, tableHeaderDecoration, tableCellStyle),
            pw.SizedBox(height: 16),
            
            // 3. Particle Size Distribution (if exists)
            if (_particleSizeDistribution.isNotEmpty) ...[
              pw.Text('3. Particle Size Distribution', style: headerStyle),
              pw.SizedBox(height: 8),
              _buildInfoTable(
                _particleSizeDistribution.entries.map((e) => 
                  {e.key: '${e.value}%'}).toList(),
                tableHeaderStyle,
                tableHeaderDecoration,
                tableCellStyle,
              ),
              pw.SizedBox(height: 16),
            ],
            
            // 4. Screen Configuration
            pw.Text('4. Screen Configuration', style: headerStyle),
            pw.SizedBox(height: 8),
            _buildInfoTable([
              {'Number of Decks': _questionnaire.numberOfDecks.toString()},
              if (_numberOfDecks >= 1) {'Top Deck Aperture': _questionnaire.topDeckAperture},
              if (_numberOfDecks >= 1) {'Top Deck Material': _questionnaire.topDeckMaterial},
              if (_numberOfDecks >= 2) {'Middle Deck Aperture': _questionnaire.middleDeckAperture},
              if (_numberOfDecks >= 2) {'Middle Deck Material': _questionnaire.middleDeckMaterial},
              if (_numberOfDecks >= 3) {'Bottom Deck Aperture': _questionnaire.bottomDeckAperture},
              if (_numberOfDecks >= 3) {'Bottom Deck Material': _questionnaire.bottomDeckMaterial},
            ], tableHeaderStyle, tableHeaderDecoration, tableCellStyle),
            pw.SizedBox(height: 16),
            
            // 5. Installation Details
            pw.Text('5. Installation Details', style: headerStyle),
            pw.SizedBox(height: 8),
            _buildInfoTable([
              {'Max Height': _questionnaire.maxHeight},
              {'Max Width': _questionnaire.maxWidth},
              {'Max Length': _questionnaire.maxLength},
              {'Max Weight (kg)': _questionnaire.maxWeight},
            ], tableHeaderStyle, tableHeaderDecoration, tableCellStyle),
            pw.SizedBox(height: 16),
            
            // 6. Additional Options
            pw.Text('6. Additional Options', style: headerStyle),
            pw.SizedBox(height: 8),
            _buildInfoTable([
              {'Isolation Base': _questionnaire.isolationBase ? 'Yes' : 'No'},
              {'Dust Cover': _questionnaire.dustCover ? 'Yes' : 'No'},
              {'Spray Bars': _questionnaire.sprayBars ? 'Yes' : 'No'},
              {'Motor Supplied': _questionnaire.motorSupplied ? 'Yes' : 'No'},
              {'Liner Requirements': _questionnaire.linerRequirements},
            ], tableHeaderStyle, tableHeaderDecoration, tableCellStyle),
            
            // Footer
            pw.Spacer(),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated on ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  'Screen Selection App',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.blue800,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  // Add more pages if content is too long
  if (_particleSizeDistribution.length > 10 || 
      _questionnaire.linerRequirements.length > 200) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Additional Details', style: headerStyle),
              pw.SizedBox(height: 16),
              
              if (_particleSizeDistribution.length > 10)
                pw.Text('Particle Size Distribution (continued)', 
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              if (_particleSizeDistribution.length > 10)
                pw.SizedBox(height: 8),
              if (_particleSizeDistribution.length > 10)
                _buildInfoTable(
                  _particleSizeDistribution.entries.skip(10).map((e) => 
                    {e.key: '${e.value}%'}).toList(),
                  tableHeaderStyle,
                  tableHeaderDecoration,
                  tableCellStyle,
                ),
              
              if (_questionnaire.linerRequirements.length > 200) ...[
                pw.SizedBox(height: 16),
                pw.Text('Liner Requirements Details:', 
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(_questionnaire.linerRequirements),
              ],
            ],
          );
        },
      ),
    );
  }

  try {
    final output = await getExternalStorageDirectory();
    final filePath = '${output?.path}/questionnaire_${_questionnaire.id}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF saved to $filePath'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Open',
          onPressed: () => OpenFile.open(filePath),
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error generating PDF: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() => _isSaving = false);
  }
}

// Helper method to build consistent tables
pw.Widget _buildInfoTable(
  List<Map<String, String>> data,
  pw.TextStyle headerStyle,
  pw.BoxDecoration headerDecoration,
  pw.TextStyle cellStyle,
) {
  return pw.Table.fromTextArray(
    context: null,
    headerStyle: headerStyle,
    headerDecoration: headerDecoration,
    data: [
      ['Parameter', 'Value'],
      ...data.map((item) => [item.keys.first, item.values.first]),
    ],
    columnWidths: {
      0: const pw.FlexColumnWidth(2),
      1: const pw.FlexColumnWidth(3),
    },
    cellAlignment: pw.Alignment.centerLeft,
    cellStyle: cellStyle,
    cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  );
}
  void _addParticleSizeRow() {
    final sizeController = TextEditingController();
    final percentageController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Particle Size',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: sizeController,
                        decoration: const InputDecoration(
                          labelText: 'Size',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => 
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: percentageController,
                        decoration: const InputDecoration(
                          labelText: 'Percentage',
                          border: OutlineInputBorder(),
                          suffixText: '%',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => 
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (sizeController.text.isNotEmpty && 
                          percentageController.text.isNotEmpty) {
                        setState(() {
                          _particleSizeDistribution[sizeController.text] = 
                              percentageController.text;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add Particle Size'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.questionnaire == null 
              ? 'New Questionnaire' 
              : 'Edit Questionnaire',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPDF,
            tooltip: 'Export to PDF',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveQuestionnaire,
            tooltip: 'Save',
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader(
                      'Customer Information',
                      Icons.business,
                    ),
                    _buildTextFormField('Customer', 'customer', isRequired: true),
                    _buildTextFormField('Plant', 'plant'),
                    _buildTextFormField('Contact Person', 'contactPerson'),
                    
                    Row(
                      children: [
                        Expanded(child: _buildTextFormField('Name', 'name')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextFormField('Email', 'email')),
                      ],
                    ),
                    
                    _buildTextFormField('Phone', 'phone', keyboardType: TextInputType.phone),
                    
                    _buildSectionHeader(
                      'Technical Specifications', 
                      Icons.engineering,
                    ),
                    _buildTextFormField('Application', 'application'),
                    _buildTextFormField('Material', 'material'),
                    _buildTextFormField('New project or replacement screen', 'projectType'),
                    _buildTextFormField('Existing screen model and size', 'existingScreen'),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            'Capacity (TPH)', 
                            'capacity', 
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextFormField(
                            'Feed to screen (TPH)', 
                            'feedToScreen', 
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            'Maximum load (TPH)', 
                            'maxLoad', 
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextFormField(
                            'Size of largest pieces', 
                            'maxPieceSize',
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            'Material temperature (°C)', 
                            'materialTemp', 
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextFormField(
                            'pH level', 
                            'phLevel', 
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            'Moisture (%)', 
                            'moisture', 
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextFormField(
                            'Bulk density', 
                            'bulkDensity',
                          ),
                        ),
                      ],
                    ),
                    
                    _buildSectionHeader(
                      'Particle Size Distribution', 
                      Icons.auto_graph,
                    ),
                    if (_particleSizeDistribution.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No particle sizes added',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    
                    ..._particleSizeDistribution.entries.map((entry) => 
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text('${entry.key} - ${entry.value}%'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _particleSizeDistribution.remove(entry.key);
                              });
                            },
                          ),
                        ),
                      ),
                    ).toList(),
                    
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Particle Size'),
                      onPressed: _addParticleSizeRow,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    
                    _buildSectionHeader(
                      'Screen Configuration', 
                      Icons.grid_on,
                    ),
                    DropdownButtonFormField<int>(
                      value: _numberOfDecks,
                      items: [1, 2, 3].map((value) => 
                        DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value deck${value > 1 ? 's' : ''}'),
                        ),
                      ).toList(),
                      onChanged: (value) => setState(() => _numberOfDecks = value!),
                      decoration: const InputDecoration(
                        labelText: 'Number of decks',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    
                    if (_numberOfDecks >= 1) ...[
                      const SizedBox(height: 16),
                      _buildSubSectionHeader('Top Deck'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              'Aperture', 
                              'topDeckAperture',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextFormField(
                              'Material', 
                              'topDeckMaterial',
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    if (_numberOfDecks >= 2) ...[
                      const SizedBox(height: 16),
                      _buildSubSectionHeader('Middle Deck'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              'Aperture', 
                              'middleDeckAperture',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextFormField(
                              'Material', 
                              'middleDeckMaterial',
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    if (_numberOfDecks >= 3) ...[
                      const SizedBox(height: 16),
                      _buildSubSectionHeader('Bottom Deck'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              'Aperture', 
                              'bottomDeckAperture',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextFormField(
                              'Material', 
                              'bottomDeckMaterial',
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    _buildSectionHeader(
                      'Installation Details', 
                      Icons.settings_input_component,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            'Max height', 
                            'maxHeight', 
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextFormField(
                            'Max width', 
                            'maxWidth', 
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            'Max length', 
                            'maxLength', 
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextFormField(
                            'Max weight (kg)', 
                            'maxWeight', 
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    
                    _buildSectionHeader(
                      'Additional Options', 
                      Icons.tune,
                    ),
                    _buildOptionSwitch(
                      'Isolation base or H-base',
                      _isolationBase,
                      (value) => setState(() => _isolationBase = value),
                    ),
                    _buildOptionSwitch(
                      'Dust cover',
                      _dustCover,
                      (value) => setState(() => _dustCover = value),
                    ),
                    _buildOptionSwitch(
                      'Spray bars',
                      _sprayBars,
                      (value) => setState(() => _sprayBars = value),
                    ),
                    _buildOptionSwitch(
                      'Motor supplied by Conn-Weld',
                      _motorSupplied,
                      (value) => setState(() => _motorSupplied = value),
                    ),
                    
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Liner requirements',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _linerRequirements = value,
                      initialValue: _linerRequirements,
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveQuestionnaire,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : const Text(
                              'Save Questionnaire',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ].animate(interval: 50.ms).slideX(begin: 0.1),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, String controllerKey, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: _controllers[controllerKey],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: isRequired
          ? (value) => value?.isEmpty ?? true ? 'This field is required' : null
          : null,
    );
  }

  Widget _buildOptionSwitch(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => _isDarkMode = value);
    
    SystemChrome.setSystemUIOverlayStyle(
      value ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  Future<void> _exportAllData() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    setState(() => _isExporting = true);
    
    try {
      final questionnaires = await QuestionnaireStorage().getQuestionnaires();
      final output = await getExternalStorageDirectory();
      final zipPath = '${output?.path}/screen_selection_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.zip';
      
      final jsonData = jsonEncode(questionnaires.map((q) => q.toJson()).toList());
      final file = File(zipPath.replaceAll('.zip', '.json'));
      await file.writeAsString(jsonData);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported to ${file.path}'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => OpenFile.open(file.path),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import functionality would be implemented here')),
    );
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text('Are you sure you want to delete all questionnaires? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final file = await QuestionnaireStorage()._localFile;
      await file.delete();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data has been deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dark Mode',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      Switch(
                        value: _isDarkMode,
                        onChanged: _toggleDarkMode,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Export All Data'),
                  subtitle: const Text('Save all questionnaires as PDF and JSON'),
                  trailing: _isExporting
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.chevron_right),
                  onTap: _isExporting ? null : _exportAllData,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.import_export),
                  title: const Text('Import Data'),
                  subtitle: const Text('Restore from backup'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _importData,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete All Data'),
                  subtitle: const Text('Permanently remove all questionnaires'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _deleteAllData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  subtitle: const Text('App version and information'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Screen Selection',
                      applicationVersion: '1.0.0',
                      applicationIcon: SvgPicture.asset(
                        'assets/logo.png',
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      applicationLegalese: '© 2023 Screen Selection App\nAll rights reserved',
                    );
                  },
                ),
              ],
            ),
          ),
        ].animate(interval: 100.ms).fadeIn().slideX(),
      ),
    );
  }
}

class Questionnaire {
  final String id;
  final String customer;
  final String plant;
  final String contactPerson;
  final String name;
  final String email;
  final String phone;
  final String application;
  final String material;
  final String projectType;
  final String existingScreen;
  final String capacity;
  final String feedToScreen;
  final String maxLoad;
  final String maxPieceSize;
  final String materialTemp;
  final String phLevel;
  final String moisture;
  final String bulkDensity;
  final Map<String, String> particleSizeDistribution;
  final int numberOfDecks;
  final String topDeckAperture;
  final String middleDeckAperture;
  final String bottomDeckAperture;
  final String topDeckMaterial;
  final String middleDeckMaterial;
  final String bottomDeckMaterial;
  final String maxHeight;
  final String maxWidth;
  final String maxLength;
  final String maxWeight;
  final bool isolationBase;
  final bool dustCover;
  final bool sprayBars;
  final bool motorSupplied;
  final String linerRequirements;
  final DateTime createdAt;
  final DateTime updatedAt;

  Questionnaire({
    required this.id,
    this.customer = '',
    this.plant = '',
    this.contactPerson = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.application = '',
    this.material = '',
    this.projectType = '',
    this.existingScreen = '',
    this.capacity = '',
    this.feedToScreen = '',
    this.maxLoad = '',
    this.maxPieceSize = '',
    this.materialTemp = '',
    this.phLevel = '',
    this.moisture = '',
    this.bulkDensity = '',
    Map<String, String>? particleSizeDistribution,
    this.numberOfDecks = 1,
    this.topDeckAperture = '',
    this.middleDeckAperture = '',
    this.bottomDeckAperture = '',
    this.topDeckMaterial = '',
    this.middleDeckMaterial = '',
    this.bottomDeckMaterial = '',
    this.maxHeight = '',
    this.maxWidth = '',
    this.maxLength = '',
    this.maxWeight = '',
    this.isolationBase = false,
    this.dustCover = false,
    this.sprayBars = false,
    this.motorSupplied = false,
    this.linerRequirements = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : particleSizeDistribution = particleSizeDistribution ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Questionnaire copyWith({
    String? id,
    String? customer,
    String? plant,
    String? contactPerson,
    String? name,
    String? email,
    String? phone,
    String? application,
    String? material,
    String? projectType,
    String? existingScreen,
    String? capacity,
    String? feedToScreen,
    String? maxLoad,
    String? maxPieceSize,
    String? materialTemp,
    String? phLevel,
    String? moisture,
    String? bulkDensity,
    Map<String, String>? particleSizeDistribution,
    int? numberOfDecks,
    String? topDeckAperture,
    String? middleDeckAperture,
    String? bottomDeckAperture,
    String? topDeckMaterial,
    String? middleDeckMaterial,
    String? bottomDeckMaterial,
    String? maxHeight,
    String? maxWidth,
    String? maxLength,
    String? maxWeight,
    bool? isolationBase,
    bool? dustCover,
    bool? sprayBars,
    bool? motorSupplied,
    String? linerRequirements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Questionnaire(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      plant: plant ?? this.plant,
      contactPerson: contactPerson ?? this.contactPerson,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      application: application ?? this.application,
      material: material ?? this.material,
      projectType: projectType ?? this.projectType,
      existingScreen: existingScreen ?? this.existingScreen,
      capacity: capacity ?? this.capacity,
      feedToScreen: feedToScreen ?? this.feedToScreen,
      maxLoad: maxLoad ?? this.maxLoad,
      maxPieceSize: maxPieceSize ?? this.maxPieceSize,
      materialTemp: materialTemp ?? this.materialTemp,
      phLevel: phLevel ?? this.phLevel,
      moisture: moisture ?? this.moisture,
      bulkDensity: bulkDensity ?? this.bulkDensity,
      particleSizeDistribution: particleSizeDistribution ?? this.particleSizeDistribution,
      numberOfDecks: numberOfDecks ?? this.numberOfDecks,
      topDeckAperture: topDeckAperture ?? this.topDeckAperture,
      middleDeckAperture: middleDeckAperture ?? this.middleDeckAperture,
      bottomDeckAperture: bottomDeckAperture ?? this.bottomDeckAperture,
      topDeckMaterial: topDeckMaterial ?? this.topDeckMaterial,
      middleDeckMaterial: middleDeckMaterial ?? this.middleDeckMaterial,
      bottomDeckMaterial: bottomDeckMaterial ?? this.bottomDeckMaterial,
      maxHeight: maxHeight ?? this.maxHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      maxLength: maxLength ?? this.maxLength,
      maxWeight: maxWeight ?? this.maxWeight,
      isolationBase: isolationBase ?? this.isolationBase,
      dustCover: dustCover ?? this.dustCover,
      sprayBars: sprayBars ?? this.sprayBars,
      motorSupplied: motorSupplied ?? this.motorSupplied,
      linerRequirements: linerRequirements ?? this.linerRequirements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'plant': plant,
      'contactPerson': contactPerson,
      'name': name,
      'email': email,
      'phone': phone,
      'application': application,
      'material': material,
      'projectType': projectType,
      'existingScreen': existingScreen,
      'capacity': capacity,
      'feedToScreen': feedToScreen,
      'maxLoad': maxLoad,
      'maxPieceSize': maxPieceSize,
      'materialTemp': materialTemp,
      'phLevel': phLevel,
      'moisture': moisture,
      'bulkDensity': bulkDensity,
      'particleSizeDistribution': particleSizeDistribution,
      'numberOfDecks': numberOfDecks,
      'topDeckAperture': topDeckAperture,
      'middleDeckAperture': middleDeckAperture,
      'bottomDeckAperture': bottomDeckAperture,
      'topDeckMaterial': topDeckMaterial,
      'middleDeckMaterial': middleDeckMaterial,
      'bottomDeckMaterial': bottomDeckMaterial,
      'maxHeight': maxHeight,
      'maxWidth': maxWidth,
      'maxLength': maxLength,
      'maxWeight': maxWeight,
      'isolationBase': isolationBase,
      'dustCover': dustCover,
      'sprayBars': sprayBars,
      'motorSupplied': motorSupplied,
      'linerRequirements': linerRequirements,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    return Questionnaire(
      id: json['id'],
      customer: json['customer'],
      plant: json['plant'],
      contactPerson: json['contactPerson'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      application: json['application'],
      material: json['material'],
      projectType: json['projectType'],
      existingScreen: json['existingScreen'],
      capacity: json['capacity'],
      feedToScreen: json['feedToScreen'],
      maxLoad: json['maxLoad'],
      maxPieceSize: json['maxPieceSize'],
      materialTemp: json['materialTemp'],
      phLevel: json['phLevel'],
      moisture: json['moisture'],
      bulkDensity: json['bulkDensity'],
      particleSizeDistribution: Map<String, String>.from(json['particleSizeDistribution'] ?? {}),
      numberOfDecks: json['numberOfDecks'] ?? 1,
      topDeckAperture: json['topDeckAperture'],
      middleDeckAperture: json['middleDeckAperture'],
      bottomDeckAperture: json['bottomDeckAperture'],
      topDeckMaterial: json['topDeckMaterial'],
      middleDeckMaterial: json['middleDeckMaterial'],
      bottomDeckMaterial: json['bottomDeckMaterial'],
      maxHeight: json['maxHeight'],
      maxWidth: json['maxWidth'],
      maxLength: json['maxLength'],
      maxWeight: json['maxWeight'],
      isolationBase: json['isolationBase'] ?? false,
      dustCover: json['dustCover'] ?? false,
      sprayBars: json['sprayBars'] ?? false,
      motorSupplied: json['motorSupplied'] ?? false,
      linerRequirements: json['linerRequirements'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class QuestionnaireStorage {
  static final QuestionnaireStorage _instance = QuestionnaireStorage._internal();
  factory QuestionnaireStorage() => _instance;
  QuestionnaireStorage._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/questionnaires.json');
  }

  Future<void> saveQuestionnaire(Questionnaire questionnaire) async {
    try {
      final file = await _localFile;
      final questionnaires = await getQuestionnaires();
      final index = questionnaires.indexWhere((q) => q.id == questionnaire.id);
      
      if (index >= 0) {
        questionnaires[index] = questionnaire;
      } else {
        questionnaires.add(questionnaire);
      }
      
      final jsonString = jsonEncode(questionnaires.map((q) => q.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving questionnaire: $e');
      }
      rethrow;
    }
  }

  Future<List<Questionnaire>> getQuestionnaires() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];
      
      final contents = await file.readAsString();
      if (contents.isEmpty) return [];
      
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => Questionnaire.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading questionnaires: $e');
      }
      return [];
    }
  }

  Future<void> deleteQuestionnaire(String id) async {
    try {
      final questionnaires = await getQuestionnaires();
      questionnaires.removeWhere((q) => q.id == id);
      
      final file = await _localFile;
      final jsonString = jsonEncode(questionnaires.map((q) => q.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting questionnaire: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteAllQuestionnaires() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting all questionnaires: $e');
      }
      rethrow;
    }
  }
}
