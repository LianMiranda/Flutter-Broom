import 'package:broom_main_vscode/api/user.api.dart';
import 'package:broom_main_vscode/ui-components/icon_button.dart';
import 'package:broom_main_vscode/ui-components/modal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  Future<int?>? profileId;

  @override
  void initState() {
    profileId = autentication.getProfileId();
    super.initState();
  }

  void goToBankInfo(context) {
    GoRouter.of(context).push('/bank/information');
  }

  void goToFavorites(context) {
    GoRouter.of(context).push('/favorite-page');
  }

  void confirmLogout(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Modal(
            title: 'Deseja sair da sua sessão atual?',
            message:
                'Você será redirecionado para a tela principal, tem certeza disso?',
            click: () => GoRouter.of(context).push('/logout'),
            showOneButton: false,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Configurações',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF2ECC8F),
            leading: IconButton(
              onPressed: () {
                GoRouter.of(context).push('/List');
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 24,
                color: Colors.black,
              ),
            ),
          ),
          body: FutureBuilder(
            future: profileId,
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ButtonIcon(
                            btnText: 'Meus Favoritos',
                            btnIcon: Icons.favorite,
                            function: () => goToFavorites(context)),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              GoRouter.of(context).push('/meeting-page');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2ECC8F),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Meus Agendamentos',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  color: Colors.white,
                                  Icons.calendar_today_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (snapshot.data == 2)
                          ButtonIcon(
                            btnIcon: Icons.monetization_on_outlined,
                            btnText: 'Informações bancárias',
                            function: () => goToBankInfo(context),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        ButtonIcon(
                            btnText: 'Sair',
                            btnIcon: Icons.logout,
                            function: () => confirmLogout(context)),
                      ],
                    ),
                  ],
                ),
              );
            },
          )),
    );
  }
}
