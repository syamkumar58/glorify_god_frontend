import 'dart:developer';

import 'package:glorify_god/models/user_models/user_login_response_model.dart';
import 'package:glorify_god/src/api/api_calls.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

GoogleSignIn googleSignIn = GoogleSignIn();

Future<UserCredential> signInWithGoogle() async {
  //<-- Sign In with google -->/
  final googleSigning = await googleSignIn.signIn();

  //<-- google authentication from firebase  -->/
  final googleAuth = await googleSigning?.authentication;

  //<-- google credentials -->/
  final credentials = GoogleAuthProvider.credential(
    accessToken: googleAuth!.accessToken,
    idToken: googleAuth.idToken,
  );

  //<-- This below line will confirms that the
  // user is already present in the firebase or not.
  // If not creates one in the firebase
  // or
  // It signOuts the existing user from there and sign in again with the same credentials -->/
  final user = await FirebaseAuth.instance
      .fetchSignInMethodsForEmail(googleSigning!.email);

  if (user.isNotEmpty) {
    //<-- if user cred isNotEmpty means user is there in the firebase
    // 1. SignOut
    // 2. Sign in to firebase with same credentials
    // -->/
    await googleSignIn.signOut();

    final userDetails =
        await FirebaseAuth.instance.signInWithCredential(credentials);
    log('$userDetails', name: 'from the if con');
    // storeLogInDetailsInHive(userDetails);
    return userDetails;
  } else {
    //<-- If the user not in firebase
    // Simply create a new user details
    // -->/
    final userDetails =
        await FirebaseAuth.instance.signInWithCredential(credentials);
    log('$userDetails', name: 'from the else con');
    // storeLogInDetailsInHive(userDetails);
    return userDetails;
  }
}

Future<UserLoginResponseModel?> googleLogin() async {
  final userCredentials = await signInWithGoogle();

  try {
    final userLogin = await ApiCalls().logIn(
      email: userCredentials.user!.email!,
      displayName: userCredentials.user!.displayName!,
      profileUrl: userCredentials.user!.photoURL!,
    );
    log('\n\n $userLogin \n\n', name: 'userLogin!.body from user bloc');
    await storeLogInDetailsInHive(userLogin!);
    return userLogin;
  } catch (er) {
    log('$er', name: 'loginError from user bloc');
    rethrow;
  }
}

Future<dynamic> storeLogInDetailsInHive(UserLoginResponseModel userLoginResponse) async {
  final glorifyGodBox = Hive.box<dynamic>(HiveKeys.openBox);

  final userLogInData = await glorifyGodBox.get(
    HiveKeys.logInKey,
  );
  if (userLogInData != null) {
    await glorifyGodBox.delete(
      HiveKeys.logInKey,
    );
  }

  final theJson = userLoginResponse.toJson();

  try {
    await glorifyGodBox
        .put(HiveKeys.logInKey, theJson)
        .catchError((dynamic onError) {
      log('$onError', name: 'while storing, the error from catch');
    });

    final existingData = await glorifyGodBox.get(
      HiveKeys.logInKey,
      defaultValue: UserLoginResponseModel,
    );

    log(
      'the user created details from hive\n'
      '$existingData'
      '\n\n',
    );
  } catch (err) {
    log('$err', name: 'while storing the error');
  }
}
