import 'package:conference/core/storage/storage.dart';
import 'package:conference/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../models/api_exception.dart';
import '../../services/http_service.dart';

class LoginController extends GetxController {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final _storage = StorageService.instance;

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // HttpService now returns only the ResponseBody on success,
      // or throws ApiException on failure.
      final responseBody = await HttpService.instance.login(
        'auth/v2/authenticateMobileUser',
        body: {
          'email': emailCtrl.text.trim(),
          'password': passwordCtrl.text.trim(),
        },
      );

      if (responseBody != null) {
        _storage.setValue('user', responseBody);
        // Correctly update the singleton state using updateFromJson
        UserModel.instance.updateFromJson(responseBody);
        debugPrint('Login success: $responseBody');
        Get.offAllNamed('/main');
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to connect. Please check your network.');
    } finally {
      isLoading.value = false;
    }
  }

  void showForgotPasswordDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141933) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: Color(0xFF06B6D4),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Reset Password',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confeet accounts are managed by your organization or workspace administrator.',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.85)
                    : const Color(0xFF334155),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'To reset your password or recover access, please contact your organization IT administrator or email support at:',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.65)
                    : const Color(0xFF64748B),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: const SelectableText(
                'support@confeet.com',
                style: TextStyle(
                  color: Color(0xFF06B6D4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Dismiss',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Clipboard.setData(const ClipboardData(text: 'support@confeet.com'));
              Get.snackbar(
                'Email Copied',
                'support@confeet.com copied to clipboard',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF06B6D4),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Email'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFF6B6B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.error_outline_rounded,
        color: Colors.white,
        size: 20,
      ),
      duration: const Duration(seconds: 3),
    );
  }
  //
  // @override
  // void onInit() {
  //   emailCtrl.text = "testuser@test.com";
  //   passwordCtrl.text = "BYodEgFb";
  //
  //   // TODO: implement onInit
  //   super.onInit();
  // }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
