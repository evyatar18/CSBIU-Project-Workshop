// filter according to given input
typedef bool Filter<T>(T input);

// creates a filter according to given input
typedef Filter<T> FilterCreator<T, I>(I input);

Filter equalsFilter(dynamic toValue) {
  return (val) => val == toValue;
}

Filter<String> stringContains(String str) {
  return (val) => val.contains(str);
}

Filter<String> startsWith(String str) {
  return (val) => val.startsWith(str);
}

Filter<String> endsWith(String str) {
  return (val) => val.endsWith(str);
}

Filter<String> matches(String reg) {
  RegExp regex;

  try { regex = RegExp(reg); }
  catch (e) { regex = RegExp(""); }

  return (val) => regex.hasMatch(val);
}

Map<String, FilterCreator<String, String>> textFilters = {
  "equals": equalsFilter,
  "contains": stringContains,
  "starts-with": startsWith,
  "ends-with": endsWith,
  "matches": matches
};

Map<String, FilterCreator> selectionFilters = {
  "equals": equalsFilter
};