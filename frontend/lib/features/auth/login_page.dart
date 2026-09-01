import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_bloc.dart';
import '../../core/theme/app_palette.dart';
import '../shared/widgets/ui_kit.dart';

/// Вход в систему. Открывает резервирование, корзину и профиль.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.returnUrl});

  /// Адрес, на который нужно вернуться после успешного входа.
  final String? returnUrl;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ошибка могла остаться от прошлой попытки входа — открываем форму чистой.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthErrorCleared());
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _useDemoAccount() {
    _usernameController.text = 'customer';
    _passwordController.text = 'customer';
  }

  /// Пустая строка в returnUrl равнозначна её отсутствию.
  String? get _returnUrl {
    final value = widget.returnUrl;
    return (value == null || value.isEmpty) ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocConsumer<AuthBloc, AuthState>(
      // Нужен именно переход «гость → авторизован», а не любое изменение данных.
      listenWhen: (previous, current) =>
          !previous.isAuthenticated && current.isAuthenticated,
      listener: (context, state) => context.go(_returnUrl ?? '/catalog'),
      builder: (context, state) {
        return PageBody(
          maxWidth: 460,
          child: Panel(
            padding: const EdgeInsets.all(26),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Account'),
                  const SizedBox(height: 8),
                  Text('Sign in', style: context.texts.displayMedium),
                  const SizedBox(height: 10),
                  Text(
                    'Signing in unlocks reservations, your Order Cart and order '
                    'management. Browsing the catalog and reading reviews stay '
                    'open to everyone.',
                    style: context.texts.bodyMedium,
                  ),
                  const SizedBox(height: 22),
                  if (state.formError != null) ...[
                    Notice(text: state.formError!, tone: NoticeTone.error),
                    const SizedBox(height: 14),
                  ],
                  if (_returnUrl != null) ...[
                    const Notice(
                      text: 'Sign in to continue to the page you requested.',
                      tone: NoticeTone.info,
                    ),
                    const SizedBox(height: 14),
                  ],
                  _Field(
                    label: 'Username',
                    child: TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Please enter your username.'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'Password',
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) => (value ?? '').isEmpty
                          ? 'Please enter your password.'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Sign in'),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Panel(
                    flat: true,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Demo account',
                                style: context.texts.bodyMedium?.copyWith(
                                  color: palette.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Username customer · password customer',
                                style: context.texts.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: _useDemoAccount,
                          child: const Text('Fill in'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('No account yet?', style: context.texts.bodyMedium),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('Create one'),
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
  }
}

/// Подпись над полем ввода — единый вид для всех полей формы.
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
