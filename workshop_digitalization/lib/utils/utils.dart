///
/// This method takes a map and makes sure it does not have sub-maps as values.
/// if map['a']['b'] = c,
/// then in the returned map, we get newMap['a.b']=c
///
Map<String, dynamic> flattenMap(Map<String, dynamic> map) {
  // copy the map
  map = Map.from(map);

  var flattened;
  do {
    var newMap = Map<String, dynamic>();

    // if true, newMap does not contain values that are maps
    flattened = true;

    // go over all current entries
    for (var entry in map.entries) {
      // if this entry is a map (meaning we have to go down the tree)
      if (entry.value is Map<String, dynamic>) {
        // potentially newMap is not flattened
        flattened = false;

        // the prefix of each of the values should be the current key of the map
        var pathPrefix = entry.key;

        // we add into the new map each entry we find in the sub-map
        for (var subEntry in entry.value.entries) {
          newMap["$pathPrefix.${subEntry.key}"] = subEntry.value;
        }
      } else {
        // this is a flattened entry (meaning it does not contain a map)
        newMap[entry.key] = entry.value;
      }
    }

    map = newMap;
  } while (!flattened);

  return map;
}