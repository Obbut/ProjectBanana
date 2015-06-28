library KAKU;

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart';
import 'dart:io';

// Translated from the NewRemoteSwitch library v1.2.0 made by Randy Simons (http://randysimons.nl)
// https://bitbucket.org/fuzzillogic/433mhzforarduino/src/0847a6d8a9173abd5abf9cf571a1539f56588c0e/NewRemoteSwitch/NewRemoteTransmitter.cpp?at=default
// License: GPLv3


class NewRemoteTransmitter {

  int _address, _repeats;
  Pin _pin;
  Duration _periodusec;

  NewRemoteTransmitter(this._address, this._pin, int periodusec, int repeats) {
    _repeats = (1 << repeats) - 1; // I.e. _repeats = 2^repeats - 1
    _periodusec = new Duration(microseconds: periodusec);
  }

//  NewRemoteTransmitter(int address, Pin pin, int periodusec, int repeats) :
//  _address = address, _pin = pin {
//    _repeats = (1 << repeats) - 1; // I.e. _repeats = 2^repeats - 1
//    _periodusec = new Duration(microseconds: periodusec);
//  }

  sendGroup(bool switchOn) {
    for (int i = _repeats; i >= 0; i--) {
      _sendStartPulse();

      _sendAddress();

      // Do send group bit
      _sendBit(true);

      // Switch on | off
      _sendBit(switchOn);

      // No unit. Is this actually ignored?..
      _sendUnit(0);

      _sendStopPulse();
    }
  }

  sendUnit(int unit, bool switchOn) {
    for (int i = _repeats; i >= 0; i--) {
      _sendStartPulse();

      _sendAddress();

      // No group bit
      _sendBit(false);

      // Switch on | off
      _sendBit(switchOn);

      _sendUnit(unit);

      _sendStopPulse();
    }
  }

  sendDim(int unit, int dimLevel) {
    for (int i = _repeats; i >= 0; i--) {
      _sendStartPulse();

      _sendAddress();

      // No group bit
      _sendBit(true);

      // Switch type 'dim'
      _pin.value = 1;
      sleep(_periodusec);
      _pin.value = 0;
      sleep(_periodusec);
      _pin.value = 1;
      sleep(_periodusec);
      _pin.value = 0;
      sleep(_periodusec);

      _sendUnit(unit);

      for (int j = 3; j >= 0; j--) {
        _sendBit(dimLevel & 1<<j);
      }

      _sendStopPulse();
    }
  }

  sendGroupDim(int dimLevel) {
    for (int i = _repeats; i >= 0; i--) {
      _sendStartPulse();

      _sendAddress();

      // No group bit
      _sendBit(true);

      // Switch type 'dim'
      _pin.value = 1;
      sleep(_periodusec);
      _pin.value = 0;
      sleep(_periodusec);
      _pin.value = 1;
      sleep(_periodusec);
      _pin.value = 0;
      sleep(_periodusec);

      _sendUnit(0);

      for (int j = 3; j >= 0; j--) {
        _sendBit(dimLevel & 1<<j);
      }

      _sendStopPulse();
    }
  }

  _sendStartPulse() {
    _pin.value = 1;
    sleep(_periodusec);
    _pin.value = 0;
    sleep(_periodusec * 10 + new Duration(microseconds: (_periodusec.inMicroseconds >> 1)));
  }

  _sendAddress() {
    for (int i = 25; i >= 0; i--) {
      _sendBit((_address >> i) & i);
    }
  }

  _sendUnit(int unit) {
    for (int i = 3; i >= 0; i--) {
      _sendBit(unit & 1<<i);
    }
  }

  _sendStopPulse() {
    _pin.value = 1;
    sleep(_periodusec);
    _pin.value = 0;
    sleep(_periodusec * 40);
  }

  _sendBit(bool isBitOne) {
    if (isBitOne) {
      // Send '1'
      _pin.value = 1;
      sleep(_periodusec);
      _pin.value = 0;
      sleep(_periodusec * 5);
      _pin.value = 1;
      sleep(_periodusec);
      _pin.value = 0;
      sleep(_periodusec);
    } else {
      // Send '0'
      _pin.value = 1;
      sleep(_periodusec);
      _pin.value = 0;
      sleep(_periodusec);
      _pin.value = 1;
      sleep(_periodusec);
      _pin.value = 0;
      sleep(_periodusec * 5);
    }
  }
}