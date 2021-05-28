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
          _beacons.clear();
          _regionBeacons.values.forEach((list) {
            _beacons.addAll(list);
          });
          _beacons.sort(_compareParameters);
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
                color: Colors.white,
                tiles: _beacons.map(
                  (beacon) {
                    return Column(
                      children: [
                        Text(
                          beacon.macAddress,
                          style: TextStyle(fontSize: 15.0),
                        ),
                        ListTile(
                          // leading: Text(
                          //   beacon.macAddress,
                          //   style: TextStyle(fontSize: 15.0),
                          // ),
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
                                  'Accuracy: ${beacon.accuracy}m\nRSSI: ${beacon.rssi}',
                                  style: TextStyle(fontSize: 13.0),
                                ),
                                flex: 2,
                                fit: FlexFit.tight,
                              )
                            ],
                          ),
                          // trailing: Text(beacon.proximity.toString(),
                          //     style: TextStyle(fontSize: 15.0)),
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
