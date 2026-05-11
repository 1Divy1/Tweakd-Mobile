import 'package:car_social_media_app/features/profile/presentation/bloc/bloc.dart';
import 'package:car_social_media_app/features/profile/presentation/bloc/event.dart';
import 'package:car_social_media_app/features/profile/presentation/bloc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _primaryColor = Color(0xFFFF4D00);
  static const _backgroundColor = Color(0xFFF4F4F2);
  static const _cardColor = Colors.white;
  static const _borderColor = Color(0xFFE2E3E9);
  static const _labelColor = Color(0xFF1B1B1D);
  static const _mutedTextColor = Color(0xFF6A6B73);

  static final RegExp _usernameAllowed = RegExp(r'^[a-z](?!.*[_.]{2})[a-z0-9._]*[a-z0-9]$');
  static const int _usernameMinLength = 3;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _usernameError;

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String? _validateUsername(String username) {
    if (username.isEmpty) {
      return 'Please enter a callsign.';
    }
    if (username.length < _usernameMinLength) {
      return 'Username must be at least $_usernameMinLength characters.';
    }
    if (!_usernameAllowed.hasMatch(username)) {
      return 'Use only lowercase letters, numbers, dots (.) and underscores (_).';
    }
    return null;
  }

  void _onSubmit(BuildContext context) {
    final username = _usernameController.text.trim();
    final error = _validateUsername(username);
    if (error != null) {
      setState(() => _usernameError = error);
      return;
    }
    setState(() => _usernameError = null);

    final bio = _bioController.text.trim();
    context.read<ProfileBloc>().add(
      SubmitOnboarding(
        username: username,
        bio: bio.isEmpty ? null : bio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is OnboardingSubmitted) {
              context.go('/profile');
            } else if (state is OnboardingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is OnboardingSubmitting;
            return Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildProTipCard(),
                        const SizedBox(height: 24),
                        _buildUsernameSection(),
                        const SizedBox(height: 20),
                        _buildBioSection(),
                      ],
                    ),
                  ),
                ),
                _buildContinueButton(context, isSubmitting: isSubmitting),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.canPop() ? context.pop() : null,
            icon: const Icon(Icons.arrow_back, color: _primaryColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'IGNITION',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
              children: [
                TextSpan(
                  text: 'DRIVER ',
                  style: TextStyle(color: _labelColor),
                ),
                TextSpan(
                  text: 'PROFILE',
                  style: TextStyle(color: _primaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Configure your identity on the grid. This is\n'
            'how other drivers will see you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _mutedTextColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProTipCard() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: _primaryColor),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: _primaryColor, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRO TIP',
                            style: TextStyle(
                              color: _primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Your username acts as your unique '
                            'callsign. Keep it sharp. Bios that '
                            'include your current ride or dream '
                            'garage tend to get more traction.',
                            style: TextStyle(
                              color: Color(0xFF55565D),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              color: _labelColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
            children: [
              TextSpan(text: 'CALLSIGN '),
              TextSpan(
                text: '(USERNAME)',
                style: TextStyle(
                  color: _mutedTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(color: _primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _usernameError != null ? _primaryColor : _borderColor,
            ),
          ),
          child: TextField(
            controller: _usernameController,
            onChanged: (_) {
              if (_usernameError != null) {
                setState(() => _usernameError = null);
              }
            },
            style: const TextStyle(color: _labelColor, fontSize: 15),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.alternate_email,
                color: _mutedTextColor,
                size: 20,
              ),
              hintText: 'Enter your callsign',
              hintStyle: TextStyle(color: Color(0xFFB4B5BC), fontSize: 15),
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _usernameError ?? 'This will be your public handle.',
          style: TextStyle(
            color: _usernameError != null ? _primaryColor : _mutedTextColor,
            fontSize: 12,
            fontWeight: _usernameError != null
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              color: _labelColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
            children: [
              TextSpan(text: 'DRIVER BIO '),
              TextSpan(
                text: '(OPTIONAL)',
                style: TextStyle(
                  color: _mutedTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4, right: 8),
                child: Icon(
                  Icons.edit_note,
                  color: _mutedTextColor,
                  size: 22,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _bioController,
                  maxLines: 4,
                  minLines: 4,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(color: _labelColor, fontSize: 15),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText:
                        'Tell the grid about yourself, your '
                        'current ride, or your racing history...',
                    hintStyle: TextStyle(
                      color: Color(0xFFB4B5BC),
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(
    BuildContext context, {
    required bool isSubmitting,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : () => _onSubmit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            disabledBackgroundColor: _primaryColor.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: isSubmitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CONTINUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}
