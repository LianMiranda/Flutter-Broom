import 'dart:typed_data';

import 'package:broom_main_vscode/api/user.api.dart';
import 'package:broom_main_vscode/user.dart';
import 'package:broom_main_vscode/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:broom_main_vscode/ui-components/user_image.dart';
import 'package:broom_main_vscode/user_view.dart';

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    final String token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImxpYW5taXJhbmRhMjZAZ21haWwuY29tIiwiaWQiOjEsImlhdCI6MTcyNjA5NjY2NSwiZXhwIjoxNzI2MTExMDY1LCJpc3MiOiJsb2dpbiIsInN1YiI6IjEifQ.79PLGjF55TpD0RIRtthvfmrrBuyCNa4NAOzoUZh2x64';

    UserProvider userProvider = UserProvider.of(context) as UserProvider;
    List<User> users = userProvider.users;
    int usersLength = users.length;

    List<Address> address = [];
    void addAddressForUser(ListUsers user) {
      if (user.address.length > 0)
        address.add(Address.fromJson(user.address[0]));
      else
        address.add(Address(
            state: '',
            city: '',
            neighborhood: '',
            addressType: '',
            street: ''));
    }

    String getListUserFormatedAddress(Address userAddress) {
      if (userAddress.state == '' ||
          userAddress.neighborhood == '' ||
          userAddress.city == '') return '';

      return '${userAddress.neighborhood} - ${userAddress.city!}, ${userAddress.state!}';
    }

    String getListUserFullName(ListUsers user) {
      return '${user.firstName} ${user.lastName}';
    }

    return Scaffold(
      backgroundColor: Color(0xFF2ECC8F),
      appBar: AppBar(
        title: Text('User List'),
        elevation: 0,
        backgroundColor: Color(0xFF2ECC8F),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<List<ListUsers>>(
        future: fetchUsuarios(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.data);
            print(snapshot.hasError);
            return Center(child: Text('Erro ao carregar usuários'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum usuário encontrado'));
          } else {
            List<ListUsers> usuarios = snapshot.data!;
            return ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                ListUsers usuario = usuarios[index];
                addAddressForUser(usuario);

                return ListTile(
                  titleTextStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                  subtitleTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      decorationColor: Colors.white,
                      decoration: TextDecoration.overline),
                  leading: UserImage(user: usuario, token: token),
                  title: Text(getListUserFullName(usuario)),
                  subtitle: Text(getListUserFormatedAddress(address[index])),
                  onTap: () {
                    print(index);
                    print(usuario.id);
                    print(usuario.wantService);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserView(usuario: usuario),
                      ),
                    );
                    //_showUserDetails(context, usuario);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
/*
void _showUserDetails(BuildContext context, ListUsers usuario) {
  String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImxpYW5taXJhbmRhMjZAZ21haWwuY29tIiwiaWQiOjEsImlhdCI6MTcyNjA5NjY2NSwiZXhwIjoxNzI2MTExMDY1LCJpc3MiOiJsb2dpbiIsInN1YiI6IjEifQ.79PLGjF55TpD0RIRtthvfmrrBuyCNa4NAOzoUZh2x64";
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(20),
        content: Container(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                child:UserImage(user: usuario, token: token)
              ),
              SizedBox(height: 10),
              Text(
                '${usuario.firstName} ${usuario.lastName} \n ${usuario.wantService} \n ${usuario.address}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: () =>{} , child: Text('Vini gay'))
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o pop-up
            },
            child: Text('Fechar'),
          ),
        ],
      );
    },
  );
}
*/