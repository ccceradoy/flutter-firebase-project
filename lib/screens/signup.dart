import 'package:final_project/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // controllers for the fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey();

  // empty field validator
  String? emptyValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }
    return null;
  }

  // password validator
  String? passwordValidator(String? val) {
    if (val!.length < 8 ||
        val.contains(RegExp(r'[A-Z]')) == false ||
        val.contains(RegExp(r'[a-z]')) == false ||
        val.contains(RegExp(r'[0-9]')) == false ||
        val.contains(RegExp(r'[^a-zA-Z0-9]')) == false) {
      return 'Password should be at least 8 characters long with at least a number, a special character, and both uppercase and lowercase letters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 40.0, right: 40.0),
          child: Form(
            // autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _key,
            child: ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: [
                TextFormField(
                  controller: firstNameController,
                  validator: (value) {
                    return emptyValidator(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'First Name',
                  ),
                ),
                TextFormField(
                  controller: lastNameController,
                  validator: (value) {
                    return emptyValidator(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Last Name',
                  ),
                ),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    return emptyValidator(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Email',
                  ),
                ),
                TextFormField(
                  controller: usernameController,
                  validator: (value) {
                    return emptyValidator(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Username',
                  ),
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (emptyValidator(value) == null &&
                        passwordValidator(value) == null) {
                      return null;
                    } else if (emptyValidator(value) == null) {
                      return passwordValidator(value);
                    } else {
                      return emptyValidator(value);
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                ),
                TextFormField(
                  controller: birthdayController,
                  validator: (value) {
                    return emptyValidator(value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Birthday',
                  ),
                  onTap: () async {
                    DateTime? birthday = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (birthday != null) {
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(birthday);
                      setState(() {
                        birthdayController.text = formattedDate;
                      });
                    }
                  },
                ),
                TextFormField(
                  controller: locationController,
                  validator: (value) {
                    return emptyValidator(value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Location',
                  ),
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      countryListTheme: const CountryListThemeData(
                        inputDecoration: InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      onSelect: (Country country) {
                        setState(() {
                          locationController.text =
                              country.displayNameNoCountryCode;
                        });
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_key.currentState!.validate()) {
                        final success =
                            await context.read<AuthProvider>().signUp(
                                  firstName: firstNameController.text,
                                  lastName: lastNameController.text,
                                  username: usernameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  birthday: birthdayController.text,
                                  location: locationController.text,
                                );
                        if (success != null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(success)));
                        } else {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text('Sign up'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
