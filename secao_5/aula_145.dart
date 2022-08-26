/* 
  145. Modo Paisagem

  A estrategia será escolher entre gráfico ou lista de transações

  Para isto, nós usamos um componente (classe) chamado Switch que irá receber
  um value e o onChanged que por sua vez irá receber o value e esta sendo
  envolvido em um setState pois cada vez que mudarmos de estados, ele precisa
  modificar
  Toda vez que o switch for chamado, ele irá chamar a classe Switch, e irá
  mudar o valor no value dentro do setState

  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("Exibir Gráfico"),
      Switch(
        value: _showChart,
        onChanged: (value) {
          setState(() {
            _showChart = value;
          });
        },
      ),
    ],
  ),

  E então podemos fazer uma operação ternaria, para caso verdadeiro exibir o gráfico
  senão não exibir.

  _showChart
  ? Container(
      height: availableHeight * 0.3,
      child: Chart(_recentTransactions),
    )
  : Container(
      height: availableHeight * 0.7,
      child: TransactionList(_transactions, _removeTransaction),
    ),

  Ao invés de fazer uma operação ternaria, nós podemos também fazer com IF, ficando
  da seguinte maneira:

  if (_showChart)
    Container(
      height: availableHeight * 0.3,
      child: Chart(_recentTransactions),
    ),
  if (!_showChart)
    Container(
      height: availableHeight * 0.7,
      child: TransactionList(_transactions, _removeTransaction),
    ),


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
    final appBar = AppBar(
      title: const Text(
        "Despesas Pessoais",
        style: TextStyle(
          fontSize: 20,
        ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Exibir Gráfico"),
                Switch(
                  value: _showChart,
                  onChanged: (value) {
                    setState(() {
                      _showChart = value;
                    });
                  },
                ),
              ],
            ),
            if (_showChart)
              Container(
                height: availableHeight * 0.3,
                child: Chart(_recentTransactions),
              ),
            if (!_showChart)
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
