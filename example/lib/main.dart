import 'package:flutter/material.dart';
import 'package:iphone_due_sizing/iphone_due_sizing.dart';

void main() => runApp(
      IphoneSizing(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Container(
                width: 200.w,
                height: 80.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text('Scaled', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
          ),
        ),
      ),
    );
