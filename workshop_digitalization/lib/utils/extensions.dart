extension CloneList on List {
  List<T> clone<T>() {
    return List.from(this);
  }
}

extension ReverseMap on Map {
  Map<V, K> inverse<K,V>() {
    return this.map((k, v) => MapEntry<V, K>(v, k));
  }
}