import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_beacon_example/controller/requirement_state_controller.dart';
import 'package:get/get.dart';

class TabScanning extends StatefulWidget {
  @override
  _TabScanningState createState() => _TabScanningState();
}

class _TabScanningState extends State<TabScanning> {
  StreamSubscription<RangingResult> _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  final controller = Get.find<RequirementStateController>();

  @override
  void initState() {
    super.initState();

    controller.startStream.listen((flag) {
      if (flag == true) {
        initScanBeacon();
      }
    });

    controller.pauseStream.listen((flag) {
      if (flag == true) {
        pauseScanBeacon();
      }
    });
  }

  initScanBeacon() async {
    await flutterBeacon.initializeScanning;
    if (!controller.authorizationStatusOk ||
        !controller.locationServiceEnabled ||
        !controller.bluetoothEnabled) {
      print(
          'RETURNED, authorizationStatusOk=${controller.authorizationStatusOk}, '
          'locationServiceEnabled=${controller.locationServiceEnabled}, '
          'bluetoothEnabled=${controller.bluetoothEnabled}');
      return;
    }
    final regions = <Region>[
      Region(
        identifier: 'BeaconX',
        //proximityUUID: 'CB10023F-A318-3394-4199-A8730C7C1AEC',
      ),
    ];

    if (_streamRanging != null) {
      if (_streamRanging.isPaused) {
        _streamRanging.resume();
        return;
      }
    }

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
      print('RESULT = $result');
      print('BEACONS = ${result.beacons}');
      if (result != null && mounted) {
        setState(() {
          _regionBeacons[result.region] = result.beacons;
          // if (_beacons.isNotEmpty) {
          //   if (_beacons.length == result.beacons.length) {
          //     for (int i = 0; i <= result.beacons.length; i++) {
          //       if (result.beacons[i].macAddress != _beacons[i].macAddress)
          //         _beacons.clear();
          //       break;
          //     }
          //   } else
          //     _beacons.clear();
          // }
          //  else
          _beacons.clear();
          _regionBeacons.values.forEach((list) {
            _beacons.addAll(list);
          });
          //_beacons.sort(_compareParameters);
        });
      }
    });
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      setState(() {
        _beacons.clear();
      });
    }
  }

  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);

    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }

    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }

    return compare;
  }

  @override
  void dispose() {
    _streamRanging?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _beacons == null || _beacons.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: ListTile.divideTiles(
                context: context,
                color: Colors.grey,
                tiles: _beacons.map(
                  (beacon) {
                    if (beacon.beaconTypeCode.toString() == '0') //'0x00' = '0'
                      return Column(
                        children: [
                          Text(
                            'This is a Eddystone_UID frame',
                            style: TextStyle(fontSize: 15.0),
                          ),
                          Text(
                            beacon.macAddress,
                            style: TextStyle(fontSize: 15.0),
                          ),
                          Text(
                            beacon.namespaceId,
                            style: TextStyle(fontSize: 15.0),
                          ),
                          ListTile(
                            title: Text(
                              beacon.instanceId,
                              style: TextStyle(fontSize: 15.0),
                            ),
                            subtitle: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    'Accuracy: ${beacon.accuracy} m\nRSSI: ${beacon.rssi} dBm',
                                    style: TextStyle(fontSize: 13.0),
                                  ),
                                  flex: 2,
                                  fit: FlexFit.tight,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Tx Power: ${beacon.txPower}',
                            style: TextStyle(fontSize: 13.0),
                          ),
                          Text(
                            'Proximity: ${beacon.proximity.toString()}',
                            style: TextStyle(fontSize: 13.0),
                          ),
                          beacon.telemetryVersion != null
                              ? Text(
                                  'telemetryVersion: ${beacon.telemetryVersion}',
                                  style: TextStyle(fontSize: 13.0),
                                )
                              : Container(), //null,
                          beacon.batteryMilliVolts != null
                              ? Text(
                                  'batteryLevel: ${beacon.batteryMilliVolts} mV',
                                  style: TextStyle(fontSize: 13.0),
                                )
                              : Container(), //null,
                          beacon.pduCount != null
                              ? Text(
                                  'pduCount: ${beacon.pduCount} advertisements',
                                  style: TextStyle(fontSize: 13.0),
                                )
                              : Container(), //null,
                          beacon.uptime != null
                              ? Text(
                                  'uptime: ${beacon.uptime} seconds',
                                  style: TextStyle(fontSize: 13.0),
                                )
                              : Container(), //null,
                          beacon.temperature != null
                              ? Text(
                                  'temperature: ${beacon.temperature} °C',
                                  style: TextStyle(fontSize: 13.0),
                                )
                              : Container(), //null,
                        ],
                      );
                    else if (beacon.beaconTypeCode.toString() ==
                        '16') //'0x10' = '16'
                      return Column(
                        children: [
                          Text(
                            'This is a Eddystone_URL frame',
                            style: TextStyle(fontSize: 15.0),
                          ),
                          Text(
                            beacon.macAddress,
                            style: TextStyle(fontSize: 15.0),
                          ),
                          ListTile(
                            title: Text(
                              beacon.url,
                              style: TextStyle(fontSize: 15.0),
                            ),
                            subtitle: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    'Accuracy: ${beacon.accuracy} m\nRSSI: ${beacon.rssi} dBm',
                                    style: TextStyle(fontSize: 13.0),
                                  ),
                                  flex: 2,
                                  fit: FlexFit.tight,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Tx Power: ${beacon.txPower}',
                            style: TextStyle(fontSize: 13.0),
                          ),
                          Text(
                            'Proximity: ${beacon.proximity.toString()}',
                            style: TextStyle(fontSize: 13.0),
                          ),
                          beacon.telemetryVersion != null
                              ? Text(
                                  'telemetryVersion: ${beacon.telemetryVersion}',
                                  style: TextStyle(fontSize: 13.0),
                                )
                              : Container(), //null,
                          beacon.batteryMilliVolts != null
                              ? Text(
                                  'batteryLevel: ${beacon.batteryMilliVolts} mV',
                                  style: TextStyle(fontSize: 13.0),
                                )
                              : Container(), //null,
                          beacon.pduCount != null
                              ? Text(
                                  'pduCount: ${beacon.pduCount} advertisements',
                                  style: TextStyle(fontSize: 13.0),
                                )
                              : Container(), //null,
                          beacon.uptime != null
                              ? Text(
                                  'uptime: ${beacon.uptime} seconds',
                                  style: TextStyle(fontSize: 13.0),
                                )
                              : Container(), //null,
                          beacon.temperature != null
                              ? Text(
                                  'temperature: ${beacon.temperature} °C',
                                  style: TextStyle(fontSize: 13.0),
                                )
                              : Container(), //null,
                        ],
                      );
                    else if (beacon.beaconTypeCode.toString() ==
                        '32') //'0x20' = '32' This is a Eddystone_TLM frame
                      return Column(
                        children: [
                          Text(
                            'This is a Eddystone_TLM frame',
                            style: TextStyle(fontSize: 15.0),
                          ),
                          // Text(
                          //   beacon.macAddress,
                          //   style: TextStyle(fontSize: 15.0),
                          // ),
                        ],
                      );
                    else if (beacon.beaconTypeCode.toString() ==
                        '48') //'0x30' = '48' This is a Eddystone_EID frame
                      return Column(
                        children: [
                          Text(
                            'This is a Eddystone_EID frame',
                            style: TextStyle(fontSize: 15.0),
                          ),
                          Text(
                            beacon.macAddress,
                            style: TextStyle(fontSize: 15.0),
                          ),
                          ListTile(
                            title: Text(
                              beacon.ephemeralId,
                              style: TextStyle(fontSize: 15.0),
                            ),
                            subtitle: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    'Accuracy: ${beacon.accuracy} m\nRSSI: ${beacon.rssi} dBm',
                                    style: TextStyle(fontSize: 13.0),
                                  ),
                                  flex: 2,
                                  fit: FlexFit.tight,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Tx Power: ${beacon.txPower}',
                            style: TextStyle(fontSize: 13.0),
                          ),
                          Text(
                            'Proximity: ${beacon.proximity.toString()}',
                            style: TextStyle(fontSize: 13.0),
                          ),
                        ],
                      );
                    else
                      return Column(
                        children: [
                          Text(
                            'This is a iBeacon frame',
                            style: TextStyle(fontSize: 15.0),
                          ),
                          Text(
                            beacon.macAddress,
                            style: TextStyle(fontSize: 15.0),
                          ),
                          ListTile(
                            title: Text(
                              beacon.proximityUUID,
                              style: TextStyle(fontSize: 15.0),
                            ),
                            subtitle: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    'Major: ${beacon.major}\nMinor: ${beacon.minor}',
                                    style: TextStyle(fontSize: 13.0),
                                  ),
                                  flex: 1,
                                  fit: FlexFit.tight,
                                ),
                                Flexible(
                                  child: Text(
                                    'Accuracy: ${beacon.accuracy} m\nRSSI: ${beacon.rssi} dBm',
                                    style: TextStyle(fontSize: 13.0),
                                  ),
                                  flex: 2,
                                  fit: FlexFit.tight,
                                )
                              ],
                            ),
                          ),
                          Text(
                            'Tx Power: ${beacon.txPower}',
                            style: TextStyle(fontSize: 13.0),
                          ),
                          Text('Proximity: ${beacon.proximity.toString()}',
                              style: TextStyle(fontSize: 13.0)),
                        ],
                      );
                  },
                ),
              ).toList(),
            ),
    );
  }
}
