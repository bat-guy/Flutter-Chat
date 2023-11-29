extension MapExtension on Map {
  valueOrNull(String key) => containsKey(key) ? this[key] : null;
}
