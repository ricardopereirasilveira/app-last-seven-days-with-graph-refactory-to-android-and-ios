/* 
  141. Calculando tamanho Dinamicamente 

  Iremos pegar o MediaQuery para pegar o tamanho do disposítivo (largura)
  * OBS: A altura é um pouco mais complicada que a largura

  Assim como em outro componente, nós podemos usar o .of(context) para mostrar
  para a aplicação em qual componente ele está, assim a aplicação sabe exatamente
  o componente que ela está pois um componente filho consegue acessar um 
  componente do pai e assim consegue acessar um componente da árvore de elementos


  height: MediaQuery.of(context).size.height * 0.6,

  usando o médiaQuery nós podemos acessar o tamanho do dispositivo, enviando o context
  para saber o tamanho do componente, e inferindo o valor de 0.5 nós vamos pegar exatamente
  metade da tela ( se usar 1 = tela inteira, se usar 0 = absolutamente nada da tela)

  No nosso caso, como estamos usando 60% (0.6) no height do TransactionList, nós podemos
  colocar que vamos usar 40% (0.4) no Char, pois no main.dart dentro de body temos
  ambos os componente sendo renderizados nesta tela, porém, não podemos esquecer de considerar
  a appBar e o statusBar, pois eles também contam na renderizacão da tela, pois o container
  está pegando dentro do componente, então ele está ignorando todos os fatores antes (pai) e
  focando exclusivamente no componente filho e tentando, a partir da tela toda, pegar o 
  componente e fazer 100% descosiderando todo o resto

  Como primeiro ajuste, iremos ajustar a tela a partir do main.dart, criando uma variavel
  que irá medir (erroneamente) o tamanho da tela (considerando appBar e statusBar), e então
  a partir dali, criar um container que irá envolver os dois componentes que irão ser chamados
  nesta tela e definir o tamanho da altura direto nesse container, ficando assim

  final availableHeight = MediaQuery.of(context).size.height;
  Container(
    height: availableHeight * 0.4,
    child: Chart(_recentTransactions),
  ),
  Container(
    height: availableHeight * 0.6,
    child: TransactionList(_transactions, _removeTransaction),
  ),

  porém ainda dara erro, uma vez que desconsiderou appBar e statusBar.

  Para iniciar a remoção do tamanho da appBar, vamos tirar a appBar da aplicação central (builder)
  e colocar ele em uma parte separada através de uma variavel, ficando assim

  final appBar = AppBar(
    title: const Text(
      "Despesas Pessoais",
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.add),
        onPressed: () => _openTransactionFormModal(context),
      ),
    ],
  );

  a partir dai, nós vamos, dentro da variavel "availableHeight" desconsiderar o tamanho da appBar, pois
  o componente tem um chamada "preferredSize" que pode retornar o tamanho dela, sendo assim, podemso excluir ela
  através da variavel availableHeight, ficando assim:

  final availableHeight =
    MediaQuery.of(context).size.height - appBar.preferredSize.height;
  
  assim nós iremos nos aproximar dos 100% da tela (porém ainda existe diferença)

  E o statusBar nós pegamos exatamente através do MediaQuery também, que tem um método estático chamado "padding"
  que por sua vez tem um padrão nomeado chamado "top", então ficando assim


  final availableHeight = MediaQuery.of(context).size.height -
    appBar.preferredSize.height -
    MediaQuery.of(context).padding.top;
  
  Com isto, a nossa aplicação não irá precisar mexer mais, pois ela tem 100% da tela já, removendo o 
  appBar e o statusBar, através da availableHeight que foi criada

  Com isto, é so ir fazendo conforme o tamanho da tela/componentes, até dar 100% da tela, removendo tudo que
  for necessário e ficando do tamanho exato da tela, caso sua aplicação peça isso.
*/

import 'dart:math';

import 'package:expenses/components/chart.dart';
import 'package:expenses/components/transaction_list.dart';
import 'package:expenses/components/transacton_form.dart';
import 'package:expenses/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

main() => runApp(const ExpensesApp());

class ExpensesApp extends StatelessWidget {
  const ExpensesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
        fontFamily: 'Quicksand',
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [];

  List<Transaction> get _recentTransactions {
    return _transactions.where((element) {
      return element.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return TransactionForm(_addTransaction);
        });
  }

  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );

    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere(
        (element) {
          return element.id == id;
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text(
        "Despesas Pessoais",
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _openTransactionFormModal(context),
        ),
      ],
    );

    final availableHeight = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: availableHeight * 0.3,
              child: Chart(_recentTransactions),
            ),
            Container(
              height: availableHeight * 0.7,
              child: TransactionList(_transactions, _removeTransaction),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _openTransactionFormModal(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
