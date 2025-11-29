import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';
import '../view_models/register_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.viewModel});

  final RegisterViewModel viewModel;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _firstName = '';
  String _lastName = '';
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.viewModel.register.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant RegisterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.register.removeListener(_onResult);
    widget.viewModel.register.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.register.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'First name'),
                  onChanged: (v) => _firstName = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter first name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Last name'),
                  onChanged: (v) => _lastName = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter last name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (v) => _email = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: (v) => _password = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],
                _loading
                    ? const CircularProgressIndicator()
                    : ListenableBuilder(
                        listenable: widget.viewModel.register,
                        builder: (context, _) {
                          return FilledButton(
                            onPressed: () {
                              widget.viewModel.register.execute((
                                _email,
                                _password,
                                _firstName,
                                _lastName,
                              ));
                            },
                            child: Text('Register'),
                          );
                        },
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.go(Routes.login);
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.register.completed) {
      //String userId = widget.viewModel.userId;
      widget.viewModel.register.clearResult();

      context.go(Routes.home);
    }

    if (widget.viewModel.register.error) {
      widget.viewModel.register.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error while trying to register'),
          action: SnackBarAction(
            label: 'Try again',
            onPressed: () => widget.viewModel.register.execute((
              _email,
              _password,
              _firstName,
              _lastName,
            )),
          ),
        ),
      );
    }
  }
}
