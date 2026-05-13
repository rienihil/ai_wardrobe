import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String baseUrl = "http://10.0.2.2:8000";

  String name = "";
  String city = "";
  String email = "";
  String language = "English";
  bool darkMode = false;
  String profileImage = "";

  final cityController = TextEditingController();
  List<String> citySuggestions = [];
  bool showCitySuggestions = false;

  final List<String> allStyles = [
    "Casual",
    "Streetwear",
    "Formal",
    "Sport",
    "Romantic",
    "Vintage",
  ];

  final List<String> fitOptions = [
    "Regular",
    "Oversized",
    "Fitted",
  ];

  final List<String> bodyShapeOptions = [
    "None",
    "Pear",
    "Apple",
    "Rectangle",
    "Hourglass",
    "Inverted triangle",
  ];

  final List<String> avoidOptions = [
    "t-shirt",
    "tank_top",
    "longsleeve",
    "top",
    "shirt",
    "blouse",
    "sweatshirt",
    "hoodie",
    "sweater",
    "jeans",
    "trousers",
    "skirt",
    "shorts",
    "leggings",
    "sweatpants",
    "dress",
    "sneakers",
    "sport_shoes",
    "heels",
    "boots",
    "flats",
    "coat",
    "jacket",
    "blazer",
    "cardigan",
    "puffer",
  ];

  List<String> preferredStyles = [];
  String preferredFit = "Regular";
  List<String> avoidSubcategories = [];
  String bodyShape = "None";

  bool loadingPreferences = false;
  bool savingPreferences = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadUserPreferences();
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final data = await AuthService.getProfile();
    final loadedDarkMode = data['dark_mode'] ?? false;

    setState(() {
      name = data['name'] ?? "";
      email = data['email'] ?? "";
      city = data['city'] ?? "";
      language = data['language'] ?? "English";
      darkMode = data['dark_mode'] ?? false;
      cityController.text = city;
      profileImage = data['profile_image'] ?? "";
    });

    if (!mounted) return;

    Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).setDarkMode(loadedDarkMode);
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final imageUrl =
    await AuthService.uploadProfilePhoto(pickedFile.path);

    if (imageUrl != null) {
      setState(() {
        profileImage = imageUrl;
      });
    }
  }

  Future<void> loadUserPreferences() async {
    setState(() {
      loadingPreferences = true;
    });

    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.get(
        Uri.parse("$baseUrl/user_preferences"),
        headers: headers,
      );

      print("GET USER PREFERENCES STATUS: ${response.statusCode}");
      print("GET USER PREFERENCES BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          preferredStyles = List<String>.from(
            data["preferred_styles"] ?? [],
          );

          preferredFit = data["preferred_fit"] ?? "Regular";

          avoidSubcategories = List<String>.from(
            data["avoid_subcategories"] ?? [],
          );

          bodyShape = data["body_shape"] ?? "None";
        });
      }
    } catch (e) {
      print("Failed to load preferences: $e");
    } finally {
      if (mounted) {
        setState(() {
          loadingPreferences = false;
        });
      }
    }
  }

  Future<void> saveUserPreferences() async {
    if (savingPreferences) return;

    setState(() {
      savingPreferences = true;
    });

    try {
      final headers = await AuthService.getAuthHeaders();

      final body = {
        "preferred_styles": preferredStyles,
        "preferred_fit": preferredFit,
        "avoid_subcategories": avoidSubcategories,
        "body_shape": bodyShape,
      };

      print("SAVE USER PREFERENCES:");
      print(body);

      final response = await http.put(
        Uri.parse("$baseUrl/user_preferences"),
        headers: headers,
        body: jsonEncode(body),
      );

      print("PUT USER PREFERENCES STATUS: ${response.statusCode}");
      print("PUT USER PREFERENCES BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Style preferences saved!")),
        );
      } else {
        throw Exception("Failed to save preferences");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          savingPreferences = false;
        });
      }
    }
  }

  void onCityChanged(String input) async {
    if (input.isEmpty) {
      setState(() {
        citySuggestions = [];
        showCitySuggestions = false;
      });
      return;
    }

    final key = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=(cities)&key=$key';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      setState(() {
        citySuggestions = List<String>.from(
          data['predictions'].map((p) => p['description']),
        );
        showCitySuggestions = true;
      });
    }
  }

  void selectCity(String selected) async {
    cityController.text = selected;

    setState(() {
      city = selected;
      citySuggestions = [];
      showCitySuggestions = false;
    });

    await AuthService.updateProfile({"city": selected});
  }

  void changeLanguage() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Select Language"),
          children: [
            SimpleDialogOption(
              child: const Text("English"),
              onPressed: () => Navigator.pop(context, "English"),
            ),
            SimpleDialogOption(
              child: const Text("Russian"),
              onPressed: () => Navigator.pop(context, "Russian"),
            ),
            SimpleDialogOption(
              child: const Text("Kazakh"),
              onPressed: () => Navigator.pop(context, "Kazakh"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        language = result;
      });

      await AuthService.updateProfile({"language": result});
    }
  }

  void logout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  String prettyLabel(String value) {
    if (value.isEmpty) return "";

    final special = {
      "t-shirt": "T-shirt",
      "tank_top": "Tank top",
      "sport_shoes": "Sport shoes",
    };

    if (special.containsKey(value)) {
      return special[value]!;
    }

    return value
        .replaceAll("_", " ")
        .split(" ")
        .map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    })
        .join(" ");
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget buildChipGroup({
    required List<String> options,
    required List<String> selectedValues,
    required Function(String value, bool selected) onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final selected = selectedValues.contains(option);

        return FilterChip(
          label: Text(prettyLabel(option)),
          selected: selected,
          onSelected: (value) {
            onChanged(option, value);
          },
        );
      }).toList(),
    );
  }

  Widget buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required Function(String value) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: options.contains(value) ? value : options.first,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(prettyLabel(option)),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: ListView(
        children: [
          const SizedBox(height: 20),

          Column(
            children: [
              GestureDetector(
                onTap: pickAndUploadImage,
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage:
                  profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                  child: profileImage.isEmpty
                      ? const Icon(Icons.person, size: 45)
                      : null,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                name.isEmpty ? "Loading..." : name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                email,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 30),

          buildSectionTitle("Settings"),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: "City",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: onCityChanged,
                      ),

                      if (showCitySuggestions)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: citySuggestions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(citySuggestions[index]),
                              onTap: () => selectCity(citySuggestions[index]),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text("Language"),
                  subtitle: Text(language),
                  onTap: changeLanguage,
                ),

                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text("Dark Mode"),
                  value: darkMode,
                  onChanged: (value) async {
                    setState(() {
                      darkMode = value;
                    });

                    Provider.of<ThemeProvider>(
                      context,
                      listen: false,
                    ).setDarkMode(value);

                    await AuthService.updateProfile({
                      "dark_mode": value,
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          buildSectionTitle("Style Preferences"),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: loadingPreferences
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Preferred styles",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  buildChipGroup(
                    options: allStyles,
                    selectedValues: preferredStyles,
                    onChanged: (value, selected) {
                      setState(() {
                        if (selected) {
                          if (!preferredStyles.contains(value)) {
                            preferredStyles.add(value);
                          }
                        } else {
                          preferredStyles.remove(value);
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  buildDropdown(
                    label: "Preferred fit",
                    value: preferredFit,
                    options: fitOptions,
                    onChanged: (value) {
                      setState(() {
                        preferredFit = value;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Avoid items",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "These items will be avoided during outfit generation.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  buildChipGroup(
                    options: avoidOptions,
                    selectedValues: avoidSubcategories,
                    onChanged: (value, selected) {
                      setState(() {
                        if (selected) {
                          if (!avoidSubcategories.contains(value)) {
                            avoidSubcategories.add(value);
                          }
                        } else {
                          avoidSubcategories.remove(value);
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  buildDropdown(
                    label: "Body shape consideration",
                    value: bodyShape,
                    options: bodyShapeOptions,
                    onChanged: (value) {
                      setState(() {
                        bodyShape = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(
                        savingPreferences
                            ? "Saving..."
                            : "Save Style Preferences",
                      ),
                      onPressed: savingPreferences
                          ? null
                          : saveUserPreferences,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          buildSectionTitle("Account"),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}