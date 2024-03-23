import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zerotrash/Screens/Dashboard.dart';

import '../Globals/localhost.dart';
import 'Login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formfield = GlobalKey<FormState>();
  String? confirmPasswordError;
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final NameController = TextEditingController();
  final ConfirmpassController = TextEditingController();
  final RoleController = TextEditingController();
  bool passToggle = true;

  bool _isValidEmail(String email) {
    // Define a regular expression for email validation
    final RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  String? validatePassword(String value) {
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasNumber = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool isLengthValid = value.length >= 8;

    List<String> messages = [];

    if (value.isEmpty) {
      return "Enter Password";
    }

    if (!isLengthValid) {
      messages.add("8 characters ");
    }

    if (!hasUppercase) {
      messages.add("1 uppercase letter ");
    }

    if (!hasNumber && !hasSpecialChar) {
      messages.add("1 number or special character");
    }

    if (!isLengthValid || !hasUppercase || !(hasNumber || hasSpecialChar)) {
      return messages.join(", ");
      // if all ara valid, save it to variable called validPassword
    }
    return null;
  }

  // Add user to database while registering using firestore
  Future<void> registerWithFirebase() async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Successful'),
            content: Text('You have successfully registered.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      String? emailAddress = emailController.text;

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passController.text,
      );

      // extract that JWT token from the userCredential object
      String? token = await userCredential.user!.getIdToken();
      print(token);

      String? hostip = Localhost.backend;

      // send the token to the backend in a POST request Authorization header as a Bearer token
      var response = await http.post(
        Uri.parse('$hostip:3000/user/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'username': NameController.text,
          'email': emailAddress,
          'role': RoleController.text,
        }),
      );
      print(response);
      print("Account Created");

      // login with firebase with the created account.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passController.text,
      );

      emailController.clear();
      passController.clear();
      ConfirmpassController.clear();
    } catch (e) {
      print('Error in Registration: $e');
    }

    Navigator.pop(context);

    // add a dialog box with success message and an OK button
    _showLoginSuccessDialog(context);

    // redirect to main.dart
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Dashboard(),
      ),
    );
  }

  void _showLoginSuccessDialog(BuildContext context) {
    if (_formfield.currentState!.validate()) {
      if (passController.text != ConfirmpassController.text) {
        setState(() {
          confirmPasswordError = "Passwords do not match";
        });
      } else {
        setState(() {
          confirmPasswordError = null;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("You have Successfully Registered"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                    ); // Close the dialog
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              SizedBox(height: 50),
              const Text(
                "Register",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Create Account",
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
              Form(
                key: _formfield,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: NameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter ID";
                          // if there are numbers
                        } else if (value.contains(RegExp(r'[0-9]'))) {
                          return "Enter a valid Name";
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Email";
                        } else if (!_isValidEmail(value)) {
                          return "Enter a valid Email";
                        }
                        return null; // No error
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: 10),
                    // display password guidelines with 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character
                    RichText(
                      text: TextSpan(
                        text: "Password must contain: \n",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                "atleast 8 characters, 1 uppercase letter, 1 number or special character",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        return validatePassword(value!);
                      },
                      controller: passController,
                      obscureText: passToggle,
                      decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                passToggle = !passToggle;
                              });
                            },
                            child: Icon(passToggle
                                ? Icons.visibility
                                : Icons.visibility_off),
                          )),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: ConfirmpassController,
                      obscureText: passToggle,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              passToggle = !passToggle;
                            });
                          },
                          child: Icon(passToggle
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Confirm Password";
                        } else if (value != passController.text) {
                          return "Passwords do not match";
                        }
                        return null; // No error
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    Text(
                      confirmPasswordError ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Role",
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          child: Text("Organizer"),
                          value: "organizer",
                        ),
                        DropdownMenuItem(
                          child: Text("Community User"),
                          value: "community_user",
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          RoleController.text = value.toString();
                        });
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null) {
                          return "Select Role";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              // dropdown for role : organizer, community_user
              const SizedBox(height: 10),
              ElevatedButton(
                // check if all the fields are filled and valid using the _formfield key
                onPressed: () {
                  if (_formfield.currentState!.validate()) {
                    registerWithFirebase();
                  } else {
                    print("Not Validated");
                    // nugget to show that the form is not validated
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all the fields'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(250, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                child: const Text(
                  "Register",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Already Have an Account?",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Create a widget for text field
Widget inputFile({label, obscureText = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(
        height: 5,
      ),
      TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey[400]!,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 10,
      ),
    ],
  );
}
