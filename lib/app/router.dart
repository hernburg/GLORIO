import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- AUTH ---
import '../features/auth/login_screen.dart';
import '../features/welcome/welcome_screen.dart';

// --- SUPPLIES ---
import '../features/supplies/screens/supplies_list.dart';
import '../features/supplies/screens/supply_create_screen.dart';

// --- SHOWCASE ---
import '../features/showcase/screens/showcase_list.dart';
import '../features/showcase/screens/assemble_product_screen.dart';

// --- SALES ---
import '../features/sales/screens/sales_list_screen.dart';
import '../features/sales/screens/sale_info_screen.dart';

// --- CLIENTS ---
import '../features/clients/screens/clients_list.dart';
import '../features/clients/screens/client_edit_screen.dart';
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
  /// WELCOME — верхний уровень
  /// -------------------------
  GoRoute(
    path: '/welcome',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const WelcomeScreen(),
  ),

  /// -------------------------
  /// LOGIN — верхний уровень
  /// -------------------------
  GoRoute(
    path: '/login',
    parentNavigatorKey: rootNavigatorKey,   // правильно
    builder: (context, state) => const LoginScreen(),
  ),

  /// -------------------------
  /// SHELL — всё приложение
  /// -------------------------
  ShellRoute(
    navigatorKey: shellNavigatorKey,
    builder: (context, state, child) => RootShell(child: child),

    routes: [

      GoRoute(
        path: '/supplies',
        builder: (context, state) => const SuppliesListScreen(),
      ),
      GoRoute(
        path: '/supplies/new',
        builder: (context, state) => const SupplyCreateScreen(),
      ),
      GoRoute(
        path: '/supplies/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SupplyCreateScreen(editId: id);
        },
      ),

      /// SHOWCASE
      GoRoute(
        path: '/showcase',
        builder: (context, state) => const ShowcaseListScreen(),
      ),
      GoRoute(
        path: '/assemble',
        builder: (context, state) => const AssembleProductScreen(),
      ),
      GoRoute(
        path: '/assemble_edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AssembleProductScreen(editId: id);
        },
      ),

      /// SALES
      GoRoute(
        path: '/sales',
        builder: (context, state) => const SalesListScreen(),
      ),
      GoRoute(
        path: '/sale_info/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SaleInfoScreen(saleId: id);
        },
      ),

      /// CLIENTS
      GoRoute(
        path: '/clients',
        builder: (context, state) => const ClientsListScreen(),
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
        builder: (context, state) => const WriteoffListScreen(),
      ),

      /// REPORTS
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsDashboard(),
      ),

      /// MATERIAL SELECT
      GoRoute(
        path: '/materials/select',
        builder: (context, state) {
          final onSelect = state.extra as Function(dynamic);
          return MaterialSelectScreen(onSelect: onSelect);
        },
      ),
    ],
  ),
];