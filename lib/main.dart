import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final formKey = GlobalKey<FormState>();
  final cnpj = TextEditingController();
  final cnpjSituacao = TextEditingController();
  final cnpjRazaoSocial = TextEditingController();
  final cnpjNomeFantasia = TextEditingController();
  final cnpjEndereco = TextEditingController();
  late String status;
  late String statusMessage;

  final pageTitle = 'Validador';
  final actionButton = 'Validar CNPJ';
  final actionButtonIcon = const Icon(Icons.check);
  final actionCpf = 'Deseja validar um CPF? Clique aqui.';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  validateCnpj(String cnpj) async {
    setState(() => loading = true);
    String uri = 'https://www.receitaws.com.br/v1/cnpj/$cnpj';
    final response = await http.get(Uri.parse(uri));
    setState(() {
      loading = false;
      if (response.statusCode == 429) {
        status = 'ERROR';
        statusMessage = 'Muitos requests. Por favor tente mais tarde.';
      } else if (response.statusCode == 404) {
        status = 'ERROR';
        statusMessage = 'CNPJ não encontrado.';
      } else {
        final json = jsonDecode(response.body);
        status = json['status'];
        if (status == 'OK') {
          cnpjSituacao.text = json['situacao'];
          cnpjRazaoSocial.text = json['nome'];
          cnpjNomeFantasia.text = json['fantasia'];
          cnpjEndereco.text = json['logradouro'] +
              ', ' +
              json['numero'] +
              ' - ' +
              json['bairro'] +
              ' - ' +
              json['municipio'] +
              ' - ' +
              json['uf'] +
              ', ' +
              json['cep'];
        } else {
          statusMessage = json['message'];
        }
      }
      if (status == 'ERROR') {
        cnpjSituacao.text = '';
        cnpjRazaoSocial.text = '';
        cnpjNomeFantasia.text = '';
        cnpjEndereco.text = '';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(statusMessage),
          backgroundColor: Colors.redAccent,
        ));
      }
    });
  }

  validateCpf() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(pageTitle),
            centerTitle: true,
          ),
          body: const WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl:
                'https://servicos.receita.fazenda.gov.br/Servicos/CPF/ConsultaSituacao/ConsultaPublica.asp',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Situação',
                      ),
                      controller: cnpjSituacao,
                      readOnly: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Razão Social',
                      ),
                      controller: cnpjRazaoSocial,
                      readOnly: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nome Fantasia',
                      ),
                      controller: cnpjNomeFantasia,
                      readOnly: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 96),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Endereço',
                      ),
                      controller: cnpjEndereco,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: TextFormField(
                        controller: cnpj,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'CNPJ',
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Informe o CNPJ corretamente!';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            validateCnpj(cnpj.text);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: (loading)
                              ? [
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ]
                              : [
                                  actionButtonIcon,
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      actionButton,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => validateCpf(),
                      child: Text(actionCpf),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
