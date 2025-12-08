import 'package:flower_accounting_app/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/supplies/screens/supplies_list.dart';
import '../features/sales/screens/sales_list_screen.dart';
import '../features/clients/screens/clients_list.dart';
import '../features/writeoff/screens/writeoff_list.dart';
import '../features/reports/screens/reports_dashboard.dart';
import '../features/showcase/screens/showcase_list.dart';
import '../features/showcase/screens/assemble_product_screen.dart';
import '../features/supplies/screens/supply_create_screen.dart';
import '../features/materials/screens/material_select_screen.dart';
import 'package:flower_accounting_app/data/models/assembled_product.dart';
import '../features/supplies/screens/supply_edit_screen.dart';




import 'root_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => RootShell(child: child),
      routes: [

        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        GoRoute(
          path: '/supplies',
          name: 'supplies',
          builder: (context, state) => const SuppliesListScreen(),
        ),

        GoRoute(
         path: '/supplies/edit/:id',
         builder: (context, state) {
           final id = state.pathParameters['id']!;
            return SupplyEditScreen(id: id);
        },
       ),

        // ✅ ВИТРИНА — ПРАВИЛЬНЫЙ ПУТЬ
        GoRoute(
          path: '/showcase',
          name: 'showcase',
          builder: (context, state) => const ShowcaseListScreen(),
        ),

        GoRoute(
          path: '/assemble', 
          name: 'assemble',
          builder: (context, state) => const AssembleProductScreen(),
          ),

        GoRoute(
          path: '/assemble/edit/:id',
          name: 'assemble_edit',
          builder: (context, state) {
            final product = state.extra as AssembledProduct;
            return AssembleProductScreen(editProduct: product);
          },
        ),

        GoRoute(
          path: '/supplies/new',
          name: 'supply_new',
          builder: (context, state) => const SupplyCreateScreen(),
        ),

        GoRoute(
          path: '/sales',
          name: 'sales',
          builder: (context, state) => const SalesListScreen(),
        ),

        GoRoute(
          path: '/clients',
          name: 'clients',
          builder: (context, state) => const ClientsListScreen(),
        ),

        GoRoute(
          path: '/writeoff',
          name: 'writeoff',
          builder: (context, state) => const WriteoffListScreen(),
        ),

        GoRoute(
          path: '/reports',
          name: 'reports',
          builder: (context, state) => const ReportsDashboard(),
        ),

        GoRoute(
          path: '/materials/select',
          name: 'materials_select',
          builder: (context, state) {
            final onSelect = state.extra as Function(dynamic);
            return MaterialSelectScreen(onSelect: onSelect);
          },
        ),
      ],
    ),
  ],
);
