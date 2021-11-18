import 'package:flutter/material.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    // socketService.socket.emit(event)

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Server Status: ${socketService.serverStatus}')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        elevation: 1,
        onPressed: () {
          //TAREA

          socketService.emit('emitir-mensaje',
              {'nombre': 'Flutter', 'mensaje': 'Hola desde flutter'});
        },
      ),
    );
  }
}
