


**
** Raw pointer for C FFI
**
@NoDoc
const native struct class Ptr<T> {
  static const Ptr<T> nil
  private new make()

  static Ptr<Int8> stackAlloc(Int size)

  T load()
  Void store(T v)

  @Operator Ptr<T> plus(Int b)

  @Operator Void set(Int index, T item)
  @Operator T get(Int index)
}
