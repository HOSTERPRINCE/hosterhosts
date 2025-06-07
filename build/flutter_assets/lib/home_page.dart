import 'package:flutter/material.dart';
import 'package:hosterhosts/auth_service.dart';
import 'package:hosterhosts/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosterhosts/tournament_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _headerAnimationController;
  late AnimationController _socialAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _socialAnimation;

  // Add loading state to prevent flash
  bool _isInitialized = false;
  bool _animationsStarted = false;

  final String instagramUrl = "https://www.instagram.com/hosteresports/?__pwa=1";
  final String discordUrl = "https://discord.gg/TzC3trqq";
  final String youtubeUrl = "https://www.youtube.com/@hosterprince5076";

  final Map<String, String> gameImages = {
    'PUBG': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop',
    'Free Fire': 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=400&h=300&fit=crop',
    'Call of Duty': 'https://images.unsplash.com/photo-1552820728-8b83bb6b773f?w=400&h=300&fit=crop',
    'Fortnite': 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400&h=300&fit=crop',
    'Valorant': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop',
    'CS:GO': 'https://images.unsplash.com/photo-1552820728-8b83bb6b773f?w=400&h=300&fit=crop',
    'default': 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=400&h=300&fit=crop',
  };



  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Initialize animation controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Reduced duration
      vsync: this,
    );
    _socialAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400), // Reduced duration
      vsync: this,
    );

    // Create animations with proper curves - start from 0.8 instead of 0.0 to reduce flash
    _headerAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _socialAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _socialAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Set initial state to prevent flash
    setState(() {
      _isInitialized = true;
    });

    // Start animations immediately after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_animationsStarted) {
        _animationsStarted = true;
        _startAnimations();
      }
    });
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 100), () { // Reduced delay
      if (mounted) {
        _socialAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _socialAnimationController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  Future<int> _getParticipantCount(String gameName) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(gameName).get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Improved responsive design helpers
  bool get isMobile => MediaQuery.of(context).size.width < 768;
  bool get isTablet => MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1024;

  int get gridCrossAxisCount {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return 1; // Mobile: 1 column (use ListView)
    if (width < 1024) return 2; // Tablet: 2 columns
    if (width < 1400) return 3; // Small desktop: 3 columns
    if (width < 1800) return 4; // Medium desktop: 4 columns
    return 5; // Large desktop: 5 columns max
  }

  double get cardAspectRatio {
    if (isMobile) return 1.2;
    if (isTablet) return 0.9;
    return 0.85;
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    // Always show the widget, just animate it
    return AnimatedBuilder(
      animation: _socialAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _socialAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - _socialAnimation.value)), // Reduced offset
            child: Opacity(
              opacity: _socialAnimation.value.clamp(0.5, 1.0), // Prevent full transparency
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
                  padding: EdgeInsets.all(isMobile ? 10 : 14),
                  constraints: BoxConstraints(
                    minHeight: isMobile ? 80 : 90,
                    maxWidth: isMobile ? 120 : 150,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 8 : 10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          icon,
                          color: color,
                          size: isMobile ? 16 : 18,
                        ),
                      ),
                      SizedBox(height: isMobile ? 4 : 6),
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (subtitle.isNotEmpty && !isMobile) ...[
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchCard(DocumentSnapshot document, int index) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    String gameName = data['gameName'] ?? 'Unknown Game';
    String imageUrl = gameImages[gameName] ?? gameImages['default']!;

    return Container(
      // ... existing container properties ...
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to tournament details when card is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TournamentDetailsScreen(
                  tournamentData: data,
                ),
              ),
            );
          },
          child: isMobile
              ? _buildMobileLayout(data, gameName, imageUrl)
              : _buildDesktopLayout(data, gameName, imageUrl),
        ),
      ),
    );
  }

  // Method to get registered users count for a specific game
  Future<int> _getRegisteredUsersCount(String gameName) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(gameName)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching registered users count: $e');
      return 0;
    }
  }

  Widget _buildMobileLayout(Map<String, dynamic> data, String gameName, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Game Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.sports_esports, color: Colors.grey, size: 24),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.deepPurple],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gameName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  data['shortDescription'] ?? 'No description',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Stats with Registered Users Count
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    _buildMiniStatChip(
                      icon: Icons.attach_money,
                      label: '₹${data['entryFee'] ?? '0'}',
                      color: Colors.green,
                    ),
                    _buildMiniStatChip(
                      icon: Icons.emoji_events,
                      label: '₹${data['prizeMoney'] ?? '0'}',
                      color: Colors.amber,
                    ),
                    // Registered Users Count
                    FutureBuilder<int>(
                      future: _getRegisteredUsersCount(gameName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildMiniStatChip(
                            icon: Icons.people,
                            label: '...',
                            color: Colors.blue,
                          );
                        }
                        return _buildMiniStatChip(
                          icon: Icons.people,
                          label: '${snapshot.data ?? 0}',
                          color: Colors.blue,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Register Button
          Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TournamentDetailsScreen(
                        tournamentData: data,
                      ),
                    ),
                  );
                },
                child: const Center(
                  child: Text(
                    'Join',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Map<String, dynamic> data, String gameName, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.sports_esports, color: Colors.grey, size: 48),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Content
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.deepPurple],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    gameName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Expanded(
                  child: Text(
                    data['shortDescription'] ?? 'No description',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),

                // Stats with Registered Users Count
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildStatChip(
                      icon: Icons.attach_money,
                      label: '₹${data['entryFee'] ?? '0'}',
                      color: Colors.green,
                    ),
                    _buildStatChip(
                      icon: Icons.emoji_events,
                      label: '₹${data['prizeMoney'] ?? '0'}',
                      color: Colors.amber,
                    ),
                    _buildStatChip(
                      icon: Icons.people,
                      label: '${data['limit'] ?? 'Unlimited'}',
                      color: Colors.blue,
                    ),
                    // Registered Users Count
                    FutureBuilder<int>(
                      future: _getRegisteredUsersCount(gameName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildStatChip(
                            icon: Icons.group,
                            label: 'Loading...',
                            color: Colors.orange,
                          );
                        }
                        return _buildStatChip(
                          icon: Icons.group,
                          label: 'Registered: ${snapshot.data ?? 0}',
                          color: Colors.orange,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TournamentDetailsScreen(
                            tournamentData: data,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Register Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      decoration: const BoxDecoration(
      gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFF8F9FF),
        Color(0xFFE8E9FF),
      ],
    ),
    ),
    child: SafeArea(
    child: Column(
    children: [
    // Custom Header - Always visible with consistent height
    AnimatedBuilder(
    animation: _isInitialized ? _headerAnimation : AlwaysStoppedAnimation(0.8),
    builder: (context, child) {
    return Transform.translate(
    offset: Offset(0, -20 * (1 - _headerAnimation.value)), // Reduced offset
    child: Opacity(
    opacity: _headerAnimation.value.clamp(0.8, 1.0), // Prevent full transparency
    child: Container(
    height: isMobile ? 88 : 104, // Fixed height to prevent layout shift
    padding: EdgeInsets.all(isMobile ? 16 : 20),
    child: Row(
    children: [
    Container(
    padding: EdgeInsets.all(isMobile ? 10 : 12),
    decoration: BoxDecoration(
    gradient: const LinearGradient(
    colors: [Colors.purple, Colors.deepPurple],
    ),
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
    BoxShadow(
    color: Colors.purple.withOpacity(0.3),
    blurRadius: 6,
    offset: const Offset(0, 3),
    ),
    ],
    ),
    child: Icon(
    Icons.sports_esports,
    color: Colors.white,
    size: isMobile ? 20 : 24,
    ),
    ),
    SizedBox(width: isMobile ? 12 : 16),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    'HosterHosts',
    style: TextStyle(
    fontSize: isMobile ? 20 : 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    ),
    Text(
    'Gaming Tournaments',
    style: TextStyle(
    fontSize: isMobile ? 12 : 14,
    color: Colors.grey[600],
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    ),
    ],
    ),
    ),
    Container(
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 6,
    offset: const Offset(0, 2),
    ),
    ],
    ),
    child: IconButton(
    onPressed: () {
    auth.signOut();
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => Login()),
    );
    },
    icon: Icon(
    Icons.logout,
    color: Colors.red,
    size: isMobile ? 20 : 24,
    ),
    tooltip: 'Log Out',
    ),
    ),
    ],
    ),
    ),
    ),
    );
    },
    ),

    // Social Media Section
    Container(
    margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20),
    child: Row(
    children: [
    Expanded(
    child: _buildSocialButton(
    icon: FontAwesomeIcons.instagram,
    title: 'Message',
    subtitle: 'Get Help',
    color: const Color(0xFFE4405F),
    onTap: () => _launchURL(instagramUrl),
    index: 0,
    ),
    ),
    Expanded(
    child: _buildSocialButton(
    icon: FontAwesomeIcons.discord,
    title: 'Discord',
    subtitle: 'Join Community',
    color: const Color(0xFF5865F2),
    onTap: () => _launchURL(discordUrl),
    index: 1,
    ),
    ),
    Expanded(
    child: _buildSocialButton(
    icon: FontAwesomeIcons.youtube,
    title: 'Subscribe',
    subtitle: 'Latest Updates',
    color: const Color(0xFFFF0000),
    onTap: () => _launchURL(youtubeUrl),
    index: 2,
    ),
    ),
    ],
    ),
    ),

    SizedBox(height: isMobile ? 16 : 20),

    // Matches Section
    Expanded(
    child: StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('matches').snapshots(),
    builder: (context, snapshot) {
    if (snapshot.hasError) {
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.error_outline,
    size: isMobile ? 48 : 64,
    color: Colors.red[300],
    ),
    SizedBox(height: isMobile ? 12 : 16),
    Text(
    'Something went wrong',
    style: TextStyle(
    fontSize: isMobile ? 16 : 18,
    color: Colors.grey,
    ),
    ),
    ],
    ),
    );
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(
    child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
    ),
    );
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.sports_esports_outlined,
    size: isMobile ? 48 : 64,
    color: Colors.grey[400],
    ),
    SizedBox(height: isMobile ? 12 : 16),
    Text(
    'No matches available',
    style: TextStyle(
    fontSize: isMobile ? 16 : 18,
    color: Colors.grey,
    ),
    ),
    SizedBox(height: isMobile ? 6 : 8),
    Text(
    'Check back later for new tournaments',
    style: TextStyle(
    fontSize: isMobile ? 12 : 14,
    color: Colors.grey[600],
    ),
    ),
    ],
    ),
    );
    }

    // Use ListView for mobile, GridView for larger screens
    if (isMobile) {
    return ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: 8),
    itemCount: snapshot.data!.docs.length,
    itemBuilder: (context, index) {
    return _buildMatchCard(snapshot.data!.docs[index], index);
    },);
    } else {
      // GridView for tablet and desktop
      return GridView.builder(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCrossAxisCount,
          childAspectRatio: cardAspectRatio,
          crossAxisSpacing: isMobile ? 8 : 12,
          mainAxisSpacing: isMobile ? 8 : 12,
        ),
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          return _buildMatchCard(snapshot.data!.docs[index], index);
        },
      );
    }
    },
    ),
    ),
    ],
    ),
    ),
      ),
    );
  }
}