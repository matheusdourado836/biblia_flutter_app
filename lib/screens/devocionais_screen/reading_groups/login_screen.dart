import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/register_user_modal.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/reset_email_sent_dialog.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/reset_pass_modal.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/user_provider.dart';

class LoginScreen extends StatefulWidget {
  final EventBus? eventBus;
  const LoginScreen({super.key, this.eventBus});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _loading = false;
  bool _hidePass = true;
  String _errorMsg = '';

  Widget _loadingWidget() => const SizedBox(
    height: 35,
    width: 35,
    child: CircularProgressIndicator(),
  );

  Future<void> doLogin() async {
    try {
      setState(() => _loading = true);
      final readingGroupProvider = Provider.of<UserProvider>(context, listen: false);
      await readingGroupProvider.doLogin(email: _emailController.text.trim(), pass: _passController.text.trim());
      setState(() => _loading = false);
      widget.eventBus?.fire('Refresh');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'user_home_screen');
    }on FirebaseAuthException catch(e) {
      setState(() {
        _loading = false;
        _errorMsg = e.translated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Form(
        key: _key,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                    colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: .3), BlendMode.darken),
                    alignment: Alignment.topCenter,
                    image: const AssetImage('assets/images/group.jpg'),
                  )
              ),
              alignment: Alignment.topCenter,
            ),
            Container(
              height: MediaQuery.sizeOf(context).height * .74,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadiusDirectional.horizontal(
                  start: Radius.circular(30),
                  end: Radius.circular(30)
                )
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Entre com sua conta',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if(value?.isEmpty ?? true) {
                              return 'Este campo é obrigatório';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Digite seu email aqui...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.onSurface), borderRadius: const BorderRadius.all(Radius.circular(10))),
                            errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(10))),
                            focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(10))),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.onSurface, strokeAlign: 10), borderRadius: const BorderRadius.all(Radius.circular(10))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Senha', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passController,
                          obscureText: _hidePass,
                          validator: (value) {
                            if(value?.isEmpty ?? true) {
                              return 'Este campo é obrigatório';
                            }
                            if(value!.length < 6) {
                              return 'A senha deve ter pelo menos 6 dígitos.';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: '********',
                            filled: true,
                            suffixIcon: IconButton(
                                onPressed: () => setState(() => _hidePass = !_hidePass),
                                icon: (_hidePass) ? const Icon(CupertinoIcons.eye) : const Icon(CupertinoIcons.eye_slash)
                            ),
                            hintStyle: const TextStyle(color: Colors.grey),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.onSurface), borderRadius: const BorderRadius.all(Radius.circular(10))),
                            errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(10))),
                            focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(10))),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.onSurface, strokeAlign: 10), borderRadius: const BorderRadius.all(Radius.circular(10))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if(_errorMsg.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                          _errorMsg,
                          textAlign: TextAlign.left,
                          style: const TextStyle(color: Colors.red)
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          useSafeArea: true,
                          showDragHandle: true,
                          builder: (contet) => const ResetPassModal()
                        ).then((res) {
                          if (!context.mounted) return;
                          if(res is String) {
                            showDialog(
                                context: context,
                                builder: (context) => ResetEmailSentDialog(email: res)
                            );
                          }
                        }),
                        child: const Text('Esqueci minha senha')
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: (_loading) ? _loadingWidget() : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(500, 40),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if(_key.currentState?.validate() ?? false) {
                            doLogin();
                          }
                        },
                        child: const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: InkWell(
                        onTap: () => showModalBottomSheet(
                          isScrollControlled: true,
                          useSafeArea: true,
                          context: context,
                          builder: (context) => const RegisterUserModal()
                        ).then((res) {
                          if(res is String) {
                            _emailController.text = res;
                            showCustomSnackBar(child: Text('Usuário criado com sucesso!'));
                          }
                        }),
                        child: const Text.rich(
                          style: TextStyle(fontSize: 12),
                          TextSpan(
                            text: 'Não tem uma conta? ',
                            children: [
                              TextSpan(
                                text: 'Crie uma aqui',
                                style: TextStyle(fontWeight: FontWeight.bold)
                              )
                            ]
                          )
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 50,
              left: 30,
              child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.adaptive.arrow_back, color: Colors.white, size: 32,)
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }
}
