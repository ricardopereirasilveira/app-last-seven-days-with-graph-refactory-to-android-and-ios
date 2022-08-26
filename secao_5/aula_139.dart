/* 
  139. O que é responsividade?

  Por diversas vezes, a mesma aplicação é apresentada em diversas telas diferentes 

  Uma das primeiras coisas que podemos fazer (caso desejamos) é bloquear algum tipo de orientação
  (paisagem ou retrato) o flutter suporta bloquear qualquer orientação

  Ter uma aplicação responsiva é trabalhar com diversos tamanhos (retrato, paisagem, tablet, desktop, TV, etc...)
  de uma forma que ela irá preencher os espaços necessários de acordo com o tamanho da tela que irá rodar a
  aplicação

  Além da tela responsiva, nós vamos querer também que ela considere os diversos tipo de sistemas operacionais
  (Android, iOS, Windows, etc...)

  Considerando Android e iOS
  Android:
    - Tema Material-Design
    - Animações/Transições no Android
    - Fontes Android
  
  iOS:
    - Tema Cupertino
    - Animações/Transições no iOS
    - Fonte iOS

  Pois cada sistema operacão tem sua maneira de pensar o UI de uma forma diferente, então podemos pensar em ter
  mesmo de uma mesma aplicação caracteristicas especificas para cada sistema operacional, sendo assim, ao selecionar
  a data por exemplo, no Android selecionamos de uma maneira, no iOS selecionamos de outra maneira

  Um projeto (código) ---> Uma árvore de Componente ---> Diferentes Ramos (if Plataform.isISO) --->
    sub-árvore iOS (Widgets) / sub-árvore Android (Widgets)

  Nós iremos ter apenas um código, mas seremos capazes de desenvolver conteudos exclusivos para Android e iOS, isto
  com apenas um código, mas a árvore de componente será especifica para cada plataforma, criamos diferentes ramos
  dentro da árvore de componente.
  Tudo começa no componente raiz da aplicação, em seguida colocamos uma appBar, depois colocamos o body com um Scaffold
  e iremos montando os widgets e a partir do momento que temos necessidades diferentes a partir de sistemas
  operacionais temos diferentes ramos (condicionais) que irão jogar para cada compente especifico do seu sistema
  operacional para podermos customizar especificamente para cada sistema operacional (seja do ponto de vista de tela
  seja do ponto de vista de sistema operacional )

  Mesmo que a gente tenha tamanhos e sistemas operacionais diferentes, a lógica continua a mesma, tudo continua da mesma
  maneira, então muito código é igual, a parte exclusiva da personalização é que irá mudar, teremos potencialmente
  90% da aplicação igual, e os outros 10% customizados especificamente para cada sistema operacional 


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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Despesas Pessoais",
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _openTransactionFormModal(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Chart(_recentTransactions),
          TransactionList(_transactions, _removeTransaction),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _openTransactionFormModal(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
