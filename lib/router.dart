import 'package:go_router/go_router.dart';

import 'package:aplikasi_catatan_note/screens/home_screen.dart';
import 'package:aplikasi_catatan_note/screens/note_editor_screen.dart';
import 'package:aplikasi_catatan_note/screens/note_detail_screen.dart';
import 'package:aplikasi_catatan_note/screens/category_manager_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/note/new',
      builder: (context, state) => const NoteEditorScreen(),
    ),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return NoteDetailScreen(noteId: id);
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return NoteEditorScreen(noteId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoryManagerScreen(),
    ),
  ],
);
