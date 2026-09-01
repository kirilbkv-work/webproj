import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_bloc.dart';
import '../../application/orders/orders_bloc.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/review_repository.dart';
import '../shared/widgets/ui_kit.dart';

/// profile: view and edit registration data, password and stats
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

/// which panel owns the current form error
enum _ErrorOwner { none, profile, password }

class _ProfilePageState extends State<ProfilePage> {
  static const String _lede =
      'All profile data collected at registration can be edited here: name, '
      'contact details, favourite item types and login credentials.';

  final GlobalKey<FormState> _profileForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordForm = GlobalKey<FormState>();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();

  Set<ClothingType> _favorites = <ClothingType>{};

  /// profile the fields were filled from
  UserProfile? _source;

  bool _dirty = false;

  /// suppresses change tracking while fields are filled programmatically
  bool _applying = false;

  _ErrorOwner _errorOwner = _ErrorOwner.none;

  /// waiting for the password change result
  bool _passwordPending = false;
  int? _passwordBaseMessageId;

  List<TextEditingController> get _profileControllers => [
    _firstName,
    _lastName,
    _email,
    _phone,
    _address,
    _username,
  ];

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AuthBloc>();
    final user = bloc.state.user;
    if (user != null) _applyUser(user);
    for (final controller in _profileControllers) {
      controller.addListener(_handleFieldChanged);
    }
    // drop an error left over from another form
    bloc.add(const AuthErrorCleared());
  }

  @override
  void dispose() {
    for (final controller in _profileControllers) {
      controller.removeListener(_handleFieldChanged);
      controller.dispose();
    }
    _currentPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  void _applyUser(UserProfile user) {
    _applying = true;
    _source = user;
    _firstName.text = user.firstName;
    _lastName.text = user.lastName;
    _email.text = user.email;
    _phone.text = user.phone;
    _address.text = user.address;
    _username.text = user.username;
    _favorites = user.favoriteTypes.toSet();
    _dirty = false;
    _applying = false;
  }

  bool _computeDirty() {
    final user = _source;
    if (user == null) return false;
    return _firstName.text != user.firstName ||
        _lastName.text != user.lastName ||
        _email.text != user.email ||
        _phone.text != user.phone ||
        _address.text != user.address ||
        _username.text != user.username ||
        _favorites.length != user.favoriteTypes.length ||
        !_favorites.containsAll(user.favoriteTypes);
  }

  void _handleFieldChanged() {
    if (_applying) return;
    final next = _computeDirty();
    if (next == _dirty) return;
    setState(() => _dirty = next);
  }

  void _toggleFavorite(ClothingType type) {
    setState(() {
      if (!_favorites.remove(type)) _favorites.add(type);
      _dirty = _computeDirty();
    });
  }

  void _handleAuthChanged(BuildContext context, AuthState state) {
    final user = state.user;
    if (user != null && user != _source) {
      setState(() => _applyUser(user));
    }
    if (_passwordPending && state.message?.id != _passwordBaseMessageId) {
      _passwordPending = false;
      _passwordForm.currentState?.reset();
      _currentPassword.clear();
      _newPassword.clear();
    }
  }

  void _save() {
    if (!(_profileForm.currentState?.validate() ?? false)) return;
    setState(() => _errorOwner = _ErrorOwner.profile);
    context.read<AuthBloc>().add(
      AuthProfileSubmitted(
        ProfileDraft(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          address: _address.text.trim(),
          // enum order, not click order
          favoriteTypes: ClothingType.values
              .where(_favorites.contains)
              .toList(),
          username: _username.text.trim(),
        ),
      ),
    );
  }

  void _discard() {
    final user = _source;
    if (user == null) return;
    setState(() {
      _applyUser(user);
      _errorOwner = _ErrorOwner.none;
    });
    _profileForm.currentState?.validate();
  }

  void _changePassword() {
    if (!(_passwordForm.currentState?.validate() ?? false)) return;
    final bloc = context.read<AuthBloc>();
    setState(() => _errorOwner = _ErrorOwner.password);
    _passwordPending = true;
    _passwordBaseMessageId = bloc.state.message?.id;
    bloc.add(
      AuthPasswordSubmitted(
        currentPassword: _currentPassword.text,
        newPassword: _newPassword.text,
      ),
    );
  }

  void _signOut() {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    context.go('/catalog');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.user != current.user ||
          previous.message?.id != current.message?.id,
      listener: _handleAuthChanged,
      builder: (context, state) {
        final user = state.user;
        if (user == null) {
          return PageBody(
            child: EmptyState(
              icon: Icons.account_circle_outlined,
              title: 'You are not signed in',
              message: 'Sign in to see your profile, orders and reviews.',
              action: FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Go to sign in'),
              ),
            ),
          );
        }

        return PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final side = _buildSideColumn(context, user);
                  final main = _buildMainColumn(context, state);
                  if (constraints.maxWidth < 900) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [side, const SizedBox(height: 20), main],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 300, child: side),
                      const SizedBox(width: 24),
                      Expanded(child: main),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final intro = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Account'),
            const SizedBox(height: 10),
            Text('My profile', style: context.texts.displayMedium),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Text(_lede, style: context.texts.bodyLarge),
            ),
          ],
        );
        final signOut = OutlinedButton(
          onPressed: _signOut,
          child: const Text('Sign out'),
        );

        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [intro, const SizedBox(height: 18), signOut],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: intro),
            const SizedBox(width: 24),
            signOut,
          ],
        );
      },
    );
  }

  Widget _buildSideColumn(BuildContext context, UserProfile user) {
    final palette = context.palette;
    final orders = context.watch<OrdersBloc>().state.lines;
    final rated = orders.where((line) => line.order.rating != null).length;
    final reviews = context.read<ReviewRepository>().byAuthor(user.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.brand,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(user.fullName, style: context.texts.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Customer since ${Formatters.isoDate(user.memberSince)}',
                style: context.texts.bodySmall,
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Metric('Orders', '${orders.length}')),
                  Expanded(child: _Metric('Rated', '$rated')),
                  Expanded(child: _Metric('Reviews', '${reviews.length}')),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/cart'),
                  child: const Text('Open Order Cart'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My reviews', style: context.texts.titleLarge),
              const SizedBox(height: 12),
              if (reviews.isEmpty)
                Text(
                  'You have not reviewed anything yet. Rate an arrived order '
                  'from the Order Cart and it will show up here.',
                  style: context.texts.bodySmall,
                )
              else
                for (final review in reviews) _buildReviewRow(context, review),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(BuildContext context, Review review) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            onTap: () => context.go('/catalog/${review.itemId}'),
            child: Text(
              '${review.rating} / 5 stars',
              style: context.texts.bodyMedium?.copyWith(
                color: palette.brandSoft,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: palette.brandSoft,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            Formatters.shortDate(review.createdAt),
            style: context.texts.bodySmall,
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('“${review.comment}”', style: context.texts.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _buildMainColumn(BuildContext context, AuthState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProfilePanel(context, state),
        const SizedBox(height: 20),
        _buildPasswordPanel(context, state),
      ],
    );
  }

  Widget _buildProfilePanel(BuildContext context, AuthState state) {
    final palette = context.palette;
    final error = _errorOwner == _ErrorOwner.profile ? state.formError : null;

    return Panel(
      child: Form(
        key: _profileForm,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Profile details',
                    style: context.texts.titleLarge,
                  ),
                ),
                if (_dirty) const Tag('Unsaved changes'),
              ],
            ),
            const SizedBox(height: 18),
            if (error != null) ...[
              Notice(text: error, tone: NoticeTone.error),
              const SizedBox(height: 18),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 18.0;
                final full = constraints.maxWidth;
                final half = full < 520
                    ? full
                    : ((full - gap) / 2).floorToDouble();

                return Wrap(
                  spacing: gap,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: half,
                      child: _LabeledField(
                        label: 'First name',
                        controller: _firstName,
                        validator: (value) =>
                            _minLength(value, 2, 'first name'),
                      ),
                    ),
                    SizedBox(
                      width: half,
                      child: _LabeledField(
                        label: 'Last name',
                        controller: _lastName,
                        validator: (value) => _minLength(value, 2, 'last name'),
                      ),
                    ),
                    SizedBox(
                      width: half,
                      child: _LabeledField(
                        label: 'Email',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                    ),
                    SizedBox(
                      width: half,
                      child: _LabeledField(
                        label: 'Phone',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Enter your phone number.'
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: full,
                      child: _LabeledField(
                        label: 'Address',
                        controller: _address,
                        hint:
                            'Used as the default delivery address for '
                            'reservations.',
                        validator: (value) => _minLength(value, 8, 'address'),
                      ),
                    ),
                    SizedBox(
                      width: full,
                      child: _LabeledField(
                        label: 'Username',
                        controller: _username,
                        validator: (value) => _minLength(value, 3, 'username'),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            Text(
              'Favourite item types'.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: palette.inkMuted,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final type in ClothingType.values)
                  SelectableChip(
                    label: type.label,
                    selected: _favorites.contains(type),
                    onTap: () => _toggleFavorite(type),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'The catalog highlights items from your favourite types.',
              style: context.texts.bodySmall,
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton(
                  onPressed: _dirty ? _save : null,
                  child: const Text('Save changes'),
                ),
                TextButton(
                  onPressed: _dirty ? _discard : null,
                  child: const Text('Discard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordPanel(BuildContext context, AuthState state) {
    final error = _errorOwner == _ErrorOwner.password ? state.formError : null;

    return Panel(
      child: Form(
        key: _passwordForm,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Login credentials', style: context.texts.titleLarge),
            const SizedBox(height: 18),
            if (error != null) ...[
              Notice(text: error, tone: NoticeTone.error),
              const SizedBox(height: 18),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 18.0;
                final full = constraints.maxWidth;
                final half = full < 520
                    ? full
                    : ((full - gap) / 2).floorToDouble();

                return Wrap(
                  spacing: gap,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: half,
                      child: _LabeledField(
                        label: 'Current password',
                        controller: _currentPassword,
                        obscureText: true,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Enter your current password.'
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: half,
                      child: _LabeledField(
                        label: 'New password',
                        controller: _newPassword,
                        obscureText: true,
                        validator: (value) =>
                            (value == null || value.length < 4)
                            ? 'Use at least 4 characters.'
                            : null,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: _changePassword,
                child: const Text('Change password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _minLength(String? value, int length, String field) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your $field.';
    if (text.length < length) return 'Use at least $length characters.';
    return null;
  }

  static String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your email address.';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    return valid ? null : 'Enter a valid email address.';
  }
}

/// a single profile stat
class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: context.palette.inkMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: context.texts.headlineSmall),
      ],
    );
  }
}

/// labelled form field with an optional hint
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.validator,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: palette.inkMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: context.texts.bodyMedium?.copyWith(color: palette.ink),
        ),
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(hint!, style: context.texts.bodySmall),
        ],
      ],
    );
  }
}
