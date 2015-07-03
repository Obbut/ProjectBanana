// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_rest/shelf_rest.dart';
import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart';

//import 'Persistence.dart';
import 'KAKU.dart' as KAKU;

void main(List<String> args) {
  Gpio.hardware = new RpiHardware();

  KAKU.NewRemoteTransmitter switcher = new KAKU.NewRemoteTransmitter(01001, Gpio.instance.pin(1, output), 260, 5);

  var parser = new ArgParser()
      ..addOption('port', abbr: 'p', defaultsTo: '8080');

  var result = parser.parse(args);

  var port = int.parse(result['port'], onError: (val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });

//  Persistence p = new Persistence();
//  p.init();

  Router restAPI = router()
    ..get("/api/token/revoke/{token}", (String token) => token)
    ..get("/switch/unit/{unit}/on", (int unit) => switcher.sendUnit(unit, true))
    ..get("/switch/unit/{unit}/off", (int unit) => switcher.sendUnit(unit, false))
    ..get("/switch/group/on", () => switcher.sendGroup(true))
    ..get("/switch/group/off", () => switcher.sendGroup(false));

  io.serve(restAPI.handler, '0.0.0.0', port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}

shelf.Response _echoRequest(shelf.Request request) {
  return new shelf.Response.ok('Request for "${request.url}"');
}
