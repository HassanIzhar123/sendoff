import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sendoff/helper/MySharedPreferences.dart';
import 'package:sendoff/screens/authentication/widgets/custom_text_field.dart';
import 'package:sendoff/screens/authentication/widgets/google_button.dart';
import 'package:sendoff/widgets/styled_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helper/helper_functions.dart';
import '../../helper/pallet.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  bool isLogin = false;

  RegisterScreen({super.key, required this.isLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController(text: '');
  final lastNameController = TextEditingController(text: '');
  final emailController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.primaryLight,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.height * 0.03,
        ).copyWith(top: MediaQuery.of(context).size.height * .15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Pallete.primary,
                  child: StyledText(
                    text: "L",
                    maxLines: 1,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 35.0,
              ),
              StyledText(
                text: widget.isLogin ? "LogIn" : "Register",
                fontSize: 36.0,
                maxLines: 1,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 40.0),
              !widget.isLogin
                  ? Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            hintText: "First Name",
                            controller: firstNameController,
                            validator: (val) {
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Expanded(
                          child: CustomTextField(
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            hintText: "Last Name",
                            controller: lastNameController,
                            validator: (val) {
                              return null;
                            },
                          ),
                        )
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(
                height: 15.0,
              ),
              CustomTextField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                hintText: "Email address *",
                controller: emailController,
                validator: (val) {
                  return null;
                },
              ),
              const SizedBox(
                height: 15.0,
              ),
              CustomTextField(
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                hintText: "Password *",
                controller: passwordController,
                validator: (val) {
                  return null;
                },
              ),
              const SizedBox(
                height: 30.0,
              ),
              widget.isLogin
                  ? CustomButton(
                      color: Pallete.primary,
                      borderRadius: 30.0,
                      height: MediaQuery.of(context).size.height * .054,
                      onPressed: () async {
                        if (emailController.text == "") {
                          showToast(context, "email cannot be Empty!");
                        } else if (passwordController.text == "") {
                          showToast(context, "Password cannot be Empty!");
                        } else {
                          await showLoaderDialog(context);
                          SignUpModel? signUpModel = await login(emailController.text, passwordController.text);
                          FocusManager.instance.primaryFocus?.unfocus();

                          if (signUpModel != null) {
                            if (!signUpModel.isError) {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString("customerId", signUpModel.customerId!);
                              await prefs.setBool("isSignedIn", true);
                              MySharedPreferences mySharedPreferences = MySharedPreferences.getInstance();
                              mySharedPreferences.isUserSignedIn = true;
                              if (mounted) {
                                //log"loggedin");
                                Navigator.pop(context);
                                Navigator.pop(context, signUpModel.customerId!);
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(signUpModel.errorMessage ?? ""),
                                ));
                                Navigator.pop(context);
                              }
                            }
                          } else {
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                        }
                      },
                      child: const Center(
                        child: StyledText(
                          text: "Log In",
                          fontSize: 17.0,
                          maxLines: 1,
                          align: TextAlign.center,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : CustomButton(
                      color: Pallete.primary,
                      borderRadius: 30.0,
                      height: MediaQuery.of(context).size.height * .054,
                      onPressed: () async {
                        // String? token = await FirebaseMessaging.instance.getToken();
                        // log("token: $token");
                        if (firstNameController.text == "") {
                          showToast(context, "First Name cannot be Empty!");
                        } else if (lastNameController.text == "") {
                          showToast(context, "Last Name cannot be Empty!");
                        } else if (emailController.text == "") {
                          showToast(context, "email cannot be Empty!");
                        } else if (passwordController.text == "") {
                          showToast(context, "Password cannot be Empty!");
                        } else {
                          await showLoaderDialog(context);
                          SignUpModel? signUpModel = await signUp(firstNameController.text, lastNameController.text,
                              emailController.text, passwordController.text);
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (signUpModel != null) {
                            if (!signUpModel.isError) {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString("customerId", signUpModel.customerId!);
                              await prefs.setBool("isSignedIn", true);
                              MySharedPreferences mySharedPreferences = MySharedPreferences.getInstance();
                              mySharedPreferences.isUserSignedIn = true;
                              if (mounted) {
                                Navigator.pop(context);
                                Navigator.pop(context, signUpModel.customerId);
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(signUpModel.errorMessage ?? ""),
                                ));
                                Navigator.pop(context);
                              }
                            }
                          } else {
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                        }
                      },
                      child: const Center(
                        child: StyledText(
                          text: "Sign Up",
                          fontSize: 17.0,
                          maxLines: 1,
                          align: TextAlign.center,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: GoogleButton(
                  onPressed: () async {
                    await showLoaderDialog(context);
                    SignUpModel signUpModel = await _handleSignIn();
                    if (signUpModel != null) {
                      if (!signUpModel.isError) {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString("customerId", signUpModel.customerId!);
                        await prefs.setBool("isSignedIn", true);
                        MySharedPreferences mySharedPreferences = MySharedPreferences.getInstance();
                        mySharedPreferences.isUserSignedIn = true;
                        if (mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context, signUpModel.customerId);
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(signUpModel.errorMessage ?? ""),
                          ));
                          Navigator.pop(context);
                        }
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Error Occurred"),
                        ));
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 25.0,
                  right: 25.0,
                ),
                child: const Text(
                  "signing in by google will update your password if you already have signed up through email and password!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              !widget.isLogin
                  ? InkWell(
                      onTap: () async {
                        setState(() {
                          widget.isLogin = true;
                        });
                      },
                      child: const StyledText(
                        text: "Already have Account! LogIn",
                        fontSize: 17.0,
                        maxLines: 1,
                        align: TextAlign.center,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        isUnderLine: true,
                      ),
                    )
                  : InkWell(
                      onTap: () async {
                        setState(() {
                          widget.isLogin = false;
                        });
                      },
                      child: const StyledText(
                        text: "Want to SignUp",
                        fontSize: 17.0,
                        maxLines: 1,
                        align: TextAlign.center,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        isUnderLine: true,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn googleSignIn = GoogleSignIn();
  //
  // Future<User?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  //     if (googleSignInAccount == null) {
  //       return null; // The user canceled the sign-in process.
  //     }
  //
  //     final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleSignInAuthentication.accessToken,
  //       idToken: googleSignInAuthentication.idToken,
  //     );
  //
  //     final UserCredential authResult = await _auth.signInWithCredential(credential);
  //     final User? user = authResult.user;
  //     return user;
  //   } catch (error) {
  //     print("Error signing in with Google: $error");
  //     return null;
  //   }
  // }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(margin: const EdgeInsets.only(left: 7), child: const Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<SignUpModel> signUp(String firstName, String lastName, String email, String password) async {
    try {
      UserCredential result =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': user.email,
          'fcmToken': await FirebaseMessaging.instance.getToken(),
        });
        log('User data added to Firestore successfully');
        return SignUpModel(user.uid, false, null);
      } else {
        log('user is not signed up');
        return SignUpModel(null, true, "user is not signed up");
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          return SignUpModel(null, true, 'Email is already in use. Try another email.');
        } else if (e.code == 'invalid-email') {
          return SignUpModel(null, true, 'Invalid email format. Please check the email.');
        } else if (e.code == 'weak-password') {
          return SignUpModel(null, true, 'Password is too weak. Please choose a stronger password.');
        } else {
          return SignUpModel(null, true, 'Error creating user:  ${e.toString()}');
        }
      } else {
        return SignUpModel(null, true, 'Error creating user: ${e.toString()}');
      }
    }
  }

  Future<String?> getFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token;
  }

  Future<SignUpModel> login(String email, String password) async {
    try {
      UserCredential result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
          'fcmToken': await FirebaseMessaging.instance.getToken(),
        });
        return SignUpModel(user.uid, false, null);
      } else {
        log('user is not signed up');
        return SignUpModel(null, true, "user is not signed up");
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          return SignUpModel(null, true, 'User Not Found');
        } else if (e.code == 'wrong-password') {
          return SignUpModel(null, true, 'Incorrect Password');
        } else if (e.code == 'invalid-email') {
          return SignUpModel(null, true, 'Invalid email format. Please check the email.');
        } else {
          return SignUpModel(null, true, 'Error in LogIn: ${e.toString()}');
        }
      } else {
        return SignUpModel(null, true, 'Error in LogIn: ${e.toString()}');
      }
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<SignUpModel> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      if (user != null) {
        List<String> nameParts = user.displayName!.split(' ');
        String firstName = nameParts.first;
        String lastName = nameParts.length > 1 ? nameParts.last : '';
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': user.email,
          'fcmToken': await FirebaseMessaging.instance.getToken(),
        });
        log('User data added to Firestore successfully');
        return SignUpModel(user.uid, false, null);
      } else {
        log('user is not signed up');
        return SignUpModel(null, true, "user is not signed up");
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          return SignUpModel(null, true, 'Email is already in use. Try another email.');
        } else if (e.code == 'invalid-email') {
          return SignUpModel(null, true, 'Invalid email format. Please check the email.');
        } else {
          return SignUpModel(null, true, 'Error creating user:  ${e.toString()}');
        }
      } else {
        return SignUpModel(null, true, 'Error creating user: ${e.toString()}');
      }
    }
  }
}

class SignUpModel {
  String? customerId;
  bool isError;
  String? errorMessage;

  @override
  String toString() {
    return 'SignUpModel{customerId: $customerId, isError: $isError, errorMessage: $errorMessage}';
  }

  SignUpModel(this.customerId, this.isError, this.errorMessage);
}
