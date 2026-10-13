class AppConstants {
  AppConstants._();

  // App meta
  static const String appName = 'Aether Studio';
  static const String appVersion = '1.0.0';

  // Layout
  static const double sidebarWidth = 280.0;
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;
  static const double borderRadiusLg = 20.0;
  static const double glassBlur = 16.0;
  static const double padding = 16.0;
  static const double paddingLg = 24.0;

  // Generation
  static const List<String> stylePresets = [
    'Photorealistic',
    'Digital Art',
    'Anime',
    'Oil Painting',
    'Watercolour',
    'Cinematic',
    'Sketch',
    'Pixel Art',
  ];

  static const List<String> aspectRatios = [
    '1:1',
    '4:3',
    '3:4',
    '16:9',
    '9:16',
  ];

  static const int defaultSteps = 30;
  static const double defaultCfgScale = 7.5;
}
