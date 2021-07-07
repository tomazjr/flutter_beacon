//  Copyright (c) 2018 Eyro Labs.
//  Licensed under Apache License v2.0 that can be
//  found in the LICENSE file.

part of flutter_beacon;

/// Enum for defining proximity.
enum Proximity { unknown, immediate, near, far }

/// Class for managing Beacon object.
class Beacon {
  /// The proximity UUID of beacon.
  final String? proximityUUID;

  /// The mac address of beacon.
  ///
  /// From iOS this value will be null
  final String? macAddress;

  /// The major value of beacon.
  final int? major;

  /// The minor value of beacon.
  final int? minor;

  /// The rssi value of beacon in dBm.
  final int rssi;

  /// The transmission power of beacon.
  ///
  /// From iOS this value will be null
  final int? txPower;

  /// The accuracy of distance of beacon in meter.
  final double accuracy;

  /// The proximity of beacon.
  final Proximity? _proximity;

  /// Identifier namespaceID of UID
  final String? namespaceId;

  /// Identifier instanceId of UID
  final String? instanceId;

  /// ExtraDataFields telemetryVersion
  final int? telemetryVersion;

  /// ExtraDataFields battery level batteryMilliVolts in mV
  final int? batteryMilliVolts;

  /// ExtraDataFields pduCount advertisements
  final int? pduCount;

  /// ExtraDataFields uptime in seconds
  final int? uptime;

  /// ExtraDataFields temperature in °C
  final int? temperature;

  /// Identifier url of URL
  final String? url;

  /// BeaconTypeCode
  final int? beaconTypeCode;

  /// BluetoothName
  final String? bleName;

  /// Identifier ephemeralId of EID
  final String? ephemeralId;

  /// Create beacon object.
  const Beacon({
    /* required */ this.proximityUUID,
    this.macAddress,
    /* required */ this.major,
    /* required */ this.minor,
    int? rssi,
    this.txPower,
    required this.accuracy,
    Proximity? proximity,
    this.namespaceId,
    this.instanceId,
    this.telemetryVersion,
    this.batteryMilliVolts,
    this.pduCount,
    this.uptime,
    this.temperature,
    this.url,
    this.beaconTypeCode,
    this.bleName,
    this.ephemeralId,
  })  : this.rssi = rssi ?? -1,
        this._proximity = proximity;

  /// Create beacon object from json.
  Beacon.fromJson(dynamic json)
      : this(
          proximityUUID: json['proximityUUID'],
          macAddress: json['macAddress'],
          major: json['major'],
          minor: json['minor'],
          rssi: _parseInt(json['rssi']),
          txPower: _parseInt(json['txPower']),
          accuracy: _parseDouble(json['accuracy']),
          proximity: _parseProximity(json['proximity']),
          namespaceId: json['namespaceId'],
          instanceId: json['instanceId'],
          telemetryVersion: json['telemetryVersion'],
          batteryMilliVolts: json['batteryMilliVolts'],
          pduCount: _parseInt(json['pduCount']),
          uptime: json['uptime'],
          temperature: json['temperature'],
          url: json['url'],
          beaconTypeCode: _parseInt(json['beaconTypeCode']),
          bleName: json['bleName'],
          ephemeralId: json['ephemeralId'],
        );

  /// Parsing dynamic data into double.
  static double _parseDouble(dynamic data) {
    if (data is num) {
      return data.toDouble();
    } else if (data is String) {
      return double.tryParse(data) ?? 0.0;
    }

    return 0.0;
  }

  /// Parsing dynamic data into integer.
  static int? _parseInt(dynamic data) {
    if (data is num) {
      return data.toInt();
    } else if (data is String) {
      return int.tryParse(data) ?? 0;
    }

    return null;
  }

  /// Parsing dynamic proximity into enum [Proximity].
  static dynamic _parseProximity(dynamic proximity) {
    if (proximity == 'unknown') {
      return Proximity.unknown;
    }

    if (proximity == 'immediate') {
      return Proximity.immediate;
    }

    if (proximity == 'near') {
      return Proximity.near;
    }

    if (proximity == 'far') {
      return Proximity.far;
    }

    return null;
  }

  /// Parsing array of [Map] into [List] of [Beacon].
  static List<Beacon> beaconFromArray(dynamic beacons) {
    if (beacons is List) {
      return beacons.map((json) {
        return Beacon.fromJson(json);
      }).toList();
    }

    return [];
  }

  /// Parsing [List] of [Beacon] into array of [Map].
  static dynamic beaconArrayToJson(List<Beacon> beacons) {
    return beacons.map((beacon) {
      return beacon.toJson;
    }).toList();
  }

  /// Serialize current instance object into [Map].
  dynamic get toJson {
    final map = <String, dynamic>{
      //'proximityUUID': proximityUUID,
      //'major': major,
      //'minor': minor,
      'rssi': rssi,
      'accuracy': accuracy,
      'proximity': proximity.toString().split('.').last
    };

    if (proximityUUID != null) {
      map['proximityUUID'] = proximityUUID;
    }
    if (major != null) {
      map['major'] = major;
    }
    if (minor != null) {
      map['minor'] = minor;
    }

    if (txPower != null) {
      map['txPower'] = txPower;
    }

    if (macAddress != null) {
      map['macAddress'] = macAddress;
    }

    if (namespaceId != null) {
      map['namespaceId'] = namespaceId;
    }
    if (instanceId != null) {
      map['instanceId'] = instanceId;
    }
    if (telemetryVersion != null) {
      map['telemetryVersion'] = telemetryVersion;
    }
    if (batteryMilliVolts != null) {
      map['batteryMilliVolts'] = batteryMilliVolts;
    }
    if (pduCount != null) {
      map['pduCount'] = pduCount;
    }
    if (uptime != null) {
      map['uptime'] = uptime;
    }
    if (temperature != null) {
      map['temperature'] = temperature;
    }
    if (url != null) {
      map['url'] = url;
    }
    if (beaconTypeCode != null) {
      map['beaconTypeCode'] = beaconTypeCode;
    }
    if (bleName != null) {
      map['bleName'] = bleName;
    }
    if (ephemeralId != null) {
      map['ephemeralId'] = ephemeralId;
    }

    return map;
  }

  /// Return [Proximity] of beacon.
  ///
  /// iOS will always set proximity by default, but Android is not
  /// so we manage it by filtering the accuracy like bellow :
  /// - `accuracy == 0.0` : [Proximity.unknown]
  /// - `accuracy > 0 && accuracy <= 0.5` : [Proximity.immediate]
  /// - `accuracy > 0.5 && accuracy < 3.0` : [Proximity.near]
  /// - `accuracy > 3.0` : [Proximity.far]
  Proximity get proximity {
    if (_proximity != null) {
      return _proximity!;
    }

    if (accuracy == 0.0) {
      return Proximity.unknown;
    }

    if (accuracy <= 0.5) {
      return Proximity.immediate;
    }

    if (accuracy < 3.0) {
      return Proximity.near;
    }

    return Proximity.far;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Beacon &&
          runtimeType == other.runtimeType &&
          proximityUUID == other.proximityUUID &&
          major == other.major &&
          minor == other.minor &&
          (macAddress != null ? macAddress == other.macAddress : true);

  @override
  int get hashCode {
    int hashCode = proximityUUID.hashCode ^ major.hashCode ^ minor.hashCode;
    if (macAddress != null) {
      hashCode = hashCode ^ macAddress.hashCode;
    }

    return hashCode;
  }

  @override
  String toString() {
    return json.encode(toJson);
  }
}
