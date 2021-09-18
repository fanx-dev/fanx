//
// Copyright (c) 2021, chunquedong
// Licensed under the LGPL
// History:
//   2021-9-18  Jed Young  Creation
//

class DurationExtI {
	static extension Duration ns(Int v) { Duration.fromNanos(v) }
	static extension Duration ms(Int v) { Duration.fromMillis(v) }
	static extension Duration sec(Int v) { Duration.fromSec(v) }
	static extension Duration mins(Int v) { Duration.fromMin(v) }
	static extension Duration hr(Int v)  { Duration.fromHour(v) }
	static extension Duration day(Int v) { Duration.fromDay(v) }
}

class DurationExtF {
	static extension Duration ns(Float v) { Duration.fromNanos(v.toInt) }
	static extension Duration ms(Float v) { Duration.fromMillis(v.toInt) }
	static extension Duration sec(Float v) { Duration.fromMillis((v * Duration.milliPerSec).toInt) }
	static extension Duration mins(Float v) { Duration.fromMillis((v * Duration.milliPerMin).toInt) }
	static extension Duration hr(Float v)  { Duration.fromMillis((v * Duration.milliPerHr).toInt) }
	static extension Duration day(Float v) { Duration.fromMillis((v * Duration.milliPerDay).toInt) }
}
