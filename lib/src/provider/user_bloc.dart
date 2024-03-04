import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/models/user_models/user_login_response_model.dart';
import 'package:glorify_god/src/api/api_calls.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

GoogleSignIn googleSignIn = GoogleSignIn();

Future<UserCredential> signInWithGoogle() async {
  //<--If using Firebase, you might want to reinitialize Firebase -->/
  // await Firebase.initializeApp();

  // Sign out from Google
  await googleSignIn.signOut();

  //<--If using Firebase, you might want to reinitialize Firebase -->/
  // await Firebase.initializeApp();
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

  log('it reached here what happening');

  try {
    final userLogin = await ApiCalls().logIn(
      email: userCredentials.user!.email!,
      displayName: userCredentials.user!.displayName!,
      profileUrl: userCredentials.user!.photoURL!,
      provider: LoginProviders.GOOGLE.toString().split('.')[1],
    );
    log('\n\n $userLogin -- ${LoginProviders.GOOGLE.toString().split('.')[1]} \n\n',
        name: 'userLogin!.body from user bloc');
    await storeLogInDetailsInHive(userLogin!);
    return userLogin;
  } catch (er) {
    log('$er', name: 'loginError from user bloc');
    if (er.toString().contains('Connection refused')) {
      toastMessage(message: 'Login failed, please try again some time later');
    }
    return null;
  }
}

Future<dynamic> storeLogInDetailsInHive(
    UserLoginResponseModel userLoginResponse) async {
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

Future createEmail({
  required String email,
  required String password,
}) async {
  try {
    final create = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password, //'guest.user.7908',
    );
    log('$create', name: 'Created with - ');
  } on FirebaseAuthException catch (er) {
    log('$er', name: 'createEmail failed with exception');
  }
}

Future<UserCredential> signInWithEmail({
  required BuildContext context,
  required String email,
  required String password,
}) async {
  try {
    final emailDetails = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    log('$emailDetails', name: 'Signed with em');
    return emailDetails;
  } on FirebaseAuthException catch (er) {
    log('$er', name: 'Email failed with exception');
    if (er.toString().contains(
        'The supplied auth credential is incorrect, malformed or has expired.')) {
      flushBar(
        context: context,
        messageText:
            'Entered login details are not valid, please try with valid details'
            ' (or) '
            'you can also use google login for easy acess',
      );
    } else if (er.toString().contains('')) {}
    rethrow;
  }
}

Future<UserLoginResponseModel?> emailLogin({
  required BuildContext context,
  required String email,
  required String password,
}) async {
  log('it reached here to email login');

  final emailDetails = await signInWithEmail(
    context: context,
    email: email,
    password: password,
  );

  log('${emailDetails.user!.email}', name: 'it reached here to email login');

  try {
    final userLogin = await ApiCalls().logIn(
      email: emailDetails.user!.email ?? '',
      displayName: 'Guest User',
      profileUrl:
          'https://glorifygod.s3.ap-south-1.amazonaws.com/Guest+User/guestImage.png',
      provider: LoginProviders.EMAIL.toString().split('.')[1],
    );
    log('\n\n $userLogin \n\n', name: 'userLogin!.body from user bloc');
    await storeLogInDetailsInHive(userLogin!);
    return userLogin;
  } catch (er) {
    log('$er', name: 'loginError from user bloc');
    if (er.toString().contains('Connection refused')) {
      toastMessage(message: 'Login failed, please try again some time later');
    }
    return null;
  }
}
