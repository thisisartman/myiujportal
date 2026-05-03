import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardSettings {
  final String columnCount;
  final String quickLinkStyle;
  final bool showUpNext;
  final bool showTimeline;
  final bool showAlerts;
  final bool showQuickLinks;
  final bool showIdCard;
  final bool showLibrary;
  final bool showPolls;

  const DashboardSettings({
    this.columnCount = '3',
    this.quickLinkStyle = 'icon-label',
    this.showUpNext = true,
    this.showTimeline = true,
    this.showAlerts = true,
    this.showQuickLinks = true,
    this.showIdCard = true,
    this.showLibrary = true,
    this.showPolls = true,
  });

  DashboardSettings copyWith({
    String? columnCount,
    String? quickLinkStyle,
    bool? showUpNext,
    bool? showTimeline,
    bool? showAlerts,
    bool? showQuickLinks,
    bool? showIdCard,
    bool? showLibrary,
    bool? showPolls,
  }) {
    return DashboardSettings(
      columnCount: columnCount ?? this.columnCount,
      quickLinkStyle: quickLinkStyle ?? this.quickLinkStyle,
      showUpNext: showUpNext ?? this.showUpNext,
      showTimeline: showTimeline ?? this.showTimeline,
      showAlerts: showAlerts ?? this.showAlerts,
      showQuickLinks: showQuickLinks ?? this.showQuickLinks,
      showIdCard: showIdCard ?? this.showIdCard,
      showLibrary: showLibrary ?? this.showLibrary,
      showPolls: showPolls ?? this.showPolls,
    );
  }
}

class DashboardSettingsNotifier extends Notifier<DashboardSettings> {
  @override
  DashboardSettings build() => const DashboardSettings();

  void setColumnCount(String value) {
    state = state.copyWith(columnCount: value);
  }

  void setQuickLinkStyle(String value) {
    state = state.copyWith(quickLinkStyle: value);
  }

  void toggle(String key) {
    state = switch (key) {
      'upNext' => state.copyWith(showUpNext: !state.showUpNext),
      'timeline' => state.copyWith(showTimeline: !state.showTimeline),
      'alerts' => state.copyWith(showAlerts: !state.showAlerts),
      'quickLinks' => state.copyWith(showQuickLinks: !state.showQuickLinks),
      'idCard' => state.copyWith(showIdCard: !state.showIdCard),
      'library' => state.copyWith(showLibrary: !state.showLibrary),
      'polls' => state.copyWith(showPolls: !state.showPolls),
      _ => state,
    };
  }
}

final dashboardSettingsProvider =
    NotifierProvider<DashboardSettingsNotifier, DashboardSettings>(
      DashboardSettingsNotifier.new,
    );

final quickLinkStyleProvider = Provider<String>((ref) {
  return ref.watch(dashboardSettingsProvider).quickLinkStyle;
});
