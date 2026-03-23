

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'volunteer_login.dart';

class VolunteerRegistrationPage extends StatefulWidget {
  @override
  _VolunteerRegistrationPageState createState() => _VolunteerRegistrationPageState();
}

class _VolunteerRegistrationPageState extends State<VolunteerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController whyVolunteerController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController otherNonHelplineController = TextEditingController();


  String volunteerType = '';
  List<String> nonHelplineRoles = [
    'Event Support',
    'Fundraising',
    'Community Outreach',
    'Campus Ambassador',
    'Social Media & Digital Promotion',
    'Content Writing / Blogging',
    'Graphic Design / Creative Support',
    'Technical Support',
    'Translation / Language Support',
    'Photography / Videography',
    'Mentorship / Training',
    'Case Follow-up Coordinator',
    'Crisis Response Assistant',
    'Resource & Referral Assistant'
  ];
  List<String> helplineRoles = ['Call/Chat Support Volunteer'];
  Map<String, bool> selectedRolesHelpline = {};
  Map<String, bool> selectedRolesNonHelpline = {};

 
 
  List<String> days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  Map<String, bool> selectedDaysHelpline = {};
  Map<String, bool> selectedDaysNonHelpline = {};
  List<String> times = [
    '12:00 AM – 4:00 AM',
    '4:00 AM – 8:00 AM',
    '8:00 AM – 12:00 PM',
    '12:00 PM – 4:00 PM',
    '4:00 PM – 8:00 PM',
    '8:00 PM – 12:00 AM',
    'Flexible / Available 24 Hours'
  ];
  Map<String, bool> selectedTimesHelpline = {};
  Map<String, bool> selectedTimesNonHelpline = {};



  bool agreePolicy = false,
      consentContact = false,
      confirmInfo = false,
      cyberLawConsent = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    for (var role in helplineRoles) selectedRolesHelpline[role] = false;
    for (var role in nonHelplineRoles) selectedRolesNonHelpline[role] = false;
    for (var day in days) {
      selectedDaysHelpline[day] = false;
      selectedDaysNonHelpline[day] = false;
    }
    for (var t in times) {
      selectedTimesHelpline[t] = false;
      selectedTimesNonHelpline[t] = false;
    }
  }




  _pickDOB() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = picked.toIso8601String().split('T')[0];
    }
  }

 
 

  bool isAdult(String dob) {
    if (dob.isEmpty) return false;
    try {
      DateTime birth = DateTime.parse(dob);
      DateTime today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month ||
          (today.month == birth.month && today.day < birth.day)) age--;
      return age >= 18;
    } catch (e) {
      print("isAdult Check Error: $e");
      return false;
    }
  }





  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }




  void debugPrintFields() {
    print("============ Registration Form Fields ============");
    print("Full Name: ${fullNameController.text}");
    print("Email: ${emailController.text}");
    print("Phone: ${phoneController.text}");
    print("DOB: ${dobController.text}");
    print("Address: street=${streetController.text}, city=${cityController.text}, state=${stateController.text}, postal=${postalCodeController.text}");
    print("Volunteer Type: $volunteerType");
    print("Roles: ${volunteerType == 'helpline' ? selectedRolesHelpline : selectedRolesNonHelpline}");
    print("Other Role: ${otherNonHelplineController.text}");
    print("Days: ${volunteerType == 'helpline' ? selectedDaysHelpline : selectedDaysNonHelpline}");
    print("Times: ${volunteerType == 'helpline' ? selectedTimesHelpline : selectedTimesNonHelpline}");
    print("Why Volunteer: ${whyVolunteerController.text}");
    print("Skills: ${skillsController.text}");
    print("Consents: Policy=$agreePolicy, Contact=$consentContact, Info=$confirmInfo, CyberLaw=$cyberLawConsent");
    print("==================================================");
  }




  _submitForm() async {
    debugPrintFields();
    if (!_formKey.currentState!.validate()) {
      print("Validation failed!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields correctly")),
      );
      return;
    }

    if (!isValidEmail(emailController.text.trim())) {
      print("Invalid email format.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    if (!isAdult(dobController.text)) {
      print("Not an adult.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be at least 18 years old")),
      );
      return;
    }

    if (volunteerType.isEmpty) {
      print("Volunteer type not selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select a volunteer type (Helpline or Non-Helpline)")),
      );
      return;
    }

    Map<String, bool> selectedRoles =
        volunteerType == 'helpline' ? selectedRolesHelpline : selectedRolesNonHelpline;
    bool hasSelectedRole = selectedRoles.values.any((selected) => selected) ||
        (volunteerType == 'non-helpline' && otherNonHelplineController.text.isNotEmpty);

    if (!hasSelectedRole) {
      print("No role selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one role or specify other role")),
      );
      return;
    }

    Map<String, bool> selectedDays =
        volunteerType == 'helpline' ? selectedDaysHelpline : selectedDaysNonHelpline;
    Map<String, bool> selectedTimes =
        volunteerType == 'helpline' ? selectedTimesHelpline : selectedTimesNonHelpline;

    bool hasSelectedDay = selectedDays.values.any((selected) => selected);
    bool hasSelectedTime = selectedTimes.values.any((selected) => selected);

    if (!hasSelectedDay) {
      print("No day selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one day for availability")),
      );
      return;
    }

    if (!hasSelectedTime) {
      print("No time selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one time slot for availability")),
      );
      return;
    }

    if (!(agreePolicy && consentContact && confirmInfo && cyberLawConsent)) {
      print("Not all consent checkboxes selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All consent checkboxes must be selected")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      print("Attempting to register user...");
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      String uid = userCredential.user!.uid;
      print("User created: $uid");

      List<String> roles = [];
      selectedRoles.forEach((k, v) {
        if (v) roles.add(k);
      });
      if (volunteerType == 'non-helpline' &&
          otherNonHelplineController.text.isNotEmpty) {
        roles.add(otherNonHelplineController.text.trim());
      }

      List<String> availabilityDays = [];
      selectedDays.forEach((k, v) {
        if (v) availabilityDays.add(k);
      });

      List<String> availabilityTimes = [];
      selectedTimes.forEach((k, v) {
        if (v) availabilityTimes.add(k);
      });

      print("Saving registration info to Firestore...");
      await FirebaseFirestore.instance
          .collection('volunteers')
          .doc(uid)
          .set({
        'uid': uid,
        'fullName': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'dob': dobController.text.trim(),
        'address': {
          'street': streetController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'postalCode': postalCodeController.text.trim(),
        },
        'volunteerType': volunteerType,
        'roles': roles,
        'availabilityDays': availabilityDays,
        'availabilityTimes': availabilityTimes,
        'additionalInfo': {
          'whyVolunteer': whyVolunteerController.text.trim(),
          'skillsExperience': skillsController.text.trim(),
        },
        'consent': {
          'agreePolicy': agreePolicy,
          'consentContact': consentContact,
          'confirmInfo': confirmInfo,
          'cyberLawConsent': cyberLawConsent,
        },
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print("Registration data saved in Firestore for UID: $uid");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful! Your application is pending admin approval."),
          backgroundColor: Colors.green,
        ),
      );

      print("Navigating to login page...");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VolunteerLoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = "";
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      switch (e.code) {
        case 'email-already-in-use':
          msg = "This email is already registered. Please use a different email or login.";
          break;
        case 'weak-password':
          msg = "Password is too weak. Please use at least 6 characters.";
          break;
        case 'invalid-email':
          msg = "Please enter a valid email address.";
          break;
        case 'operation-not-allowed':
          msg = "Email/password accounts are not enabled. Please contact support.";
          break;
        default:
          msg = e.message ?? "Registration failed. Please try again.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } catch (e) {
      print("Registration error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildCheckboxList(Map<String, bool> map) {
    return Column(
      children: map.keys.map((key) {
        return CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(key),
          value: map[key],
          onChanged: (val) {
            setState(() {
              map[key] = val!;
            });
          },
        );
      }).toList(),
    );
  }



  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    dobController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    whyVolunteerController.dispose();
    skillsController.dispose();
    otherNonHelplineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Registration"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpansionTile(
                initiallyExpanded: true,
                title: const Text("👤 Personal Information",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty)
                        return "Full name is required";
                      if (val.trim().length < 2)
                        return "Name must be at least 2 characters";
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email Address *",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty)
                        return "Email is required";
                      if (!isValidEmail(val.trim()))
                        return "Please enter a valid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password *",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return "Password is required";
                      if (val.length < 6)
                        return "Password must be at least 6 characters";
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: "Phone Number *",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty)
                        return "Phone number is required";
                      String cleanVal = val.replaceAll(RegExp(r'[^\d]'), '');
                      if (cleanVal.length < 10)
                        return "Please enter a valid phone number";
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: dobController,
                    decoration: InputDecoration(
                      labelText: "Date of Birth *",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today), onPressed: _pickDOB),
                    ),
                    readOnly: true,
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return "Date of birth is required";
                      if (!isAdult(val)) return "You must be at least 18 years old";
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              ExpansionTile(
                title: const Text("Address Information",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: streetController,
                      decoration: const InputDecoration(
                        labelText: "Street Address *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      v == null || v.trim().isEmpty ? "Street address is required" : null),
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: "City *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      v == null || v.trim().isEmpty ? "City is required" : null),
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: stateController,
                      decoration: const InputDecoration(
                        labelText: "State *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      v == null || v.trim().isEmpty ? "State is required" : null),
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: postalCodeController,
                      decoration: const InputDecoration(
                        labelText: "Postal Code *",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return "Postal code is required";
                        String cleanVal = val.replaceAll(RegExp(r'[^\d]'), '');
                        if (cleanVal.length < 5)
                          return "Please enter a valid postal code";
                        return null;
                      }),
                  const SizedBox(height: 10),
                ],
              ),
              ExpansionTile(
                title: const Text("Volunteer Type *",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Radio(
                        value: "helpline",
                        groupValue: volunteerType,
                        onChanged: (v) {
                          setState(() {
                            volunteerType = v!;
                            selectedRolesNonHelpline.updateAll((key, value) => false);
                            selectedDaysNonHelpline.updateAll((key, value) => false);
                            selectedTimesNonHelpline.updateAll((key, value) => false);
                            otherNonHelplineController.clear();
                          });
                        },
                      ),
                      const Text("Helpline Support"),
                      const SizedBox(width: 20),
                      Radio(
                        value: "non-helpline",
                        groupValue: volunteerType,
                        onChanged: (v) {
                          setState(() {
                            volunteerType = v!;
                            selectedRolesHelpline.updateAll((key, value) => false);
                            selectedDaysHelpline.updateAll((key, value) => false);
                            selectedTimesHelpline.updateAll((key, value) => false);
                          });
                        },
                      ),
                      const Text("Non-Helpline Support"),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              if (volunteerType.isNotEmpty)
                ExpansionTile(
                  title: const Text("Select Roles *",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    const SizedBox(height: 10),
                    if (volunteerType == 'helpline')
                      buildCheckboxList(selectedRolesHelpline),
                    if (volunteerType == 'non-helpline')
                      Column(
                        children: [
                          buildCheckboxList(selectedRolesNonHelpline),
                          const SizedBox(height: 10),
                          TextFormField(
                              controller: otherNonHelplineController,
                              decoration: const InputDecoration(
                                labelText: "Other Role (if not listed above)",
                                border: OutlineInputBorder(),
                              )),
                        ],
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              if (volunteerType.isNotEmpty)
                ExpansionTile(
                  title: const Text("Availability *",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    const SizedBox(height: 10),
                    const Text("Available Days:",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    buildCheckboxList(
                        volunteerType == 'helpline'
                            ? selectedDaysHelpline
                            : selectedDaysNonHelpline),
                    const SizedBox(height: 15),
                    const Text("Available Times:",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    buildCheckboxList(
                        volunteerType == 'helpline'
                            ? selectedTimesHelpline
                            : selectedTimesNonHelpline),
                    const SizedBox(height: 10),
                  ],
                ),
              ExpansionTile(
                title: const Text("Additional Information",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: whyVolunteerController,
                      decoration: const InputDecoration(
                        labelText: "Why do you want to volunteer?",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3),
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: skillsController,
                      decoration: const InputDecoration(
                        labelText: "Relevant Skills / Experience",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3),
                  const SizedBox(height: 10),
                ],
              ),
              ExpansionTile(
                title: const Text("✅ Consent & Agreements *",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: agreePolicy,
                    onChanged: (v) => setState(() => agreePolicy = v!),
                    title: const Text(
                        "I agree to the Volunteer Policy and Terms of Service."),
                  ),
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: confirmInfo,
                    onChanged: (v) => setState(() => confirmInfo = v!),
                    title: const Text(
                        "I confirm that all information provided is accurate and complete."),
                  ),
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: consentContact,
                    onChanged: (v) => setState(() => consentContact = v!),
                    title: const Text(
                        "I consent to be contacted regarding volunteer activities and updates."),
                  ),
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: cyberLawConsent,
                    onChanged: (v) => setState(() => cyberLawConsent = v!),
                    title: const Text(
                        "I understand that legal action can be taken as per Cyber Security Laws for any misuse."),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Register", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VolunteerLoginPage()));
                    },
                    child: const Text("Login",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
