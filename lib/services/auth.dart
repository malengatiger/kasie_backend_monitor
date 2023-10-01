import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot;
import 'package:kasie_transie_library/utils/functions.dart';

final Auth auth = Auth(FirebaseAuth.instance);

class Auth {
  final FirebaseAuth firebaseAuth;
  static const mm = '❤️❤️❤️ Auth';
  Auth(this.firebaseAuth);

  Future<bool> signIn() async {
    await dot.dotenv.load();
    final email = dot.dotenv.env['EMAIL'];
    final pswd = dot.dotenv.env['PASSWORD'];

    final cred = await firebaseAuth.signInWithEmailAndPassword(email: email!, password: pswd!);
    if (cred.user != null) {
      pp('$mm this user signed in: ${cred.user!.displayName} - ${cred.user!.email}');
      return true;
    }
    return false;
  }
}
