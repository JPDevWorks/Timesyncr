import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timesyncr/Home.dart';
import 'package:timesyncr/database/database_service.dart';
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
  Uint8List? pickedImage;

  @override
  void initState() {
    super.initState();
    getUserProfile();
  }

  Future<void> getUserProfile() async {
    Userdetials? user =
        await DatabaseService.getUserDetailsByEmail(widget.userId);
    if (user != null) {
      setState(() {
        userProfile = user;
        _nameController.text = userProfile!.name.toString();
        _phoneController.text = userProfile!.phonenumber.toString();
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
                ? Color(0xFF0D6E6E)
                : Color(0xFFFF3D3D),
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
        title: Text('Profile'),
        backgroundColor: themeController.isDarkTheme.value
            ? Color(0xFF0D6E6E)
            : Color(0xFFFF3D3D),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 325,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themeController.isDarkTheme.value
                      ? [Color(0xFF0D6E6E), Color.fromARGB(182, 0, 0, 0)]
                      : [Color(0xFFFF3D3D), Color.fromARGB(76, 255, 255, 255)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
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
                          color: Color.fromARGB(161, 158, 158, 158),
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
                              ? Icon(
                                  Icons.person_rounded,
                                  color: Colors.black38,
                                  size: 85,
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
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
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildProfileInfoTile('Name', _nameController),
                  SizedBox(height: 10),
                  _buildProfileInfoTile(
                    'Phone Number',
                    _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        updateUserProfile();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeController.isDarkTheme.value
                            ? Color(0xFF0D6E6E)
                            : Color(0xFFFF3D3D),
                      ),
                      child: Text(
                        'Update Profile',
                        style: TextStyle(
                          color: themeController.isDarkTheme.value
                              ? Color.fromARGB(255, 0, 0, 0)
                              : Color.fromARGB(255, 250, 248, 248),
                        ),
                      ),
                    ),
                  ),
                ],
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
    return Obx(() => Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color:
                themeController.isDarkTheme.value ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
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
              SizedBox(height: 10),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                readOnly: title == 'Email' || title == 'Status',
                decoration: InputDecoration(
                  hintText: 'Enter your $title',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void updateUserProfile() async {
    String newName = _nameController.text.trim();
    String newPhone = _phoneController.text.trim();

    if (newName.isNotEmpty && newPhone.isNotEmpty) {
      try {
        await DatabaseService.updateUserDetailsByEmail(
          email: userProfile!.email.toString(),
          name: newName,
          phoneNumber: newPhone,
          profileImage: pickedImage,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );

        await getUserProfile();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name and phone cannot be empty')),
      );
    }
  }
}
