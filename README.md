# iphone_due_sizing

Design once on an iPhone frame, get the same proportions on every screen.

## Usage

```dart
import 'package:iphone_due_sizing/iphone_due_sizing.dart';

void main() => runApp(
      IphoneSizing(
        // designSize: Size(390, 844), // defaults to iPhone 15 (393x852)
        child: MaterialApp(home: Home()),
      ),
    );

Container(
  width: 200.w,
  height: 48.h,
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
  child: Text('Hi', style: TextStyle(fontSize: 16.sp)),
);
```

| Extension | Scales by |
|-----------|-----------|
| `.w`  | screen width |
| `.h`  | screen height |
| `.r`  | smaller of the two (radii, squares) |
| `.sp` | width × user text scale |
