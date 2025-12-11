import 'package:flower_accounting_app/features/clients/screens/client_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- AUTH ---
import '../features/auth/login_screen.dart';

// --- SUPPLIES ---
import '../features/supplies/screens/supplies_list.dart';
import '../features/supplies/screens/supply_create_screen.dart';
import '../features/supplies/screens/supply_edit_screen.dart';

// --- SHOWCASE / PRODUCTS ---
import '../features/showcase/screens/showcase_list.dart';
import '../features/showcase/screens/assemble_product_screen.dart';
import '../data/models/assembled_product.dart';

// --- SALES ---
import '../features/sales/screens/sales_list_screen.dart';

// --- CLIENTS ---
import '../features/clients/screens/clients_list.dart';
import '../data/models/client.dart';

// --- WRITE-OFF ---
import '../features/writeoff/screens/writeoff_list.dart';

// --- REPORTS ---
import '../features/reports/screens/reports_dashboard.dart';

// --- MATERIALS ---
import '../features/materials/screens/material_select_screen.dart';

// --- LAYOUT ---
import 'root_shell.dart';


/// КЛЮЧИ — корректная структура
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();


/// СПИСОК МАРШРУТОВ
final List<RouteBase> appRoutes = [

  /// -------------------------
  /// LOGIN — верхний уровень
  /// -------------------------
  GoRoute(
    path: '/login',
    parentNavigatorKey: rootNavigatorKey,   // правильно
    builder: (_, __) => const LoginScreen(),
  ),

  /// -------------------------
  /// SHELL — всё приложение
  /// -------------------------
  ShellRoute(
    navigatorKey: shellNavigatorKey,
    builder: (_, state, child) => RootShell(child: child),

    routes: [

      GoRoute(
        path: '/supplies',
        builder: (_, __) => const SuppliesListScreen(),
      ),
      GoRoute(
        path: '/supplies/new',
        builder: (_, __) => const SupplyCreateScreen(),
      ),
      GoRoute(
        path: '/supplies/edit/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return SupplyEditScreen(id: id);
        },
      ),

      /// SHOWCASE
      GoRoute(
        path: '/showcase',
        builder: (_, __) => const ShowcaseListScreen(),
      ),
      GoRoute(
        path: '/assemble',
        builder: (_, __) => const AssembleProductScreen(),
      ),
      GoRoute(
        path: '/assemble/edit/:id',
        builder: (_, state) {
          final product = state.extra as AssembledProduct;
          return AssembleProductScreen(editProduct: product);
        },
      ),

      /// SALES
      GoRoute(
        path: '/sales',
        builder: (_, __) => const SalesListScreen(),
      ),

      /// CLIENTS
      GoRoute(
        path: '/clients',
        builder: (_, __) => const ClientsListScreen(),
      ),

      GoRoute(
        path: '/clients/edit',
        builder: (context, state) {
          final client = state.extra as Client?;
          return ClientEditScreen(client: client);
        },
      ),
    


      /// WRITE-OFF
      GoRoute(
        path: '/writeoff',
        builder: (_, __) => const WriteoffListScreen(),
      ),

      /// REPORTS
      GoRoute(
        path: '/reports',
        builder: (_, __) => const ReportsDashboard(),
      ),

      /// MATERIAL SELECT
      GoRoute(
        path: '/materials/select',
        builder: (_, state) {
          final onSelect = state.extra as Function(dynamic);
          return MaterialSelectScreen(onSelect: onSelect);
        },
      ),
    ],
  ),
];