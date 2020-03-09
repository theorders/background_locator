import 'dart:async';
import 'dart:ui';

import 'package:background_locator/auto_stop_handler.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/location_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'callback_dispatcher.dart';
import 'keys.dart';

class BackgroundLocator{
  static const MethodChannel _channel = const MethodChannel(Keys.CHANNEL_ID);
  static const MethodChannel _background =
      MethodChannel(Keys.BACKGROUND_CHANNEL_ID);

  static Future<void> initialize() async {
    final CallbackHandle callback =
        PluginUtilities.getCallbackHandle(callbackDispatcher);
    await _channel.invokeMethod(Keys.METHOD_PLUGIN_INITIALIZE_SERVICE,
        {Keys.ARG_CALLBACK_DISPATCHER: callback.toRawHandle()});
  }

  static Future<void> registerLocationUpdate(
      void Function(LocationDto) callback,
      {LocationSettings settings}) async {
    print('===============registerLocationUpdate===============');

    final _settings = settings ?? LocationSettings();
    print('===============autoStop: ${_settings.autoStop}===============');
    if (_settings.autoStop) {
      WidgetsBinding.instance.addObserver(AutoStopHandler());
    }

    final args = {
      Keys.ARG_CALLBACK:
          PluginUtilities.getCallbackHandle(callback).toRawHandle(),
      Keys.ARG_SETTINGS: _settings.toMap()
    };

    await _channel.invokeMethod(
        Keys.METHOD_PLUGIN_REGISTER_LOCATION_UPDATE, args);
  }

  static Future<void> unRegisterLocationUpdate() async {
    await _channel.invokeMethod(Keys.METHOD_PLUGIN_UN_REGISTER_LOCATION_UPDATE);
  }
}
