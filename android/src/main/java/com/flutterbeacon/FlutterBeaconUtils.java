package com.flutterbeacon;

import android.util.Log;

import org.altbeacon.beacon.Beacon;
import org.altbeacon.beacon.BeaconParser;
import org.altbeacon.beacon.Identifier;
import org.altbeacon.beacon.MonitorNotifier;
import org.altbeacon.beacon.Region;
import org.altbeacon.beacon.utils.UrlBeaconUrlCompressor;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

class FlutterBeaconUtils {
    static String parseState(int state) {
        return state == MonitorNotifier.INSIDE ? "INSIDE" : state == MonitorNotifier.OUTSIDE ? "OUTSIDE" : "UNKNOWN";
    }

    static List<Map<String, Object>> beaconsToArray(List<Beacon> beacons) {
        if (beacons == null) {
            return new ArrayList<>();
        }
        List<Map<String, Object>> list = new ArrayList<>();
        for (Beacon beacon : beacons) {
            Map<String, Object> map = beaconToMap(beacon);
            list.add(map);
        }

        return list;
    }

    private static Map<String, Object> beaconToMap(Beacon beacon) {
        Map<String, Object> map = new HashMap<>();

        // if is a Eddystone-UID frame
        if (beacon.getServiceUuid() == 0xfeaa && beacon.getBeaconTypeCode() == 0x00) {
            // This is a Eddystone-UID frame
            map.put("namespaceId", beacon.getId1().toString().toUpperCase());
            map.put("instanceId", beacon.getId2().toString().toUpperCase());
            map.put("rssi", beacon.getRssi());
            map.put("txPower", beacon.getTxPower());
            map.put("accuracy", String.format(Locale.US, "%.2f", beacon.getDistance()));
            map.put("macAddress", beacon.getBluetoothAddress());
            map.put("bleName", beacon.getBluetoothName());
            map.put("beaconTypeCode", beacon.getBeaconTypeCode());

            // Do we have telemetry data?
            if (beacon.getExtraDataFields().size() > 0) {
                map.put("telemetryVersion", beacon.getExtraDataFields().get(0));
                //long telemetryVersion = beacon.getExtraDataFields().get(0);
                map.put("batteryMilliVolts", beacon.getExtraDataFields().get(1));
                //long batteryMilliVolts = beacon.getExtraDataFields().get(1);
                map.put("pduCount", beacon.getExtraDataFields().get(3));
                //long pduCount = beacon.getExtraDataFields().get(3);
                map.put("uptime", beacon.getExtraDataFields().get(4));
                //long uptime = beacon.getExtraDataFields().get(4);
                map.put("temperature", beacon.getExtraDataFields().get(2));
            }
        }
        else
        // if is a Eddystone-URL frame
        if (beacon.getServiceUuid() == 0xfeaa && beacon.getBeaconTypeCode() == 0x10) {
            // This is a Eddystone-URL frame
            map.put("url", UrlBeaconUrlCompressor.uncompress(beacon.getId1().toByteArray()));
            map.put("rssi", beacon.getRssi());
            map.put("txPower", beacon.getTxPower());
            map.put("accuracy", String.format(Locale.US, "%.2f", beacon.getDistance()));
            map.put("macAddress", beacon.getBluetoothAddress());
            map.put("bleName", beacon.getBluetoothName());
            map.put("beaconTypeCode", beacon.getBeaconTypeCode());

            // Do we have telemetry data?
            if (beacon.getExtraDataFields().size() > 0) {
                map.put("telemetryVersion", beacon.getExtraDataFields().get(0));
                //long telemetryVersion = beacon.getExtraDataFields().get(0);
                map.put("batteryMilliVolts", beacon.getExtraDataFields().get(1));
                //long batteryMilliVolts = beacon.getExtraDataFields().get(1);
                map.put("pduCount", beacon.getExtraDataFields().get(3));
                //long pduCount = beacon.getExtraDataFields().get(3);
                map.put("uptime", beacon.getExtraDataFields().get(4));
                //long uptime = beacon.getExtraDataFields().get(4);
                map.put("temperature", beacon.getExtraDataFields().get(2));
            }
        }
        else
        // if is a Eddystone-TLM frame
        if (beacon.getServiceUuid() == 0xfeaa && beacon.getBeaconTypeCode() == 0x20) {
            // This is a Eddystone-TLM frame
            // Do we have telemetry data?
            //if (beacon.getExtraDataFields().size() > 0) {
                map.put("telemetryVersion", beacon.getExtraDataFields().get(0));
                //long telemetryVersion = beacon.getExtraDataFields().get(0);
                map.put("batteryMilliVolts", beacon.getExtraDataFields().get(1));
                //long batteryMilliVolts = beacon.getExtraDataFields().get(1);
                map.put("pduCount", beacon.getExtraDataFields().get(3));
                //long pduCount = beacon.getExtraDataFields().get(3);
                map.put("uptime", beacon.getExtraDataFields().get(4));
                //long uptime = beacon.getExtraDataFields().get(4);
                map.put("temperature", beacon.getExtraDataFields().get(2));
            //}
        }
        else
            // if is a Eddystone-EID frame
            if (beacon.getServiceUuid() == 0xfeaa && beacon.getBeaconTypeCode() == 0x30) {
                // This is a Eddystone-EID frame
                map.put("ephemeralId", beacon.getId1().toString().toUpperCase());
                map.put("rssi", beacon.getRssi());
                map.put("txPower", beacon.getTxPower());
                map.put("accuracy", String.format(Locale.US, "%.2f", beacon.getDistance()));
                map.put("macAddress", beacon.getBluetoothAddress());
                map.put("bleName", beacon.getBluetoothName());
                map.put("beaconTypeCode", beacon.getBeaconTypeCode());
            }
        else
        {
        map.put("proximityUUID", beacon.getId1().toString().toUpperCase());
        map.put("major", beacon.getId2().toInt());
        map.put("minor", beacon.getId3().toInt());
        map.put("rssi", beacon.getRssi());
        map.put("txPower", beacon.getTxPower());
        map.put("accuracy", String.format(Locale.US, "%.2f", beacon.getDistance()));
        map.put("macAddress", beacon.getBluetoothAddress());
        map.put("bleName", beacon.getBluetoothName());
        //map.put("identifier", beacon.getParserIdentifier());
        }

        return map;
    }

    static Map<String, Object> regionToMap(Region region) {
        Map<String, Object> map = new HashMap<>();

        map.put("identifier", region.getUniqueId());
        if (region.getId1() != null) {
            map.put("proximityUUID", region.getId1().toString());
        }
        if (region.getId2() != null) {
            map.put("major", region.getId2().toInt());
        }
        if (region.getId3() != null) {
            map.put("minor", region.getId3().toInt());
        }

        return map;
    }

    @SuppressWarnings("rawtypes")
    static Region regionFromMap(Map map) {
        try {
            String identifier = "";
            List<Identifier> identifiers = new ArrayList<>();

            Object objectIdentifier = map.get("identifier");
            if (objectIdentifier instanceof String) {
                identifier = objectIdentifier.toString();
            }

            Object proximityUUID = map.get("proximityUUID");

            if (proximityUUID instanceof String) {
                identifiers.add(Identifier.parse((String) proximityUUID));
            }

            Object major = map.get("major");
            if (major instanceof Integer) {
                identifiers.add(Identifier.fromInt((Integer) major));
            }
            Object minor = map.get("minor");
            if (minor instanceof Integer) {
                identifiers.add(Identifier.fromInt((Integer) minor));
            }

            return new Region(identifier, identifiers);
        } catch (IllegalArgumentException e) {
            Log.e("REGION", "Error : " + e);
            return null;
        }
    }

    @SuppressWarnings("rawtypes")
    static Beacon beaconFromMap(Map map) {
        Beacon.Builder builder = new Beacon.Builder();

        Object proximityUUID = map.get("proximityUUID");
        if (proximityUUID instanceof String) {
            builder.setId1((String) proximityUUID);
        }
        Object major = map.get("major");
        if (major instanceof Integer) {
            builder.setId2(major.toString());
        }
        Object minor = map.get("minor");
        if (minor instanceof Integer) {
            builder.setId3(minor.toString());
        }

        Object txPower = map.get("txPower");
        if (txPower instanceof Integer) {
            builder.setTxPower((Integer) txPower);
        } else {
            builder.setTxPower(-59);
        }

        builder.setDataFields(Collections.singletonList(0L));
        builder.setManufacturer(0x004c);

        return builder.build();
    }
}
