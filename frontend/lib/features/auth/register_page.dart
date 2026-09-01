import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_bloc.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_palette.dart';
import '../shared/widgets/ui_kit.dart';

/// loose international phone format
final _phonePattern = RegExp(r'^[+()\d][\d\s()-]{6,}$');
final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

/// registration; the assignment asks for the full profile up front
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _favoriteTypes = <ClothingType>{};

  /// local validation error, not the repository one
  String? _localError;
  bool _favoritesTouched = false;

  @override
  void initState() {
    super.initState();
    // drop an error left over from a previous attempt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthErrorCleared());
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleFavorite(ClothingType type) {
    setState(() {
      _favoritesTouched = true;
      if (!_favoriteTypes.add(type)) {
        _favoriteTypes.remove(type);
      }
    });
  }

  void _submit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final typesValid = _favoriteTypes.isNotEmpty;

    if (!formValid || !typesValid) {
      setState(() {
        _favoritesTouched = true;
        _localError =
            'Please complete every field of the profile before continuing.';
      });
      return;
    }

    setState(() => _localError = null);
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        RegistrationData(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          favoriteTypes: ClothingType.values
              .where(_favoriteTypes.contains)
              .toList(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
      ),
    );
  }

  String? _minLength(String? value, int length) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'This field is required.';
    return text.length < length ? 'This value is too short.' : null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        // single column on narrow screens
        final narrow = constraints.maxWidth < 760;

        return BlocConsumer<AuthBloc, AuthState>(
          // only the guest to signed-in transition should navigate
          listenWhen: (previous, current) =>
              !previous.isAuthenticated && current.isAuthenticated,
          listener: (context, state) => context.go('/catalog'),
          builder: (context, state) {
            final error = _localError ?? state.formError;

            return PageBody(
              maxWidth: 760,
              child: Panel(
                padding: EdgeInsets.all(narrow ? 20 : 28),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow('Account'),
                      const SizedBox(height: 8),
                      Text(
                        'Create your account',
                        style: context.texts.displayMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Registration collects the complete customer profile: '
                        'name, contact details, favourite item types and login '
                        'credentials. Everything can be edited later from the '
                        'profile page.',
                        style: context.texts.bodyMedium,
                      ),
                      const SizedBox(height: 22),
                      if (error != null) ...[
                        Notice(text: error, tone: NoticeTone.error),
                        const SizedBox(height: 18),
                      ],
                      _Section(
                        title: 'Name',
                        child: _FormGrid(
                          narrow: narrow,
                          cells: [
                            _GridCell(
                              child: _Field(
                                label: 'First name',
                                child: TextFormField(
                                  controller: _firstNameController,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.givenName,
                                  ],
                                  validator: (value) => _minLength(value, 2),
                                ),
                              ),
                            ),
                            _GridCell(
                              child: _Field(
                                label: 'Last name',
                                child: TextFormField(
                                  controller: _lastNameController,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.familyName,
                                  ],
                                  validator: (value) => _minLength(value, 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      _Section(
                        title: 'Contact information',
                        child: _FormGrid(
                          narrow: narrow,
                          cells: [
                            _GridCell(
                              child: _Field(
                                label: 'Email',
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  validator: (value) {
                                    final text = (value ?? '').trim();
                                    if (text.isEmpty) {
                                      return 'This field is required.';
                                    }
                                    return _emailPattern.hasMatch(text)
                                        ? null
                                        : 'Enter a valid email address, for '
                                              'example name@example.com.';
                                  },
                                ),
                              ),
                            ),
                            _GridCell(
                              child: _Field(
                                label: 'Phone',
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumber,
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: '+1 555 010 0200',
                                  ),
                                  validator: (value) {
                                    final text = (value ?? '').trim();
                                    if (text.isEmpty) {
                                      return 'This field is required.';
                                    }
                                    return _phonePattern.hasMatch(text)
                                        ? null
                                        : 'This value has an unexpected '
                                              'format.';
                                  },
                                ),
                              ),
                            ),
                            _GridCell(
                              wide: true,
                              child: _Field(
                                label: 'Delivery address',
                                child: TextFormField(
                                  controller: _addressController,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.fullStreetAddress,
                                  ],
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Street, number, city, postal '
                                        'code',
                                  ),
                                  validator: (value) => _minLength(value, 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      _Section(
                        title: 'Favourite item types',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final type in ClothingType.values)
                                  SelectableChip(
                                    label: type.label,
                                    selected: _favoriteTypes.contains(type),
                                    onTap: () => _toggleFavorite(type),
                                  ),
                              ],
                            ),
                            if (_favoritesTouched && _favoriteTypes.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Choose at least one favourite type.',
                                  style: context.texts.bodySmall?.copyWith(
                                    color: palette.danger,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      _Section(
                        title: 'Login details',
                        child: _FormGrid(
                          narrow: narrow,
                          cells: [
                            _GridCell(
                              wide: true,
                              child: _Field(
                                label: 'Username',
                                child: TextFormField(
                                  controller: _usernameController,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.newUsername,
                                  ],
                                  validator: (value) => _minLength(value, 3),
                                ),
                              ),
                            ),
                            _GridCell(
                              child: _Field(
                                label: 'Password',
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  validator: (value) {
                                    final text = value ?? '';
                                    if (text.isEmpty) {
                                      return 'This field is required.';
                                    }
                                    return text.length < 4
                                        ? 'Use at least 4 characters.'
                                        : null;
                                  },
                                ),
                              ),
                            ),
                            _GridCell(
                              child: _Field(
                                label: 'Repeat password',
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  onFieldSubmitted: (_) => _submit(),
                                  validator: (value) {
                                    final text = value ?? '';
                                    if (text.isEmpty) {
                                      return 'This field is required.';
                                    }
                                    return text == _passwordController.text
                                        ? null
                                        : 'The two passwords do not match.';
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _submit,
                          child: const Text('Create account'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Already registered?',
                            style: context.texts.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Sign in'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// form section with a heading
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.texts.headlineSmall),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

/// grid cell; [wide] spans both columns
class _GridCell {
  const _GridCell({required this.child, this.wide = false});

  final Widget child;
  final bool wide;
}

/// two-column field grid, one column when narrow
class _FormGrid extends StatelessWidget {
  const _FormGrid({required this.narrow, required this.cells});

  final bool narrow;
  final List<_GridCell> cells;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 18.0;
        final full = constraints.maxWidth;
        final half = (full - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: 16,
          children: [
            for (final cell in cells)
              SizedBox(
                width: narrow || cell.wide ? full : half,
                child: cell.child,
              ),
          ],
        );
      },
    );
  }
}

/// label above an input
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.texts.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.palette.inkSoft,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
