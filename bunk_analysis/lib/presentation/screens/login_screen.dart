import 'package:flutter/material.dart';
import '../../core/security/credential_vault.dart';
import '../../data/providers/portal_scrapper.dart';
import 'dashboard_screen.dart';
import '../../data/repositories/attendance_data.dart';
import '../../utils/analytics.dart';
import '../../core/constants/app_colors.dart';
import 'terms_and_conditions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regnoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _regnoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final regno = _regnoController.text.trim();
    final password = _passwordController.text;
    final api = PortalApi();
    bool success = false;
    try {
      success = await api.login(regno: regno, password: password);
    } catch (e) {
      success = false;
    }

    setState(() => _isLoading = false);

    if (success) {
      await AnalyticsService.logLogin();
      await CredentialVault.saveCredentials(regno: regno, password: password);
      final profile = await api.profile();
      final attendance = await api.fetchAttendance();
      await LocalCache.saveProfile(profile.data);
      await LocalCache.saveAttendance(attendance.data);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage(title: 'NSync')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid registration number or password'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Scaffold(
      backgroundColor: c.pageBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo + title ──────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.accentGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(
                          color: c.accentGreen.withOpacity(0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    //   child: Icon(
                    //     Icons.school_rounded,
                    //     size: 22,
                    //     color: c.accentGreen,
                    //   ),
                    // ),
                    const SizedBox(width: 12),
                    Text(
                      'NSync',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Use your student portal credentials',
                  style: TextStyle(fontSize: 13, color: c.textMuted),
                ),

                const SizedBox(height: 32),

                // ── Form card ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: c.surfaceBg,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(color: c.surfaceBorder),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Regno field
                        _FieldLabel(label: 'Registration Number', c: c),
                        const SizedBox(height: 6),
                        _InputField(
                          controller: _regnoController,
                          hint: 'e.g. 9901XXXXXX',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          c: c,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter registration number'
                              : null,
                        ),

                        const SizedBox(height: 16),

                        // Password field
                        _FieldLabel(label: 'Password', c: c),
                        const SizedBox(height: 6),

                        _InputField(
                          controller: _passwordController,
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          c: c,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter password'
                              : null,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: c.textMuted,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ── Terms checkbox ─────────────────────────────────────────
                        GestureDetector(
                          onTap: () =>
                              setState(() => _agreedToTerms = !_agreedToTerms),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _agreedToTerms
                                      ? c.accentGreen
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: _agreedToTerms
                                        ? c.accentGreen
                                        : c.surfaceBorder,
                                    width: 1.5,
                                  ),
                                ),
                                child: _agreedToTerms
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: c.pageBg,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () {}, // don't toggle checkbox when tapping text
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: c.textMuted,
                                      ),
                                      children: [
                                        const TextSpan(text: 'I agree to the '),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const TermsAndConditionsPage(),
                                              ),
                                            ),
                                            child: Text(
                                              'Terms & Conditions',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: c.accentGreen,
                                                fontWeight: FontWeight.w600,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: c.accentGreen,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: c.accentGreen,
                                  strokeWidth: 2,
                                ),
                              )
                            : GestureDetector(
                                onTap: _agreedToTerms
                                    ? _submit
                                    : null, // ← disabled if not agreed
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _agreedToTerms
                                        ? c.accentGreen
                                        : c.accentGreen.withOpacity(
                                            0.3,
                                          ), // ← faded when disabled
                                    borderRadius: BorderRadius.circular(
                                      AppDimens.radiusMd,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _agreedToTerms
                                            ? c.pageBg
                                            : c.pageBg.withOpacity(
                                                0.4,
                                              ), // ← faded text too
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        // Submit button
                        // _isLoading
                        //     ? Center(
                        //         child: CircularProgressIndicator(
                        //           color: c.accentGreen,
                        //           strokeWidth: 2,
                        //         ),
                        //       )
                        //     : GestureDetector(
                        //         onTap: _submit,
                        //         child: Container(
                        //           height: 48,
                        //           decoration: BoxDecoration(
                        //             color: c.accentGreen,
                        //             borderRadius: BorderRadius.circular(
                        //               AppDimens.radiusMd,
                        //             ),
                        //           ),
                        //           child: Center(
                        //             child: Text(
                        //               'Sign In',
                        //               style: TextStyle(
                        //                 fontSize: 15,
                        //                 fontWeight: FontWeight.w700,
                        //                 color: c.pageBg,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Disclaimer ────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: c.textSubtle,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Your credentials are stored securely on this device only and are never sent to any third-party server.',
                        style: TextStyle(fontSize: 11, color: c.textSubtle),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final AppColorSchemeExt c;

  const _FieldLabel({required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: c.textMuted,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ─── Input field ──────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?) validator;
  final Widget? suffix;
  final AppColorSchemeExt c;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.c,
    required this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: TextStyle(fontSize: 14, color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textSubtle, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: c.textMuted),
        suffixIcon: suffix,
        filled: true,
        fillColor: c.pageBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          borderSide: BorderSide(color: c.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          borderSide: BorderSide(color: c.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          borderSide: BorderSide(color: c.accentGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          borderSide: BorderSide(color: c.accentRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          borderSide: BorderSide(color: c.accentRed, width: 1.5),
        ),
      ),
    );
  }
}
