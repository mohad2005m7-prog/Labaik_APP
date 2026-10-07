import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/auth_controller.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  final bool isPasswordReset;

  const VerificationCodeScreen({
    super.key,
    required this.email,
    this.isPasswordReset = false,
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;

  // إدارة المؤقت (Timer)
  Timer? _timer;
  int _secondsRemaining = 55; // مطابقة للوقت الظاهر في التصميم
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // إضافة مستمعين لإعادة بناء الواجهة لتحديث شكل المربعات عند التركيز/الكتابة
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() => setState(() {}));
      _controllers[i].addListener(() => setState(() {}));
    }
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 55;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onVerifyPressed() {
    final code = _otpCode;

    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال رمز التحقق كاملاً (6 أرقام)',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
        ),
      );
      return;
    }

    AuthController.verifyEmail(
      context: context,
      email: widget.email,
      code: code,
      isPasswordReset: widget.isPasswordReset,
      setLoading: (val) => setState(() => _isLoading = val),
    );
  }

  void _onResendPressed() {
    if (!_canResend) return;

    AuthController.resendCode(context, widget.email);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B3B2B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // العنوان الرئيسي (خط Tajawal غامق)
              const Text(
                'رمز التحقق',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B3B2B),
                ),
              ),
              const SizedBox(height: 12),

              // الوصف المنسق
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'أدخل الرمز المكون من 6 أرقام الذي تم إرساله إلى البريد الإلكتروني المسجل.\n(${widget.email})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: Color(0xFF8A92A6),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // مربعات إدخال الرمز (6 مربعات بتصميم Figma)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final isFocused = _focusNodes[index].hasFocus;
                    final isFilled = _controllers[index].text.isNotEmpty;
                    final isActive = isFocused || isFilled;

                    return Container(
                      width: 48,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive ? const Color(0xFF1B3B2B) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B3B2B),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (index < 5) {
                              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                            } else {
                              _focusNodes[index].unfocus();
                            }
                          } else {
                            if (index > 0) {
                              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                            }
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 36),

              // زر تأكيد الرمز
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onVerifyPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3B2B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'تأكيد',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 28),

              // نص وحالة العداد / إعادة الإرسال
              GestureDetector(
                onTap: _canResend ? _onResendPressed : null,
                child: Text(
                  _canResend
                      ? 'إعادة إرسال الرمز'
                      : 'إعادة إرسال الرمز خلال $_secondsRemaining ثانية',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: _canResend ? const Color(0xFF1B3B2B) : const Color(0xFF1B3B2B),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}