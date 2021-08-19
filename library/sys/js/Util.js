
fan.sys.List.makeFromJs = function(array) {
	var list = fan.sys.List.make(array.length);
	for(var i= 0; i<array.length; ++i){
		list.add(array[i]);
	}
	return list;
}

fan.sys.List.orign_make = fan.sys.List.make;
fan.sys.List.make = function(arg1, arg2) {
	if (arg1 instanceof fan.std.Type) {
		if (arg2 instanceof Array) {
			return fan.sys.List.makeFromJs(arg2);
		}
		else if (arg2 === undefined) {
			return fan.sys.List.orign_make(1);
		}
		else {
			throw "unkonw args:"+args2;
		}
	}
	return fan.sys.List.orign_make(arg1);
}

fan.sys.List.prototype.toJs = function() {
	return this.m_array.m_array;
}