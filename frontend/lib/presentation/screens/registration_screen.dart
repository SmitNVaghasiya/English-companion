import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/env_config.dart';
import '../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_logo.dart';
import 'voice_chat_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  String _username = '';
  String _mobileNo = '';
  String _password = '';
  String _otp = '';
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isOtpSent = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _mobileNoController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.sendOtp('+91$_mobileNo');
      
      if (!mounted) return;
      setState(() {
        _isOtpSent = true;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyOtpAndRegister() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      // First verify OTP
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.verifyOtp('+91$_mobileNo', _otp);

      // Then register the user
      final response = await http.post(
        Uri.parse('${EnvConfig.backendUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _username,
          'mobileNo': '+91$_mobileNo',
          'password': _password,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await authProvider.updateUserDetails(
          token: data['access_token'],
          userId: data['id'],
          username: _username,
          mobileNo: '+91$_mobileNo',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: AppColors.primaryColor,
          ),
        );
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const VoiceChatScreen()),
          (route) => false,
        );
      } else {
        final errorDetail = jsonDecode(response.body)['detail'] ?? response.body;
        if (errorDetail == "Mobile number already exists") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mobile number already registered. Please login.'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context);
        } else if (errorDetail == "Username already exists") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Username already taken. Please choose another.'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isOtpSent = false; // Allow retry
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: $errorDetail'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: AppLogo(size: 150),
              ),
              const SizedBox(height: 20),
              Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A2A44),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create your English Companion account',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                enabled: !_isOtpSent,
                style: TextStyle(
                  color: _isOtpSent 
                      ? (isDarkMode ? Colors.grey[600] : Colors.grey[400])
                      : null,
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a username' : null,
                onSaved: (value) => _username = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _mobileNoController,
                decoration: const InputDecoration(
                  labelText: 'Mobile No. (e.g., 9876543210)',
                  prefixIcon: Icon(Icons.phone_android),
                  prefixText: '+91 ',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                enabled: !_isOtpSent,
                style: TextStyle(
                  color: _isOtpSent 
                      ? (isDarkMode ? Colors.grey[600] : Colors.grey[400])
                      : null,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your mobile number';
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  return null;
                },
                onSaved: (value) => _mobileNo = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                enabled: !_isOtpSent,
                style: TextStyle(
                  color: _isOtpSent 
                      ? (isDarkMode ? Colors.grey[600] : Colors.grey[400])
                      : null,
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your password';
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              if (_isOtpSent) ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'Enter OTP',
                    prefixIcon: Icon(Icons.pin),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter the OTP';
                    if (value.length != 6) return 'OTP must be 6 digits';
                    return null;
                  },
                  onSaved: (value) => _otp = value!,
                  onChanged: (value) {
                    if (value.length == 6) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _isOtpSent ? _verifyOtpAndRegister : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          _isOtpSent ? 'Verify OTP & Register' : 'Send OTP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : const Color(0xFF64748B),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
