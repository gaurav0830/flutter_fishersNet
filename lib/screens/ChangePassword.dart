import 'package:flutter/material.dart';
import 'package:app/services/ChangePasswordService.dart'; // update the import path as needed

class ChangePasswordForm extends StatefulWidget {
    const ChangePasswordForm({super.key});

    @override
    State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _oldPasswordController = TextEditingController();
    final TextEditingController _newPasswordController = TextEditingController();
    bool _isLoading = false;

    Future<void> _handleChangePassword() async {
        if (!_formKey.currentState!.validate()) return;

        setState(() => _isLoading = true);

        final response = await AuthService.changePassword(
            oldPassword: _oldPasswordController.text.trim(),
            newPassword: _newPasswordController.text.trim(),
        );

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Error occurred')),
        );

        if (response['success'] == true) {
            Navigator.pop(context);
        }
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: Column(
                        children: [
                            const Icon(Icons.lock_outline, size: 60, color: Colors.deepPurple),
                            const SizedBox(height: 10),
                            const Text(
                                'Change Password',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),

                            // Old Password
                            TextFormField(
                                controller: _oldPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: 'Current Password',
                                    prefixIcon: Icon(Icons.lock),
                                    border: OutlineInputBorder(),
                                ),
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Enter your current password'
                                    : null,
                            ),
                            const SizedBox(height: 16),

                            // New Password
                            TextFormField(
                                controller: _newPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: 'New Password',
                                    prefixIcon: Icon(Icons.lock_open),
                                    border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                    if (value == null || value.isEmpty) return 'Enter new password';
                                    if (value.length < 6) return 'Password must be at least 6 characters';
                                    return null;
                                },
                            ),
                            const SizedBox(height: 24),

                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                onPressed: _handleChangePassword,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Change Password', style: TextStyle(color: Colors.white)),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}
