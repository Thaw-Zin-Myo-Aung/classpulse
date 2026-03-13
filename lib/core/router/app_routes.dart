enum AppRoutes {
  splash('/splash'),
  home('/home'),
  checkIn('/checkin'),
  finish('/finish');

  const AppRoutes(this.path);
  final String path;
}

