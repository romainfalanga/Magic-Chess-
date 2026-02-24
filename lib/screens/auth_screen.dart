// ============================================================
// ÉCRANS AUTH - Inscription / Connexion
// ============================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/fantasy_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Connexion
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  // Inscription
  final _regUsernameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regPass2Ctrl = TextEditingController();

  bool _obscurePass = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regPass2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FantasyTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              _buildLogo(),
              const SizedBox(height: 32),
              // Tabs
              _buildTabs(),
              const SizedBox(height: 24),
              // Formulaires
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(),
                    _buildRegisterForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: FantasyTheme.purpleGradient,
            boxShadow: FantasyTheme.glowShadow(FantasyTheme.purple),
          ),
          child: const Center(
            child: Text('♟', style: TextStyle(fontSize: 38)),
          ),
        ),
        const SizedBox(height: 12),
        Text('MAGIC CHESS', style: FantasyTheme.titleStyle),
        Text(
          'Connecte-toi pour jouer en ligne',
          style: FantasyTheme.labelStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: FantasyTheme.bgMedium,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: FantasyTheme.purple.withValues(alpha: 0.3)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: FantasyTheme.purpleGradient,
          boxShadow: FantasyTheme.glowShadow(FantasyTheme.purple, intensity: 0.3),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: FantasyTheme.white,
        unselectedLabelColor: FantasyTheme.silver,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(text: 'Connexion'),
          Tab(text: 'Inscription'),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        if (_errorMessage != null) _buildError(_errorMessage!),
        _buildField(
          controller: _loginEmailCtrl,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _buildField(
          controller: _loginPassCtrl,
          label: 'Mot de passe',
          icon: Icons.lock_outline,
          obscure: _obscurePass,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePass ? Icons.visibility_off : Icons.visibility,
              color: FantasyTheme.silver,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
        ),
        const SizedBox(height: 24),
        _buildButton('Se connecter', _handleLogin),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        if (_errorMessage != null) _buildError(_errorMessage!),
        _buildField(
          controller: _regUsernameCtrl,
          label: 'Pseudo (visible par les autres)',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 10),
        _buildField(
          controller: _regEmailCtrl,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        _buildField(
          controller: _regPassCtrl,
          label: 'Mot de passe',
          icon: Icons.lock_outline,
          obscure: true,
        ),
        const SizedBox(height: 10),
        _buildField(
          controller: _regPass2Ctrl,
          label: 'Confirmer le mot de passe',
          icon: Icons.lock_outline,
          obscure: true,
        ),
        const SizedBox(height: 20),
        _buildButton("Créer mon compte", _handleRegister),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: FantasyTheme.bgMedium,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: FantasyTheme.purple.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: TextStyle(color: FantasyTheme.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: FantasyTheme.silver.withValues(alpha: 0.7), fontSize: 13),
          prefixIcon: Icon(icon, color: FantasyTheme.purple, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: _isLoading
              ? null
              : FantasyTheme.purpleGradient,
          color: _isLoading ? FantasyTheme.bgMedium : null,
          boxShadow: _isLoading
              ? null
              : FantasyTheme.glowShadow(FantasyTheme.purple, intensity: 0.4),
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: FantasyTheme.purple,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: FantasyTheme.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: FantasyTheme.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FantasyTheme.red.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: FantasyTheme.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg,
                style: TextStyle(color: FantasyTheme.red, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final error = await AuthService.signIn(
      email: _loginEmailCtrl.text.trim(),
      password: _loginPassCtrl.text,
    );
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_regPassCtrl.text != _regPass2Ctrl.text) {
      setState(() => _errorMessage = 'Les mots de passe ne correspondent pas');
      return;
    }
    if (_regUsernameCtrl.text.trim().length < 3) {
      setState(() => _errorMessage = 'Pseudo trop court (3 caractères min)');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final error = await AuthService.signUp(
      email: _regEmailCtrl.text.trim(),
      password: _regPassCtrl.text,
      username: _regUsernameCtrl.text.trim(),
    );
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }
}
