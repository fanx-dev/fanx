


**
** Raw pointer for C FFI
**
@NoDoc
const native struct class Ptr<T> {
  static const Ptr nil
  private new make()

  static Ptr<Int8> stackAlloc(Int size)

  T val

  @Operator This plus(Int b)

  @Operator Void set(Int index, T item)
  @Operator T get(Int index)
}
