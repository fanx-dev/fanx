@Js
native class FloatArray {

  ** Create a 32-bit float array.
  static FloatArray makeF4(Int size)

  ** Create a 64-bit float array.
  static FloatArray makeF8(Int size)

  ** Protected constructor for implementation classes
  internal new make()

  @Operator Float get(Int pos)

  @Operator Void set(Int pos, Float val)

  Int size()

  FloatArray realloc(Int newSize)

  This fill(Float val, Int times)

  This copyFrom(FloatArray that, Int thatOffset, Int thisOffset, Int length)

  protected override Void finalize()
}
@Js
native class IntArray {
  ** Create a signed 8-bit, 1-byte integer array (-128 to 127).
  static IntArray makeS1(Int size)

  ** Create a unsigned 8-bit, 1-byte integer array (0 to 255).
  static IntArray makeU1(Int size)

  ** Create a signed 16-bit, 2-byte integer array (-32_768 to 32_767).
  static IntArray makeS2(Int size)

  ** Create a unsigned 16-bit, 2-byte integer array (0 to 65_535).
  static IntArray makeU2(Int size)

  ** Create a signed 32-bit, 4-byte integer array (-2_147_483_648 to 2_147_483_647).
  static IntArray makeS4(Int size)

  ** Create a unsigned 32-bit, 4-byte integer array (0 to 4_294_967_295).
  static IntArray makeU4(Int size)

  ** Create a signed 64-bit, 8-byte integer array.
  static IntArray makeS8(Int size)

  ** Protected constructor for implementation classes
  internal new make()

  @Operator Int get(Int pos)

  @Operator Void set(Int pos, Int val)

  Int size()

  IntArray realloc(Int newSize)

  This fill(Int val, Int times)

  This copyFrom(IntArray that, Int thatOffset, Int thisOffset, Int length)

  protected override Void finalize()
}
@Js
class BoolArray {
  private Int _size
  private IntArray words

  new make(Int size) {
    _size = size
    isize := (size.shiftr(0x5)) + 1
    words = IntArray.makeS4(isize)
  }

  @Operator Bool get(Int pos) {
    i := pos.shiftr(0x5);
    mask := 1.shiftl(pos.and(0x1F))
    return words[i].and(mask) != 0
  }

  @Operator Void set(Int pos, Bool val) {
    i := pos.shiftr(0x5);
    mask := 1.shiftl(pos.and(0x1F))
    if (val)
      words[i] = words[i].or(mask);
    else
      words[i] = words[i].and(mask.not);
  }

  Int size() { _size }

  BoolArray realloc(Int newSize) {
    if (_size == newSize)
      return this;
    isize := (newSize.shiftr(0x5)) + 1
    words = words.realloc(isize)
    _size = newSize
    return this;
  }

  This fill(Bool val, Int times) {
    for (i := 0; i < times; ++i) {
      set(i, val)
    }
    return this
  }

  This copyFrom(BoolArray that, Int thatOffset, Int thisOffset, Int length) {
    thatOff := (thatOffset.shiftr(0x5))
    thisOff := (thisOffset.shiftr(0x5))
    len := (length.shiftr(0x5)) + 1;
    words.copyFrom(that.words, thatOff, thisOff, len)
    return this
  }

  ** Set entire array to false
  This clear() {
    for (i:=0; i<words.size; ++i) words[i] = 0;
    return this
  }

  ** Iterate each index set to true
  Void eachTrue(|Int index| f) {
    for (i:=0; i<words.size; ++i)
    {
      if (words[i] == 0) continue
      for (j:=0; j<32; ++j)
      {
        index := (i.shiftl(0x05)) + j
        if (get(index)) f.call(index)
      }
    }
  }
  ** Set the value at given index and return the previous value.
  Bool getAndSet(Int pos, Bool val) {
    i := pos.shiftr(0x5);
    mask := 1.shiftl(pos.and(0x1F))
    prev := words[i].and(mask) != 0
    if (val)
      words[i] = words[i].or(mask);
    else
      words[i] = words[i].and(mask.not);
    return prev
  }
}