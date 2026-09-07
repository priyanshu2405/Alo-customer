import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/*
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final _controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get stream => _controller.stream;

  bool get isConnected => _channel != null;

  void connect(String url, {Map<String, String>? headers}) {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(
      Uri.parse(url),
      // protocols: [
      //   'auth',
      //   'token_${yourToken}',
      // ],
     // headers: headers,
    );

    _channel?.stream.listen((data) {
        try {
          final decoded = jsonDecode(data);
          _controller.add(decoded);
        } catch (_) {
          _controller.add(data);
        }
      },
      onError: (error) {
        _controller.addError(error);
        _reconnect(url, headers);
      },
      onDone: () {
        _reconnect(url, headers);
      },
    );
  }

  /// SEND DATA
  void send(dynamic data) {
    if (_channel == null) {
      debugPrint('[WS] ❌ Send failed: Socket not connected');
      return;
    }

    final payload =
    data is String ? data : jsonEncode(data);
    _channel?.sink.add(payload);
    debugPrint(
      '[WS] 📤 Sent → ${_truncate(payload)}',
    );
  }
  String _truncate(String text, {int max = 5000}) {
    if (text.length <= max) return text;
    return '${text.substring(0, max)}...(${text.length} chars)';
  }

  /// DISCONNECT
  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  /// AUTO RECONNECT
  void _reconnect(String url, Map<String, String>? headers) async {
    disconnect();
    await Future.delayed(const Duration(seconds: 3));
    connect(url, headers: headers);
  }

  /// CLEANUP
  void dispose() {
    disconnect();
    _controller.close();
  }
}*/



/// ============================================
/// CORRECT IMPLEMENTATION
/// ============================================
class SocketIoService {
  static final SocketIoService _instance = SocketIoService._internal();
  factory SocketIoService() => _instance;
  SocketIoService._internal();

  IO.Socket? _socket;
  final _controller = StreamController<dynamic>.broadcast();

  int? _currentUserId;
  int? _currentRideId;
  bool _isSubscribedToLocation = false;
  bool _isLocationListenerSetup = false;

  Stream<dynamic> get stream => _controller.stream;
  bool get isConnected => _socket?.connected == true;

  /// Connect to socket
  Future<void> connect({
    required String userId,
    required String token,
  }) async{
    if (_socket != null && _socket!.connected) {
      debugPrint('[USER SOCKET] Already connected');
      return;
    }

    _currentUserId = int.tryParse(userId);

    _socket = IO.io(
      'http://66.116.207.180:3000',
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(5)
          .build(),
    );

    _setupEventListeners();
    _socket?.connect();
  }

  void _setupEventListeners() {
    _socket?.onConnect((_) {
      debugPrint('[USER SOCKET] ✅ Connected :: ${_socket?.id}');

      _authenticate();
    });
    _socket?.onDisconnect((_) {
      debugPrint('[USER SOCKET] 🔌 Disconnected');
      _isLocationListenerSetup = false;
    });

    _socket?.on('user:authenticated', (data) {
      debugPrint('[USER SOCKET] ✅ Authenticated');
    });
    // ⭐ LISTEN TO DRIVER LOCATION UPDATES
    // This is the CORRECT way - just listen to the event
    _socket?.on('driver:location_updated', (data) {
      debugPrint('[USER SOCKET] 📍 Driver location updated: $data');

      _controller.add({
        'event': 'driver:location_updated',
        'data': {
          'driver_id': data['driver_id'],
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'ride_id': data['ride_id'],
          'timestamp': data['timestamp'],
        },
      });
    });

    // Other events...


    _socket?.on('ride:accepted', (data) {
      debugPrint('[USER SOCKET] 🎉 Ride accepted');
      final rideId = data['ride_id'];
      if (rideId != null) {
        subscribeToLocationUpdates(int.tryParse(rideId.toString()) ?? 0);
      }
    });

    _socket?.on('user:status_updated', (data) {
      debugPrint('[USER SOCKET] 🎉 status changed $data');
     /* final rideId = data['ride_id'];
      if (rideId != null) {
        subscribeToLocationUpdates(int.tryParse(rideId.toString()) ?? 0);
      }*/
    });

    _socket?.on('user:location_subscribed', (data) {
      debugPrint('[USER SOCKET] 🎉 user:location_subscribed $data');
    });

    // _socket?.on('driver:status_updated_new', (data) {
    //   debugPrint('[USER SOCKET] 🎉 driver:status_updated_new $data');
    // });


    _socket?.onAny((event, data) {
      try {
        final decoded = data is String ? jsonDecode(data) : data;
        debugPrint('[USER SOCKET] 📡 Event: $event');
        _controller.add({
          'event': event,
          'data': decoded,
        });
      } catch (e) {
        debugPrint('[USER SOCKET] Error decoding event: $e');
      }
    });
  }


  void _authenticate() {
    if (_currentUserId == null) return;
    _socket?.emit('user:auth', {'user_id': _currentUserId});
  }

  /// Subscribe to location updates for a ride
  void subscribeToLocationUpdates(int rideId) {
    if (!isConnected) return;

    _currentRideId = rideId;
    _socket?.emit('user:subscribe_location', {
      'ride_id': rideId,
    });

   // debugPrint('[USER SOCKET] 📍 Subscribed to location for ride $rideId');
  }

  /// ⭐ CORRECT METHOD - Listen to driver location updates
  /// This method sets up a listener for driver location updates
  void onDriverLocationUpdated(
      void Function(DriverLocationUpdate update) listener,
      )
  {
    debugPrint('[USER SOCKET] 👂 Attaching driver:location_updated listener');

    // avoid duplicates
    _socket?.off('driver:location_updated');

    _socket?.on('driver:location_updated', (data) {
      debugPrint('[USER SOCKET] 📍 Raw location event: $data');

      try {
        final map = data is Map
            ? Map<String, dynamic>.from(data)
            : Map<String, dynamic>.from(jsonDecode(data));

        final update = DriverLocationUpdate.fromJson(map);

        // CALLBACK FIRING HERE
        listener(update);

      } catch (e) {
        debugPrint('[USER SOCKET] ❌ Parse error: $e');
      }
    });
    // _socket?.on('driver:status_updated', (data) {
    //   debugPrint('[USER SOCKET] 📍 status location update ud: $data');
    // });
    debugPrint('[USER SOCKET] ✅ Driver location listener ready');
  }

  // Future<void> onDriverLocationUpdated(
  //     void Function(Map<String, dynamic> update) listener,
  //     )
  // async {
  //   if (!isConnected) {
  //     debugPrint('[USER SOCKET] ❌ Not connected');
  //     return;
  //   }
  //
  //
  //   // Remove any existing listener first
  //   _socket?.off('driver:location_updated');
  //   debugPrint('[USER SOCKET] 👂 Setting up driver:location_updated listener');
  //
  //   // Set up the listener
  //   _socket?.on('driver:location_updated', (data) {
  //     debugPrint('[USER SOCKET] 📨 Received driver location: $data');
  //
  //     try {
  //       // Parse the data
  //       Map<String, dynamic> locationData;
  //
  //       if (data is Map) {
  //         locationData = Map<String, dynamic>.from(data);
  //       }
  //       else if (data is String) {
  //         locationData = jsonDecode(data) as Map<String, dynamic>;
  //       }
  //       else {
  //         debugPrint('[USER SOCKET] ❌ Invalid data format');
  //         return;
  //       }
  //
  //       // Call the listener with parsed data
  //       listener(locationData);
  //
  //     } catch (e) {
  //       debugPrint('[USER SOCKET] ❌ Parse error: $e');
  //     }finally {
  //       print("dvdvjdv");
  //     }
  //   });
  // }

  Future<void> rideAccept({int? rideId}) async{
    _socket?.on('ride:accepted', (data) {
      debugPrint('[USER SOCKET] 🎉 Ride accepted: $data');

      final rideId = data['ride_id'];
      _currentRideId = rideId != null ? int.tryParse(rideId.toString()) : null;

      _controller.add({
        'event': 'ride:accepted',
        'data': data,
      });

      // Auto-subscribe to location updates when ride is accepted
      if (_currentRideId != null) {
        subscribeToLocationUpdates(_currentRideId!);
      }
    });

  }

  Future<void> subScribeLocation() async{
    _socket?.on('user:location_subscribed', (data) {
      debugPrint('[USER SOCKET] ✅ Location subscribed: $data');
      _isSubscribedToLocation = true;
      _controller.add({
        'event': 'user:location_subscribed',
        'data': data,
      });
    });
  }

  Future<void> getLocationStatus(    void Function(String update) listener,
      ) async {
    // correct event name
    const eventName = 'user:status_updated';

    // remove previous listener to avoid duplicates
    _socket?.off(eventName);

    debugPrint('[USER SOCKET] 👂 Listening → $eventName');

    _socket?.on(eventName, (data) {
      debugPrint('[USER SOCKET] 🚕 user:status_update => $data');

      try {
        final map = data is Map
            ? Map<String, dynamic>.from(data)
            : Map<String, dynamic>.from(jsonDecode(data));

        final status = map['status']?.toString() ?? '';
        debugPrint('[USER SOCKET] 🟢 Parsed driver status: $status');
        listener(status);

        // TODO: update your ridePhase here if needed
      } catch (e) {
        debugPrint('[USER SOCKET] ❌ status_update parse error: $e');
      }
    });
  }



  void disconnect() {
    _socket?.off('driver:location_updated');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}




class DriverLocationUpdate {
  final dynamic driverId;
  final dynamic latitude;
  final dynamic longitude;
  final dynamic rideId;
  final dynamic timestamp;

  DriverLocationUpdate({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.rideId,
    required this.timestamp,
  });

  factory DriverLocationUpdate.fromJson(Map<String, dynamic> json) {
    return DriverLocationUpdate(
      driverId: json['driver_id'].toString(),
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      rideId: json['ride_id'].toString(),
      timestamp: json['timestamp'].toString(),
    );
  }
}
