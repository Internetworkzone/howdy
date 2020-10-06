import 'package:firebase_auth/firebase_auth.dart';
import 'package:howdy/repository/auth_repository.dart';
import 'package:howdy/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthRepository authRepository = AuthRepository();
  UserService userService = UserService();

  Future<void> createNewAccount(email, password, name) async {
    AuthResult result = await authRepository.signUp(email, password);
    if (result.user.uid != null) {
      userService.registerNewUser(result.user, name);
    }
  }

  Future<void> signInUser(String email, String password) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print('from service $email $password');
    AuthResult result = await authRepository.signIn(email, password);
    print('from service $email $password');

    preferences.setString('uid', result.user.uid);

    if (result.user.uid != null) {
      userService.updateUser(result.user.uid);
    }
  }

  Future<void> signOutUser() async {
    await authRepository.signOut();
  }
}
