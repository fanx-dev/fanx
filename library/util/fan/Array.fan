@Js @JsNative
abstract class FloatArray {

  ** Create a 32-bit float array.
  static FloatArray makeF4(Int size) { F4(size) }

  ** Create a 64-bit float array.
  static FloatArray makeF8(Int size) { F8(size) }

  ** Protected constructor for implementation classes
  internal new make() {}

  @Operator abstract Float get(Int pos)

  @Operator abstract Void set(Int pos, Float val)

  abstract Int size()

  abstract FloatArray realloc(Int newSize)

  virtual This fill(Float val, Int times) {
    t := times;
    for (i := 0; i < t; ++i) {
      set(i, val);
    }
    return this;
  }

  abstract This copyFrom(FloatArray that, Int thatOffset, Int thisOffset, Int length)

  //protected override Void finalize()
}

internal class F4 : FloatArray {
  protected Array<Float32> array
  new make(Int size) { array = Array<Float32>(size) }

  @Operator override Float get(Int pos) { array[pos] }
  @Operator override Void set(Int pos, Float val) { array[pos] = val }
  override Int size() { array.size }

  override FloatArray realloc(Int newSize) {
    if (array.size == newSize) return this;
    F4 na = F4(newSize);
    Int len = array.size > na.array.size ? na.array.size : array.size;
    Array.arraycopy(array, 0, na.array, 0, len);
    return na;
  }

  override This copyFrom(FloatArray that, Int thatOffset, Int thisOffset, Int length) {
    Array.arraycopy(((F4) that).array, thatOffset, array, thisOffset, length);
    return this;
  }
}

internal class F8 : FloatArray {
  protected Array<Float64> array
  new make(Int size) { array = Array<Float64>(size) }

  @Operator override Float get(Int pos) { array[pos] }
  @Operator override Void set(Int pos, Float val) { array[pos] = val }
  override Int size() { array.size }

  override FloatArray realloc(Int newSize) {
    if (array.size == newSize) return this;
    na := F8(newSize);
    Int len = array.size > na.array.size ? na.array.size : array.size;
    Array.arraycopy(array, 0, na.array, 0, len);
    return na;
  }

  override This copyFrom(FloatArray that, Int thatOffset, Int thisOffset, Int length) {
    Array.arraycopy(((F8) that).array, thatOffset, array, thisOffset, length);
    return this;
  }
}


@Js @JsNative
abstract class IntArray {
  ** Create a signed 8-bit, 1-byte integer array (-128 to 127).
  static IntArray makeS1(Int size) { S1(size) }

  ** Create a unsigned 8-bit, 1-byte integer array (0 to 255).
  static IntArray makeU1(Int size) { U1(size) }

  ** Create a signed 16-bit, 2-byte integer array (-32_768 to 32_767).
  static IntArray makeS2(Int size) { S2(size) }

  ** Create a unsigned 16-bit, 2-byte integer array (0 to 65_535).
  static IntArray makeU2(Int size) { U2(size) }

  ** Create a signed 32-bit, 4-byte integer array (-2_147_483_648 to 2_147_483_647).
  static IntArray makeS4(Int size) { S4(size) }

  ** Create a unsigned 32-bit, 4-byte integer array (0 to 4_294_967_295).
  static IntArray makeU4(Int size) { U4(size) }

  ** Create a signed 64-bit, 8-byte integer array.
  static IntArray makeS8(Int size) { S8(size) }

  ** Protected constructor for implementation classes
  internal new make() {}

  @Operator abstract Int get(Int pos)

  @Operator abstract Void set(Int pos, Int val)

  abstract Int size()

  abstract IntArray realloc(Int newSize)

  virtual This fill(Int val, Int times) {
    t := times;
    for (i := 0; i < t; ++i) {
      set(i, val);
    }
    return this;
  }

  abstract This copyFrom(IntArray that, Int thatOffset, Int thisOffset, Int length)

  //protected override Void finalize()
}

internal class S1 : IntArray {
  protected Array<Int8> array
  new make(Int size) { array = Array<Int8>(size) }

  @Operator override Int get(Int pos) { array[pos] }
  @Operator override Void set(Int pos, Int val) { array[pos] = val }
  override Int size() { array.size }

  override IntArray realloc(Int newSize) {
    if (array.size == newSize) return this;
    na := create(newSize);
    Int len = array.size > na.array.size ? na.array.size : array.size;
    Array.arraycopy(array, 0, na.array, 0, len);
    return na;
  }

  protected virtual S1 create(Int newSize) { S1(newSize) }

  override This copyFrom(IntArray that, Int thatOffset, Int thisOffset, Int length) {
    Array.arraycopy(((S1) that).array, thatOffset, array, thisOffset, length);
    return this;
  }
}

internal class S2 : IntArray {
  protected Array<Int16> array
  new make(Int size) { array = Array<Int16>(size) }

  @Operator override Int get(Int pos) { array[pos] }
  @Operator override Void set(Int pos, Int val) { array[pos] = val }
  override Int size() { array.size }

  override IntArray realloc(Int newSize) {
    if (array.size == newSize) return this;
    na := create(newSize);
    Int len = array.size > na.array.size ? na.array.size : array.size;
    Array.arraycopy(array, 0, na.array, 0, len);
    return na;
  }

  protected virtual S2 create(Int newSize) { S2(newSize) }

  override This copyFrom(IntArray that, Int thatOffset, Int thisOffset, Int length) {
    Array.arraycopy(((S2) that).array, thatOffset, array, thisOffset, length);
    return this;
  }
}

internal class S4 : IntArray {
  protected Array<Int32> array
  new make(Int size) { array = Array<Int32>(size) }

  @Operator override Int get(Int pos) { array[pos] }
  @Operator override Void set(Int pos, Int val) { array[pos] = val }
  override Int size() { array.size }

  override IntArray realloc(Int newSize) {
    if (array.size == newSize) return this;
    na := create(newSize);
    Int len = array.size > na.array.size ? na.array.size : array.size;
    Array.arraycopy(array, 0, na.array, 0, len);
    return na;
  }

  protected virtual S4 create(Int newSize) { S4(newSize) }

  override This copyFrom(IntArray that, Int thatOffset, Int thisOffset, Int length) {
    Array.arraycopy(((S4) that).array, thatOffset, array, thisOffset, length);
    return this;
  }
}

internal class S8 : IntArray {
  protected Array<Int64> array
  new make(Int size) { array = Array<Int64>(size) }

  @Operator override Int get(Int pos) { array[pos] }
  @Operator override Void set(Int pos, Int val) { array[pos] = val }
  override Int size() { array.size }

  override IntArray realloc(Int newSize) {
    if (array.size == newSize) return this;
    na := S8(newSize);
    Int len = array.size > na.array.size ? na.array.size : array.size;
    Array.arraycopy(array, 0, na.array, 0, len);
    return na;
  }

  override This copyFrom(IntArray that, Int thatOffset, Int thisOffset, Int length) {
    Array.arraycopy(((S8) that).array, thatOffset, array, thisOffset, length);
    return this;
  }
}

internal class U1 : S1 {
  new make(Int size) : super.make(size) {}
  @Operator override Int get(Int pos) { array[pos].and(0xFF) }
  override protected S1 create(Int newSize) { U1(newSize) }
}

internal class U2 : S2 {
  new make(Int size) : super.make(size) {}
  @Operator override Int get(Int pos) { array[pos].and(0xFFFF) }
  override protected S2 create(Int newSize) { U2(newSize) }
}

internal class U4 : S4 {
  new make(Int size) : super.make(size) {}
  @Operator override Int get(Int pos) { array[pos].and(0xFFFFFFFF) }
  override protected S4 create(Int newSize) { U4(newSize) }
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