// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'sections/about_section.dart';
import 'sections/contact_section.dart';
import 'sections/experience_section.dart';
import 'sections/home_section.dart';
import 'sections/projects_section.dart';
import 'utils/responsive_utils.dart';
import 'widgets/custom_navbar.dart';
import 'widgets/floatingactionbutton.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // use your own api and other details here
        apiKey: "AIzaSyBwPClgdsJuW9tR3mqtFvWzeigiT_aznwU",
        authDomain: "daksh-portfolio-2025.firebaseapp.com",
        projectId: "daksh-portfolio-2025",
        storageBucket: "daksh-portfolio-2025.firebasestorage.app",
        messagingSenderId: "679850385630",
        appId: "1:679850385630:web:60e07a179cdaff1adc224f",
      ),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daksh Suthar Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const PortfolioPage(),
    );
  }
}

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with TickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Keys
  // ---------------------------------------------------------------------------

  final GlobalKey homeKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey projectsKey = GlobalKey();
  final GlobalKey experienceKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  // ---------------------------------------------------------------------------
  // Controllers
  // ---------------------------------------------------------------------------

  late final ScrollController _scrollController;
  late final AnimationController _navbarController;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isScrolled = false;
  bool _isScrolling = false;

  int _currentSection = 0;

  final Map<int, double> _visibleSections = {};

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _navbarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _navbarController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Scroll & section handling
  // ---------------------------------------------------------------------------

  void _onScroll() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset > 100 && !_isScrolled) {
        setState(() => _isScrolled = true);
        _navbarController.forward();
      } else if (_scrollController.offset <= 100 && _isScrolled) {
        setState(() => _isScrolled = false);
        _navbarController.reverse();
      }
    }
  }

  void _updateSectionIndex(int index, VisibilityInfo info) {
    final visiblePixels = info.visibleFraction * info.size.height;
    _visibleSections[index] = visiblePixels;

    if (_isScrolling) return;

    if (_scrollController.hasClients) {
      final pos = _scrollController.position;

      if (pos.pixels >= pos.maxScrollExtent - 50) {
        if (_currentSection != 4) {
          setState(() => _currentSection = 4);
        }
        return;
      }
    }

    int bestSection = _currentSection;
    double maxPixels = 0.0;

    _visibleSections.forEach((idx, pixels) {
      if (pixels > maxPixels) {
        maxPixels = pixels;
        bestSection = idx;
      }
    });

    if (maxPixels > 50 && bestSection != _currentSection) {
      setState(() => _currentSection = bestSection);
    }
  }

  void scrollToSection(GlobalKey key) {
    final context = key.currentContext;

    if (context != null) {
      setState(() {
        _isScrolling = true;

        if (key == homeKey)
          _currentSection = 0;
        else if (key == aboutKey)
          _currentSection = 1;
        else if (key == projectsKey)
          _currentSection = 2;
        else if (key == experienceKey)
          _currentSection = 3;
        else if (key == contactKey) _currentSection = 4;

        _visibleSections.clear();
        _visibleSections[_currentSection] = 1000;
      });

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => _isScrolling = false);
          }
        });
      });
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          ResponsiveUtils.isMobile(context) ? 70 : 80,
        ),
        child: AnimatedBuilder(
          animation: _navbarController,
          builder: (context, child) => CustomNavbar(
            homeKey: homeKey,
            aboutKey: aboutKey,
            projectsKey: projectsKey,
            experienceKey: experienceKey,
            contactKey: contactKey,
            onSectionTap: scrollToSection,
            isScrolled: _isScrolled,
            currentSection: _currentSection,
            animation: _navbarController,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            VisibilityDetector(
              key: const Key('home_section'),
              onVisibilityChanged: (info) => _updateSectionIndex(0, info),
              child: HomeSection(
                key: homeKey,
                onHireMeTap: () => scrollToSection(contactKey),
              ),
            ),
            VisibilityDetector(
              key: const Key('about_section'),
              onVisibilityChanged: (info) => _updateSectionIndex(1, info),
              child: AboutSection(
                key: aboutKey,
                isVisible: _currentSection == 1,
              ),
            ),
            VisibilityDetector(
              key: const Key('projects_section'),
              onVisibilityChanged: (info) => _updateSectionIndex(2, info),
              child: ProjectsSection(key: projectsKey),
            ),
            VisibilityDetector(
              key: const Key('experience_section'),
              onVisibilityChanged: (info) => _updateSectionIndex(3, info),
              child: ExperienceSection(key: experienceKey),
            ),
            VisibilityDetector(
              key: const Key('contact_section'),
              onVisibilityChanged: (info) => _updateSectionIndex(4, info),
              child: ContactSection(key: contactKey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionMenu(
        scrollController: _scrollController,
        onScrollToTop: () => scrollToSection(homeKey),
      ),
    );
  }
}
