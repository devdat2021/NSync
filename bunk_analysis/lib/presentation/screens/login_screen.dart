// import 'package:bunk_analysis/main.dart';
import 'package:flutter/material.dart';
import '../../core/security/credential_vault.dart';
import '../../data/providers/portal_scrapper.dart';
import 'dashboard_screen.dart';
import '../../data/repositories/attendance_data.dart';

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
      await CredentialVault.saveCredentials(regno: regno, password: password);
      final profile = await api.profile();
      final attendance = await api.fetchAttendance();
      print("ATTENDANCE:");
      print(attendance.data);
      print("PROFILE:");
      print(profile.data);
      await LocalCache.saveProfile(profile.data);
      await LocalCache.saveAttendance(attendance.data);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage(title: 'NSync')),
      );
      // Optionally save credentials here if you have a secure vault:
      // await CredentialVault.saveCredentials(regno: regno, password: password);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid registration number or password'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
        iconTheme: theme.iconTheme,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          size: 36,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text('NSync', style: theme.textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Sign in to your account',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _regnoController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Registration Number',
                              prefixIcon: const Icon(Icons.person),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter registration number'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Enter password'
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.lerp(
                                theme.colorScheme.inversePrimary,
                                Colors.purple,
                                1.0,
                              ),
                              // backgroundColor: theme.colorScheme.inversePrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),

                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'NOTE: Use your student portal login details',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     TextButton(
                    //       onPressed: () {},
                    //       child: const Text('Forgot password?'),
                    //     ),
                    //     TextButton(
                    //       onPressed: () {},
                    //       child: const Text('Create account'),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
