/// Defines the general form of a filter,
///
/// a filter recieves an input and outputs `true` if the input passes
/// and `false` if the input does not pass
typedef bool Filter<T>(T input);

/// Creates a filter from a given input
typedef Filter<T> FilterCreator<T, I>(I input);

/*
 * This file contains different filter creators
 */

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

Filter<String> fullRegex(String reg) {
  RegExp regex;

  if (!reg.startsWith("^"))
    reg = "^" + reg;

  if (!reg.endsWith("\$"))
    reg = reg + "\$";

  try { regex = RegExp(reg); }
  catch (e) { regex = RegExp(""); }

  return (val) => regex.hasMatch(val);
}

/// all the filters used for text fields
Map<String, FilterCreator<String, String>> textFilters = {
  "equals": equalsFilter,
  "contains": stringContains,
  "starts-with": startsWith,
  "ends-with": endsWith,
  "contains-regex": matches,
  "regex": fullRegex,
};

/// all the filters used for selection fields
Map<String, FilterCreator> selectionFilters = {
  "equals": equalsFilter
};