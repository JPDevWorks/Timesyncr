import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesyncr/Home.dart';
import 'package:timesyncr/database/database.dart';
import 'package:timesyncr/models/user.dart';
import 'package:timesyncr/them_controler.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ThemeController themeController = Get.find();
  Userdetials? userProfile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final Future<SharedPreferences>prefs=SharedPreferences.getInstance();
  Uint8List? pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserProfile();
  }

  Future<void> getUserProfile() async {
    
    Userdetials? user = await Databasee.getUserDetailsByEmail(widget.userId);
    if (user != null) {
      setState(() {
        userProfile = user;
        _nameController.text = userProfile?.name ?? '';
        _phoneController.text = userProfile?.phonenumber ?? '';
      });
    }
  }

  Future<void> onProfileUpload() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Timesyncr',
            toolbarColor: themeController.isDarkTheme.value
                ? const Color(0xFF0D6E6E)
                : const Color(0xFFFF3D3D),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Timesyncr',
          minimumAspectRatio: 1.0,
        ),
      ],
    );

    if (croppedFile == null) return;

    final imageBytes = await croppedFile.readAsBytes();
    setState(() {
      pickedImage = imageBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor:
            themeController.isDarkTheme.value ? Colors.black : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 325,
              color: themeController.isDarkTheme.value
                  ? Colors.black
                  : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: onProfileUpload,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(161, 158, 158, 158),
                          shape: BoxShape.circle,
                          image: pickedImage != null
                              ? DecorationImage(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(pickedImage!),
                                )
                              : userProfile?.profileImage != null
                                  ? DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          userProfile!.profileImage!),
                                    )
                                  : null,
                        ),
                        child: Center(
                          child: pickedImage == null &&
                                  userProfile?.profileImage == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  color: Colors.black38,
                                  size: 85,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userProfile?.name ?? '',
                      style: TextStyle(
                        fontSize: 20,
                        color: themeController.isDarkTheme.value
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userProfile?.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: themeController.isDarkTheme.value
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 0),
            Container(
              color: themeController.isDarkTheme.value
                  ? Colors.black
                  : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProfileInfoTile('Name', _nameController),
                    const SizedBox(height: 10),
                    _buildProfileInfoTile(
                      'Phone Number',
                      _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : () => updateUserProfile(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeController.isDarkTheme.value
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20.0,
                                width: 20.0,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : Text(
                                'Update Profile',
                                style: TextStyle(
                                  color: themeController.isDarkTheme.value
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoTile(
    String title,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color:
              themeController.isDarkTheme.value ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.6),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeController.isDarkTheme.value
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: title == 'Email' || title == 'Status',
              decoration: InputDecoration(
                hintText: 'Enter your $title',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateUserProfile() async {
    String newName = _nameController.text.trim();
    String newPhone = _phoneController.text.trim();

    if (newName.isNotEmpty && newPhone.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        await Databasee.updateUserDetailsByEmail(
          email: userProfile?.email ?? '',
          name: newName,
          phoneNumber: newPhone,
          profileImage: pickedImage,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        await getUserProfile();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and phone cannot be empty')),
      );
    }
  }
}
