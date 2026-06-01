import 'dart:ui';

import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  // LocalStorageService is accessed via AuthService internally

  var user = Rx<User?>(null);
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkIfLoggedIn();
  }

  void _checkIfLoggedIn() {
    user.value = _authService.getSavedUser();
    isLoggedIn.value = _authService.isLoggedIn();
  }

  Future<void> signup({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'customer',
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _authService.signup(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );

      user.value = User.fromJson(response['user']);
      isLoggedIn.value = true;

      if (user.value!.role == 'admin') {
        Get.offAllNamed('/admin');
      } else if (user.value!.role == 'turf_owner') {
        Get.offAllNamed('/owner');
      } else {
        Get.offAllNamed('/home');
      }
      Get.snackbar('Success', 'Account created successfully');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      user.value = User.fromJson(response['user']);
      isLoggedIn.value = true;

      if (user.value!.role == 'admin') {
        Get.offAllNamed('/admin');
      } else if (user.value!.role == 'turf_owner') {
        Get.offAllNamed('/owner');
      } else {
        Get.offAllNamed('/home');
      }
      Get.snackbar('Success', 'Logged in successfully');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authService.logout();
      user.value = null;
      isLoggedIn.value = false;
      Get.offAllNamed('/login');
      Get.snackbar('Success', 'Logged out successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String location,
  }) async {
    isLoading.value = true;
    try {
      final UserService userService = UserService();
      final updatedUser = await userService.updateProfile(
        name: name,
        phone: phone,
        location: location,
      );
      user.value = updatedUser;
      await _authService.saveUser(updatedUser);
      Get.snackbar('Success', 'Profile updated successfully',
          backgroundColor: const Color(0xFF4CAF50), colorText: const Color(0xFFFFFFFF));
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          backgroundColor: const Color(0xFFF44336), colorText: const Color(0xFFFFFFFF));
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String newPassword) async {
    isLoading.value = true;
    try {
      await _authService.changePassword(newPassword);
      Get.snackbar('Success', 'Password updated successfully',
          backgroundColor: const Color(0xFF4CAF50), colorText: const Color(0xFFFFFFFF));
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          backgroundColor: const Color(0xFFF44336), colorText: const Color(0xFFFFFFFF));
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
