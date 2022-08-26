/* 

  150. Aproveitando larguras maiores

  Nós podemos fazer condicionacios que dizem respeito a largura do dispositivo
  (dependendo da orientação a orientação irá aumentar ou diminuir)

  Não iremos fazer a checagem em relacão a orientacão (vertifical ou horizontal)
  e sim em relacão ao espaço que temos disponível

  Para isto nós podemos usar o MediaQuery que irá pegar o tamanho do width
    MediaQuery.of(context).size.width
  
  Aqui conseguimos descobrir o tamanho do width, então faremos uma verificação
  ternaria para, caso maior do que definido, exiba um buttom, caso contrário, um icon
  ficando assim:

  trailing: MediaQuery.of(context).size.width > 400
  ? TextButton.icon(
      onPressed: () => onRemove(tr.id),
      icon: const Icon(Icons.delete),
      label: const Text('Excluir'),
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(
            Theme.of(context).errorColor),
      ),
    )
  : IconButton(
      onPressed: () => onRemove(tr.id),
      icon: Icon(Icons.delete),
      color: Theme.of(context).errorColor,
    ),
  ),

  Assim podemos fazer verificações usando o tamanho que temos, se for maior que X tamanho, faz
  uma ação, senão faz outra ação

  A diferença é que neste caso, nós temos mais espaço e vamos mostrando mais coisas, já no outro
  caso nós temos menos espaço e vamos tirando as coisas e diminuindo tudo que temos na tela.



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
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

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

    final availableHeight = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _openTransactionFormModal(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
