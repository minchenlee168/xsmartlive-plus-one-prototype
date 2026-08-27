import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_state.freezed.dart';

@freezed
abstract class ThemeState with _$ThemeState {
  const factory ThemeState.initial() = ThemeInitial;
  const factory ThemeState.loading() = ThemeLoading;

  /// Has cached theme from a previous session; background refresh in progress.
  const factory ThemeState.cached(ThemeData theme) = ThemeCached;

  /// Remote theme successfully fetched and applied.
  const factory ThemeState.loaded(ThemeData theme) = ThemeLoaded;

  /// Fetch failed. [fallback] is either cached or the flavor's static fallback.
  const factory ThemeState.error(String message, ThemeData fallback) =
      ThemeError;
}

extension ThemeStateX on ThemeState {
  ThemeData? get themeOrNull => switch (this) {
        ThemeCached(:final theme) => theme,
        ThemeLoaded(:final theme) => theme,
        ThemeError(:final fallback) => fallback,
        _ => null,
      };
}
