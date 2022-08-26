/* 

  153. Detectando a Plataforma

  O Switch por padrão não é adaptativo, ou seja, ele é apenas para Material design
  e quando estamos trabalhando com iOS ele não é do padrão, para isto, nós podemos
  usar um construtor nomeado chamado "adaptative" e com isto, ele irá se adaptar
  indepedente da plataforma que estiver (Android / iOS)

  Switch.adaptive(
    ....
  )

  Outra coisa que podemos fazer é definir quando queremos exibir em uma plataforma 
  algo ou quando não queremos definir em uma plataforma, para isto, podemos inicialmente
  fazer uma verificação ternaria, para conseguir verificar isto.

  Temos que importar o 'dart:io' e então usar o Platform.isIOS e então fazemos a verificação
  ternaria que queremos.

  import 'dart:io';
  floatingActionButton: Platform.isIOS
        ? Container()
        : FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => _openTransactionFormModal(context),
          ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );

  Podemos fazer de ambas as maneiras, chamando um construtor "adaptative" para detectar
  automaticamente e fazer as configurações sozinho, como também fazermos isto através 
  da Plataforma (manualmente)

  

*/

import 'dart:math';
import 'dart:io';

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
  bool _showChart = false;

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
    final mediaQuery = MediaQuery.of(context);
    bool isLandscape = mediaQuery.orientation == Orientation.landscape;

    final appBar = AppBar(
      title: const Text(
        "Despesas Pessoais",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      actions: [
        if (isLandscape)
          IconButton(
            icon: Icon(
              _showChart ? Icons.list : Icons.pie_chart,
            ),
            onPressed: () {
              setState(() {
                _showChart = !_showChart;
              });
            },
          ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _openTransactionFormModal(context),
        ),
      ],
    );

    final availableHeight = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showChart || !isLandscape)
              Container(
                height: availableHeight * (isLandscape ? 0.8 : 0.3),
                child: Chart(_recentTransactions),
              ),
            if (!_showChart || !isLandscape)
              Container(
                height: availableHeight * (isLandscape ? 1 : 0.7),
                child: TransactionList(_transactions, _removeTransaction),
              ),
          ],
        ),
      ),
      floatingActionButton: Platform.isIOS
          ? Container()
          : FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _openTransactionFormModal(context),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
