import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Guns N Roses', votes: 2),
    Band(id: '3', name: 'Apocalyptica', votes: 2),
    Band(id: '4', name: 'Iron Maiden', votes: 5),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('Bandas-Activas', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('Bnadas-Activas');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          _mostrarGrafica(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, i) => _bandTile(bands[i])),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
      background: Container(
          padding: EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete Band',
              style: TextStyle(color: Colors.white),
            ),
          )),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('New band name:'),
          content: TextField(
            controller: textController,
          ),
          actions: <Widget>[
            MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text))
          ],
        ),
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
          title: Text('New Band name:'),
          content: CupertinoTextField(controller: textController),
          actions: <Widget>[
            CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Add'),
                onPressed: () => addBandToList(textController.text)),
            CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Dismiss'),
                onPressed: () => Navigator.pop(context)),
          ]),
    );
  }

  void addBandToList(String name) {
    print(name);
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

//MOSTRAR GRAFICA
  Widget _mostrarGrafica() {
    Map<String, double> dataMap = new Map();
    // dataMap.putIfAbsent("Flutter", () => 5);
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.purple,
      Colors.blue,
      Colors.pink,
      Colors.green,
      Colors.yellow,
    ];
    return Container(
        width: double.infinity,
        height: 300,
        padding: EdgeInsets.all(20),
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 52,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.disc,
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            // legendShape: _BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: false,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: true,
            decimalPlaces: 0,
          ),
          // gradientList: ---To add gradient colors---
          // emptyColorGradient: ---Empty Color gradient---
        ));
  }
}
