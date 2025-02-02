import 'dart:io';
import 'package:broom_main_vscode/api/user.api.dart';
import 'package:broom_main_vscode/ui-components/user_image.dart';
import 'package:broom_main_vscode/user.dart';
import 'package:broom_main_vscode/user_yourself.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class EditUserForm extends StatefulWidget {
  final EditUser usersEdit;

  EditUserForm({required this.usersEdit});

  @override
  _EditUserFormState createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController cellphoneNumberController;
  late TextEditingController descriptionController;
  late TextEditingController valueWillingToPayController;
  String? serviceTypeSelected;
  String? favoriteDaytimeSelected;
  List<String>? zoneAtendimentSelected = [];
  String? stateAtendimentSelected;
  List<String>? specialtiesSelected = [];
  List<dynamic>? listSpecialties = [];
  List<dynamic>? listZones = [];
  List<dynamic>? listState = [];

  late String userActualImage;
  late bool? wantService;
  File? userImage;
  PlatformFile? _selectedFile;
  String _urlImagem = '';

  List<String> serviceType = [
    'Limpeza leve',
    'Limpeza média',
    'Limpeza pesada',
    'Lavar roupas',
    'Lavar louça',
    'Passar roupas',
    'Organização'
  ];

  List<String> daytimeType = ['Manhã', 'Tarde', 'Integral'];

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      PlatformFile file = result.files.first;
      print(
          "Arquivo selecionado: ${file.name}, Tamanho: ${file.size}, Tipo: ${file.extension}");

      if (file.path != null) {
        setState(() {
          userImage =
              File(file.path!); // Cria um objeto File a partir do caminho
          _selectedFile = file; // Armazena o arquivo selecionado
        });
        print("Arquivo foi carregado com sucesso.");
      } else {
        print("Erro: o caminho do arquivo é null.");
      }
    } else {
      print("Nenhum arquivo foi selecionado.");
    }
  }

  int? profileId;

  Future<Yourself?> fetchUserById() async {
    profileId = await autentication.getProfileId();
    return await getUserById();
  }

  Future<void> fetchSpecialties() async {
    listSpecialties = await fetchCustomDiaristProfileSpecialties();
  }

  Future<void> fetchActivityArea() async {
    listState = await fetchCustomDiaristProfileStates();
    listZones = await fetchCustomDiaristProfileZone();
  }
  
  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    cellphoneNumberController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.usersEdit.name);
    lastNameController = TextEditingController(text: widget.usersEdit.lastName);
    emailController = TextEditingController(text: widget.usersEdit.email);
    cellphoneNumberController = MaskedTextController(
        mask: '(00)0 0000-0000', text: widget.usersEdit.cellphoneNumber);
    descriptionController =
        TextEditingController(text: widget.usersEdit.description);
    valueWillingToPayController = TextEditingController(
        text: widget.usersEdit.valueWillingToPay?.toString() ?? '');

    serviceTypeSelected = widget.usersEdit.serviceType;
    favoriteDaytimeSelected = widget.usersEdit.favoriteDaytime;
    zoneAtendimentSelected = widget.usersEdit.regionAtendiment;
    stateAtendimentSelected = widget.usersEdit.stateAtendiment;
    specialtiesSelected = widget.usersEdit.specialties;

    wantService = widget.usersEdit.wantService ?? false;
    userActualImage = widget.usersEdit.userActualImage ?? '';
    fetchUserById().then((_) {
      setState(() {});
    });
    fetchSpecialties().then((_) {
      setState(() {});
    });
    fetchActivityArea().then((_) {
      setState(() {});
    });
  }


 Future<void> saveUser() async {
  if (_formKey.currentState!.validate()) {
    EditUser updatedUser = EditUser(
      name: nameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      cellphoneNumber: cellphoneNumberController.text.replaceAll(RegExp(r'[\(\)\s-]'), ''),
      description: descriptionController.text,
      wantService: wantService ?? false,
    );

    await updateUser(updatedUser.toJson());

      if (profileId == 1) {
        await sendCustomContractorProfile(
          serviceType: serviceTypeSelected,
          favoriteDaytime: favoriteDaytimeSelected,
          valueWillingToPay:
              double.tryParse(valueWillingToPayController.text) ?? 0.0,
        );
      } else if (profileId == 2) {
        specialtiesSelected!.forEach(
          (element) async {
            await sendCustomDiaristProfileSpecialties(specialties: element);
          },
        );
        zoneAtendimentSelected!.forEach(
          (element) async {
            await sendCustomDiaristProfileZone(regionAtendiment: element);
          },
        );
        await sendCustomDiaristProfileState(
            stateAtendiment: stateAtendimentSelected);
      }

     if (_selectedFile != null && _selectedFile!.path != null) {
      File selectedFile = File(_selectedFile!.path!);

      if (await selectedFile.exists()) {
        var imageResult = await sendImage(selectedFile);
        if (imageResult != "Sucesso") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imagem salva com sucesso!')),
          );
        }
      } else {
        print('Falha ao enviar: O arquivo não existe');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('O arquivo não existe.')),
        );
      }
    } else {
      print('Falha ao enviar: Nenhuma imagem foi selecionada');
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserYourself()),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edição de perfil',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF2ECC8F),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(children: [
                    GestureDetector(
                      onTap: () {
                        _pickImage();
                      },
                      child: _selectedFile != null
                          ? CircleAvatar(
                              radius: 50,
                               child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: userImage != null
                                            ? FileImage(userImage!)
                                            : _selectedFile != null
                                                ? MemoryImage(_selectedFile!.bytes!) 
                                                : AssetImage('assets/default_avatar.png'), 
                                        fit: BoxFit.cover,
                                       )),
                              ),
                              //  backgroundImage: FileImage(
                              // userImage!), // Exibe a imagem selecionada
                            )
                          : CircleAvatar(
                              radius: 50,
                              child: UserImage(
                                  user: ListUsers(
                                      id: -1,
                                      address: [],
                                      firstName: '',
                                      lastName: '',
                                      profileId: -1,
                                      userImage: userActualImage ?? '',
                                      wantService: false,
                                      isFavorite: false)),
                            ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: IconButton(
                          onPressed: () {
                            _pickImage();
                          },
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: Color(0xFF2ECC8F),
                          )),
                    )
                  ]),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o nome';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Sobrenome',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o sobrenome';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o e-mail';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: cellphoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Número de celular',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o número de celular';
                      }
                      return null;
                    },
                  ),
                  if (profileId == 1) ...[
                    SizedBox(height: 10),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: serviceTypeSelected,
                      decoration: InputDecoration(
                        labelText: 'Informe o serviço que está procurando',
                        border: OutlineInputBorder(),
                      ),
                      items: serviceType
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                            value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          serviceTypeSelected = value!;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: favoriteDaytimeSelected,
                      decoration: InputDecoration(
                        labelText: 'Informe o período de preferência',
                        border: OutlineInputBorder(),
                      ),
                      items: daytimeType.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          favoriteDaytimeSelected = value!;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: valueWillingToPayController,
                      decoration: InputDecoration(
                        labelText: 'Informe o valor que deseja pagar',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$',
                      ),
                    ),
                  ] else if (profileId == 2) ...[
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                        value: stateAtendimentSelected,
                        decoration: InputDecoration(
                          labelText: 'Informe o estado que você atua',
                          border: OutlineInputBorder(),
                        ),
                        items: listState!
                            .map<DropdownMenuItem<String>>((dynamic value) {
                          return DropdownMenuItem<String>(
                              value: value!['value'],
                              child: Text(value!['text']));
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            stateAtendimentSelected = value!;
                          });
                        }),
                    SizedBox(height: 10),
                    Text(
                      'Informe as suas regiões de atuação (máximo 3)',
                      style: TextStyle(fontSize: 16),
                    ),
                    Column(
                      children: listZones!.map((zone) {
                        return CheckboxListTile(
                          title: Text(zone['text'] ?? ''),
                          value:
                              zoneAtendimentSelected!.contains(zone['value']),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                if (zoneAtendimentSelected!.length < 4) {
                                  zoneAtendimentSelected?.add(zone['value']);
                                }
                              } else {
                                zoneAtendimentSelected?.remove(zone['value']);
                                deleteDataDiaristZone(zone['value']);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Informe as suas especialidades (máximo 4)',
                      style: TextStyle(fontSize: 16),
                    ),
                    Column(
                      children: listSpecialties!.map((specialty) {
                        return CheckboxListTile(
                          title: Text(specialty['text'] ?? ''),
                          value:
                              specialtiesSelected!.contains(specialty['value']),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                if (specialtiesSelected!.length < 4) {
                                  specialtiesSelected?.add(specialty['value']);
                                }
                              } else {
                                specialtiesSelected?.remove(specialty['value']);
                                deleteDataDiaristSpecialties(
                                    specialty['value']);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  SizedBox(height: 10),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a descrição';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Quer serviço?',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Switch(
                        activeColor: Color(0xFF2ECC8F),
                        value: wantService!,
                        onChanged: (bool? value) {
                          setState(() {
                            wantService = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await saveUser();
                          if (_selectedFile != null) {
                            await sendImage(File(_selectedFile!.path!));
                          }
                        } catch (e) {
                          print("Erro ao salvar ou enviar a imagem: $e");
                        }
                      },
                      child: Text('Salvar'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
