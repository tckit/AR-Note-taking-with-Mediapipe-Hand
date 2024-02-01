class ListStack<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);

  E pop() => _list.removeLast();

  E get top => _list.last;

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  int get length => _list.length;

  void clear() => _list.clear();

  E elementAt(int index) => _list.elementAt(index);

  @override
  String toString() => _list.toString();
}
