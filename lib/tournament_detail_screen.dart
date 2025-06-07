import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class TournamentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> tournamentData;

  const TournamentDetailsScreen({super.key, required this.tournamentData});

  @override
  State<TournamentDetailsScreen> createState() => _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _inGameNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  bool _isLoading = false;
  bool _isRegistered = false;
  bool _isCheckingRegistration = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkIfUserRegistered();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _inGameNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _checkIfUserRegistered([String? phoneNumber]) async {
    setState(() => _isCheckingRegistration = true);

    try {
      final gameName = widget.tournamentData['gameName'] ?? 'unknown';
      final collection = gameName.replaceAll(' ', '_').toLowerCase();

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection(collection)
            .where('phoneNumber', isEqualTo: phoneNumber)
            .get();

        setState(() {
          _isRegistered = querySnapshot.docs.isNotEmpty;
          _isCheckingRegistration = false;
        });
        return;
      }

      setState(() {
        _isRegistered = false;
        _isCheckingRegistration = false;
      });
    } catch (e) {
      setState(() => _isCheckingRegistration = false);
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    await _checkIfUserRegistered(_phoneNumberController.text);
    if (_isRegistered) {
      _showDialog('Already Registered', 'You have already registered for this tournament.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final gameName = widget.tournamentData['gameName'] ?? 'unknown';
      final existingUser = await FirebaseFirestore.instance
          .collection(gameName)
          .where('phoneNumber', isEqualTo: _phoneNumberController.text.trim())
          .get();

      if (existingUser.docs.isNotEmpty) {
        _showDialog('Already Registered', 'You have already registered for this tournament.', Colors.orange);
        setState(() {
          _isLoading = false;
          _isRegistered = true;
        });
        return;
      }

      await FirebaseFirestore.instance.collection(gameName).add({
        'name': _nameController.text.trim(),
        'inGameName': _inGameNameController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
        'registeredAt': FieldValue.serverTimestamp(),
        'tournamentId': widget.tournamentData['id'] ?? '',
        'gameName': gameName,
      });

      setState(() {
        _isRegistered = true;
        _isLoading = false;
      });

      _showSuccessDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    _showDialog(
      'Registration Successful!',
      'Welcome to ${widget.tournamentData['gameName']}!',
      Colors.green,
      showDiscordButton: true,
    );
  }

  void _showDialog(String title, String message, Color color, {bool showDiscordButton = false}) {
    showDialog(
      context: context,
      barrierDismissible: !showDiscordButton,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), Colors.white],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                child: Icon(
                  showDiscordButton ? Icons.check : Icons.info,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              if (showDiscordButton) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: const Text(
                    'Join the Discord server (Compulsory for participation)',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.purple),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              showDiscordButton
                  ? Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Later'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final discordLink = widget.tournamentData['link'] ?? '';
                        if (discordLink.isNotEmpty) {
                          final Uri url = Uri.parse(discordLink);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        }
                        Navigator.of(context).pop();
                      },
                      icon: const FaIcon(FontAwesomeIcons.discord, size: 18),
                      label: const Text('Join Discord'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5865F2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              )
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Column(
                children: [
                  _buildBackButton(),
                  const SizedBox(height: 24),
                  isMobile
                      ? Column(
                    children: [
                      _buildTournamentDetails(isMobile),
                      const SizedBox(height: 32),
                      _buildRegistrationForm(isMobile),
                    ],
                  )
                      : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildTournamentDetails(isMobile)),
                      const SizedBox(width: 32),
                      Expanded(flex: 2, child: _buildRegistrationForm(isMobile)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildTournamentDetails(bool isMobile) {
    return Column(
      children: [
        _buildTournamentHeader(isMobile),
        const SizedBox(height: 24),
        _buildPrizeEntryInfo(isMobile),
        const SizedBox(height: 24),
        _buildDescriptionSection(),
        if (widget.tournamentData['rules'] != null) ...[
          const SizedBox(height: 24),
          _buildRulesSection(),
        ],
      ],
    );
  }

  Widget _buildTournamentHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.purple.shade50.withOpacity(0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade100.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              'TOURNAMENT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                const Color(0xFF667EEA),
                const Color(0xFF764BA2),
              ],
            ).createShader(bounds),
            child: Text(
              widget.tournamentData['gameName'] ?? 'Tournament',
              style: TextStyle(
                fontSize: isMobile ? 32 : 40,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.tournamentData['shortDescription'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeEntryInfo(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: FontAwesomeIcons.trophy,
            title: 'Prize Pool',
            value: '₹${widget.tournamentData['prizeMoney'] ?? '0'}',
            colors: [const Color(0xFFFFB75E), const Color(0xFFED8F03)],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            icon: FontAwesomeIcons.ticket,
            title: 'Entry Fee',
            value: '₹${widget.tournamentData['entryFee'] ?? '0'}',
            colors: [const Color(0xFF56C596), const Color(0xFF38A169)],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required List<Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return _buildSection(
      icon: Icons.description_outlined,
      title: 'Description',
      content: Text(
        widget.tournamentData['longDescription'] ?? 'No description available',
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildRulesSection() {
    return _buildSection(
      icon: Icons.rule_outlined,
      title: 'Rules',
      content: Column(
        children: (widget.tournamentData['rules'] as List<dynamic>?)
            ?.asMap()
            .entries
            .map((entry) => _buildRuleItem(entry.key + 1, entry.value.toString()))
            .toList() ??
            [
              Text(
                'No rules specified',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildRuleItem(int index, String rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(width: 4, color: const Color(0xFF667EEA)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.how_to_reg, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Tournament Registration',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildFormField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) => value?.trim().isEmpty ?? true ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 20),
            _buildFormField(
              controller: _inGameNameController,
              label: 'In-Game Name',
              icon: Icons.sports_esports_outlined,
              validator: (value) => value?.trim().isEmpty ?? true ? 'Please enter your in-game name' : null,
            ),
            const SizedBox(height: 20),
            _buildFormField(
              controller: _phoneNumberController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) return 'Please enter your phone number';
                if (value!.trim().length < 10) return 'Please enter a valid phone number';
                return null;
              },
              onChanged: (value) {
                if (value.trim().length >= 10) {
                  _checkIfUserRegistered(value.trim());
                } else {
                  setState(() => _isRegistered = false);
                }
              },
            ),
            const SizedBox(height: 32),
            _buildRegisterButton(),
            if (_isRegistered) _buildRegisteredIndicator(),
            const SizedBox(height: 24),
            _buildInfoBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFF667EEA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildRegisterButton() {
    final bool isDisabled = _isRegistered || _isLoading || _isCheckingRegistration;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isDisabled ? null : _registerUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDisabled
                ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400])
                : LinearGradient(
              colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: _isLoading || _isCheckingRegistration
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isRegistered ? Icons.check : Icons.app_registration,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isRegistered ? 'Already Registered' : 'Register Now',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisteredIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You are already registered for this tournament!',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'After registration, join our Discord server for updates and participation.',
              style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}