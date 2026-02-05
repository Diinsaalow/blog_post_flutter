part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const ALL_POSTS = _Paths.ALL_POSTS;
  static const FAVORITES = _Paths.FAVORITES;
  static const PROFILE = _Paths.PROFILE;
  static const POST_DETAIL = _Paths.POST_DETAIL;
  static const EDIT_POST = _Paths.EDIT_POST;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const ALL_POSTS = '/all-posts';
  static const FAVORITES = '/favorites';
  static const PROFILE = '/profile';
  static const POST_DETAIL = '/post-detail';
  static const EDIT_POST = '/edit-post';
}
