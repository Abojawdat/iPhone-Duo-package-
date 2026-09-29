package io.github.abojawdat.duo_dynamic_sizing;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Build;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;

/** Streams the hinge angle sensor, posture comes from Flutter's display features. */
public class DuoDynamicSizingPlugin
    implements FlutterPlugin,
        MethodChannel.MethodCallHandler,
        EventChannel.StreamHandler,
        SensorEventListener {
  private MethodChannel methods;
  private EventChannel events;
  private SensorManager sensors;
  private Sensor hinge;
  private EventChannel.EventSink sink;
  private Double angle;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    sensors =
        (SensorManager) binding.getApplicationContext().getSystemService(Context.SENSOR_SERVICE);
    if (sensors != null && Build.VERSION.SDK_INT >= 30) {
      hinge = sensors.getDefaultSensor(Sensor.TYPE_HINGE_ANGLE);
    }
    methods = new MethodChannel(binding.getBinaryMessenger(), "duo_dynamic_sizing");
    methods.setMethodCallHandler(this);
    events = new EventChannel(binding.getBinaryMessenger(), "duo_dynamic_sizing/events");
    events.setStreamHandler(this);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    onCancel(null);
    methods.setMethodCallHandler(null);
    events.setStreamHandler(null);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "snapshot":
        result.success(snapshot());
        break;
      case "describe":
        result.success(
            "Android "
                + Build.VERSION.SDK_INT
                + ", hinge sensor: "
                + (hinge == null ? "none" : hinge.getName() + " (" + hinge.getVendor() + ")"));
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    sink = events;
    if (hinge != null) sensors.registerListener(this, hinge, SensorManager.SENSOR_DELAY_UI);
    sink.success(snapshot());
  }

  @Override
  public void onCancel(Object arguments) {
    if (hinge != null) sensors.unregisterListener(this);
    sink = null;
  }

  @Override
  public void onSensorChanged(SensorEvent event) {
    angle = (double) event.values[0];
    if (sink != null) sink.success(snapshot());
  }

  @Override
  public void onAccuracyChanged(Sensor sensor, int accuracy) {}

  private Map<String, Object> snapshot() {
    Map<String, Object> map = new HashMap<>();
    map.put("supported", hinge != null);
    map.put("hinge", hinge != null);
    if (angle != null) {
      map.put("angle", angle);
      // same order as UIHingeStatus: closed 1, partiallyOpen 2, fullyOpen 3
      map.put("status", angle < 5 ? 1 : angle > 175 ? 3 : 2);
    }
    return map;
  }
}
