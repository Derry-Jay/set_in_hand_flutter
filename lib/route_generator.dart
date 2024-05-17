import 'models/task.dart';
import 'screens/loginpage.dart';
import 'screens/whatisthis.dart';
import 'package:flutter/material.dart';
import 'models/route_argument.dart';
import 'screens/qr_image_screen.dart';
import 'screens/cyclestockcheck.dart';
import 'screens/deliverydetails.dart';
import 'screens/dashboard_screen.dart';
import 'screens/full_stock_screen.dart';
import 'screens/pulllist_scanpage.dart';
import 'widgets/route_error_screen.dart';
import 'screens/goodsin_movement_list.dart';
import 'screens/stock_movement_options.dart';
import 'screens/stockmovement_scanpage.dart';
import 'screens/goodsin_movement_scanpage.dart';
import 'screens/full_stock_next_step_screen.dart';
import 'screens/stockMovementNavigatedscanpage.dart';

class RouteGenerator {
  static Route generateRoute(RouteSettings settings) {
    Widget pageBuilder(BuildContext context) {
      final args = settings.arguments;
      switch (settings.name) {
        case '/login':
          return const LoginPage();
        case '/dashboard':
          return const DashboardScreen();
        case '/stockMovementOptions':
          return const StockMovementOptions();
        case '/goodsInMovementScan':
          return GoodsInMovementScanPage(rar: args as RouteArgument);
        case '/goodsInMovement':
          return const GoodsInMovementList();
        case '/stockMovementsScan':
          return const STOCKMOVEMENTSCANPAGE();
        case '/pullList':
          return PullListScreen(task: args as Task);
        case '/deliveryDetails':
          return DeliveryDetails(rar: args as RouteArgument);
        case '/fullStock':
          return FullStockScreen(task: args as Task);
        case '/cycleStock':
          return CycleStockCheck(task: args as Task);
        case '/whatIsThis':
          return const WhatIsThis();
        case '/stockMovementFinal':
          return StockMovementFinalPage(rar: args as RouteArgument);
        case '/fullStockItems':
          return FullStockNextStepScreen(rar: args as RouteArgument);
        case '/qr':
          return const QRImageScreen();
        // case :
        //   return;
        // case :
        //   return;
        default:
          return const RouteErrorScreen(flag: true);
      }
    }

    return MaterialPageRoute(builder: pageBuilder, settings: settings);
  }
}
