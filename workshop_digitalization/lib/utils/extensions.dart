extension CloneList on List {
  List clone() {
    return List.from(this);
  }
}

extension ReverseMap on Map {
  Map<V, K> inverse<K,V>() {
    return this.map((k, v) => MapEntry<V, K>(v, k));
  }
}