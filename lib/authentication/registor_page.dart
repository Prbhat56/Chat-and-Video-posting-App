import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intern_assignment_app/authentication/login_page.dart';

import 'package:intern_assignment_app/model/user_model.dart';
import 'package:intern_assignment_app/pages/profile_page.dart';

import '../pages/edit_profile_page.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({super.key});

  @override
  State<MyRegister> createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode cpasswordFocus = FocusNode();
  bool _isValidEmail(String email) {
    RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    RegExp lowercaseRegExp = RegExp(r'[a-z]');
    RegExp uppercaseRegExp = RegExp(r'[A-Z]');
    RegExp digitRegExp = RegExp(r'[0-9]');
    RegExp specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    return password.length >= 8 &&
        lowercaseRegExp.hasMatch(password) &&
        uppercaseRegExp.hasMatch(password) &&
        digitRegExp.hasMatch(password) &&
        specialCharRegExp.hasMatch(password);
  }

  bool _isValidName(String name) {
    for (int i = 0; i < name.length; i++) {
      bool _isValidName(String name) {
        RegExp digitRegExp = RegExp(r'\d');
        return !digitRegExp.hasMatch(name);
      }
    }
    return name.contains(RegExp(r'[^\d]'));
  }

  void createAccount() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cpassword = cpasswordController.text.trim();

    bool validationPassed = true;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        cpassword.isEmpty) {
      _showSnackBar("Please fill all the details!");
      validationPassed = false;
    } else if (password != cpassword) {
      _showSnackBar("Passwords do not match!");
      validationPassed = false;
    } else if (name.length < 6) {
      _showSnackBar("Please enter a valid name with at least 6 characters");
      validationPassed = false;
    } else if (!_isValidName(name)) {
      _showSnackBar("Name should contain at least one non-digit character");
      validationPassed = false;
    } else if (!_isValidEmail(email)) {
      _showSnackBar("Invalid email format!");
      validationPassed = false;
    } else if (!_isValidPassword(password)) {
      _showSnackBar("Invalid password format!");
      validationPassed = false;
    }

    UserCredential? credential;

    if (validationPassed) {
      try {
        credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (ex) {
        print(ex.code.toString());
      }
      if (credential != null) {
        String uid = credential.user!.uid;
        UserModel newUser = UserModel(
          uid: uid,
          email: email,
          fullname: name,
          profilepic: "",
        );
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .set(newUser.toMap())
            .then((value) {
          print("New User Created");
                Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return ProfilePage(
                userModel: newUser,
                firebaseUser: credential!.user!,
              );
            },
          ));
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _moveToNextField(FocusNode currentFocus, FocusNode nextFocus) {
    if (_isValidField(currentFocus)) {
      FocusScope.of(context).requestFocus(nextFocus);
    }
  }

  bool _isValidField(FocusNode focusNode) {
    if (focusNode == nameFocus) {
      String name = nameController.text.trim();
      if (name.isEmpty) {
        _showSnackBar("Please enter your name!");
        return false;
      } else if (name.length < 6) {
        _showSnackBar("Please enter a valid name with at least 6 characters");
        return false;
      } else if (!_isValidName(name)) {
        _showSnackBar("Name should contain at least one non-digit character");
        return false;
      }
    } else if (focusNode == emailFocus) {
      String email = emailController.text.trim();
      if (email.isEmpty) {
        _showSnackBar("Please enter your email!");
        return false;
      } else if (!_isValidEmail(email)) {
        _showSnackBar("Invalid email format!");
        return false;
      }
    } else if (focusNode == passwordFocus) {
      String password = passwordController.text.trim();
      if (password.isEmpty) {
        _showSnackBar("Please enter your password!");
        return false;
      } else if (!_isValidPassword(password)) {
        _showSnackBar("Invalid password format!");
        return false;
      }
    } else if (focusNode == cpasswordFocus) {
      String password = passwordController.text.trim();
      String cpassword = cpasswordController.text.trim();
      if (cpassword.isEmpty) {
        _showSnackBar("Please confirm your password!");
        return false;
      } else if (password != cpassword) {
        _showSnackBar("Passwords do not match!");
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 116, 231, 231)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(left: 35, top: 40),
              child: const Text(
                'Create\nAccount',
                style: TextStyle(color: Colors.black, fontSize: 33),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.28,
                    right: 35,
                    left: 35),
                child: Column(children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white)),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Enter your Name',
                        hintStyle: const TextStyle(color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: emailController,
                    focusNode: emailFocus,
                    onEditingComplete: () =>
                        _moveToNextField(emailFocus, passwordFocus),
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white)),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Enter your Email',
                        hintStyle: const TextStyle(color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    onEditingComplete: () =>
                        _moveToNextField(passwordFocus, cpasswordFocus),
                    obscureText: true,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 8, 6, 6))),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Enter your Password',
                        hintStyle: const TextStyle(color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: cpasswordController,
                    focusNode: cpasswordFocus,
                    onEditingComplete: () {
                      if (_isValidField(cpasswordFocus)) {
                        createAccount();
                        print("Create User Call");
                      }
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white)),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Confirm Password',
                        hintStyle: const TextStyle(color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Log in',
                        style: TextStyle(
                            color: Color(0xff4c505b),
                            fontSize: 27,
                            fontWeight: FontWeight.w700),
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xff4c505b),
                        child: IconButton(
                          color: Colors.white,
                          onPressed: () {
                            createAccount();
                            print("Create User Call");
                          },
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                 
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyLogin(),
                            ),
                          );
                        },
                        child: const Text(
                          'already a user sign in ',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            color: Color(0xff4c505b),
                          ),
                        ),
                      )
                    ],
                  )
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
