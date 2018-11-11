
fan.sys.List.makeFromJs = function(type, array) {
	var list = fan.sys.List.make(array.length, type);
	for (var i in array) {
		list.add(i);
	}
	return list;
}