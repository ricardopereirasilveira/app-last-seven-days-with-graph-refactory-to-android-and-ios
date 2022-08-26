/* 

  155. Componentes iOS

  Na próxima aula, faremos algumas correções por conta das atualizações do Flutter 2. 
  A primeira delas se trata da refatoração da AppBar, o PreferredSizeWidget não funciona 
  mais com a CupertinoNavigationBar, então é necessário deixar essa parte do código lá no 
  local dela mesmo, ao invés de refatorar como na aula. Ficará assim:

  return Platform.isIOS
  ? CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Despesas Pessoais'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        ),
      ),
      child: bodyPage,
    )
  A outra correção se trata da refatoração dos botões. 
  Uma pequena mudança vai ser necessária da definição da função de refatoração. 
  Será necessário adicionar () na Function que é parâmetro. Deixando o código assim:

  Widget _getIconButton(IconData icon, Function() fn) {
    return Platform.isIOS
        ? GestureDetector(onTap: fn, child: Icon(icon))
        : IconButton(icon: Icon(icon), onPressed: fn);
  }


  Iremos modificar tudo de Android para iOS quando estivermos acessando o iOS

  Consultando documentação: Docs -> Widgets Catalog -> Cupertino (iOS-style Widgets)

  Tudo começa no scaffold (que é Android), nós podemos colocar a do iOS também
  para quando acessar via iOS a gente ver as informacões do iOS

  Todas as vezes que importamos o Cupertino, ele automaticamente irá importar
  o material do cupertino:
  import 'package:flutter/cupertino.dart';

  OBS: Existe uma certa incosistência nos nomes dos atributos nomeados, por exemplo
  enquanto no CupertinoPageScaffold nós temos o atributo nomeado "child" no Scaffold
  nós temos o atributo nomeado chamado "body", eles servem para a mesma coisa.

  A primeira coisa que fizemos é colocar tudo que esta dentro do SingleChildScrollView
  em uma variavel a parte e usar ela em ambos os sitemas operacionais ()

  no Cupertino o appBar é chamado de navigationBar

  Outra diferença de atributo nomeado é que no navigation bar nós temos o Middle(que
  corresponde ao body), enquanto o trailing corresponde ao Actions.
  Porém o trailing corresponde a apenas 1 widgets, então temos que envolver ele dentro 
  de uma Row.

  o IconButton não está disponível no Cupertino, ele está disponível apenas no
  Material Design

  Então para isto criamos um método que irá ajudar a criar um botão
  No Caso do Android é um IconButton e no caso do iOS é um GestureDetector

  
  Então nós chamos a getIconButton passando os 2 parametros (o icone do Botão e a função
  de retorno)
  
  dentro da Row (que está dentro do CupertinoNavigationBar) nós temos um atributo
  nomeado chamado "mainAxisSize" que por sua vez recebe um "MainAxisSize.min"
  ou seja, ele irá pegar exatamente o tamanho do elemento, e não irá usar nada além disso.


  Usando Icones de acordo com a plataforma, para isto, nós dentro do _getIconButton
  podemos fazer uma verificação e então caso a plataforma seja iOS passar um botão
  caso seja Android, passar outro botão, ficando assim:
    Platform.isIOS ? CupertinoIcons.add : Icons.add

  OBS: Dentro do iOS nós temos algumas áreas como por exemplo o Not (área preta onde 
  fica o alto falante) e também temos a área inferior onde "fechamos" as aplicações
  que também não deve ser usada, para os usuários usaremos os gestos ou algo do tipo

  

*/

import 'dart:math';
import 'dart:io';

import 'package:expenses/components/chart.dart';
import 'package:expenses/components/transaction_list.dart';
import 'package:expenses/components/transacton_form.dart';
import 'package:expenses/models/transaction.dart';
import 'package:flutter/cupertino.dart';
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

  Widget _getIconButton(IconData icon, Function() fn) {
    return Platform.isIOS
        ? GestureDetector(onTap: fn, child: Icon(icon))
        : IconButton(icon: Icon(icon), onPressed: fn);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    bool isLandscape = mediaQuery.orientation == Orientation.landscape;

    final actions = [
      if (isLandscape)
        _getIconButton(
          _showChart ? Icons.list : Icons.pie_chart,
          () {
            setState(() {
              _showChart = !_showChart;
            });
          },
        ),
      _getIconButton(
        Platform.isIOS ? CupertinoIcons.add : Icons.add,
        () => _openTransactionFormModal(context),
      ),
    ];

    final appBar = AppBar(
      title: const Text(
        "Despesas Pessoais",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      actions: actions,
    );

    final availableHeight = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    final bodyPage = SingleChildScrollView(
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
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text('Despesas Pessoais'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions,
              ),
            ),
            child: bodyPage,
          )
        : Scaffold(
            appBar: appBar,
            body: bodyPage,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _openTransactionFormModal(context),
                  ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
