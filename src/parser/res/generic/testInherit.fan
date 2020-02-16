class Super<K,V> {
  V? val
  K? key

  virtual V? getFoo(K k) {
    if (k == key) return val
    return null
  }

  virtual Void set(K k, V v) {
    val = v
    key = k
  }
}

class Sub<K,V> : Super<K, V> {
  override Void set(K k, V v) {
    super.set(k, v)
  }
}

class Main {
  Void main() {
    nlist := Sub<Str, Int>()
    nlist.set("1", 1)
    x := nlist.getFoo("1")
    echo(x)
    echo(x.isEven)
  }
}