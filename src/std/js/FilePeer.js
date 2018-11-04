fan.std.FilePeer = function(){}


fan.std.FilePeer.make = function(uri, checkSlash) {
	if (checkSlash == undefined) checkSlash = true;
	self = fan.std.File.make();
	self.m_file = new File("", uri.toStr());
	return self;
}

fan.std.FilePeer.os = function(osPath) {
	self = fan.std.File.make();
	self.m_file = new File("", osPath);
	return self;
}

fan.std.FilePeer.osRoots = function(osPath) {
	return new fan.sys.List.make();
}

fan.std.FilePeer.createTemp = function(prefix, suffix, dir) {
	if (prefix == null || prefix.length() == 0)
		prefix = "fan";
	if (prefix.length() == 1)
		prefix = prefix + "xx";
	if (prefix.length() == 2)
		prefix = prefix + "x";

	if (suffix == null)
		suffix = ".tmp";

	if (dir != null) {
		return dir + suffix;
	}

	return fan.std.FilePeer.os("/temp/"+suffix);
}

fan.std.FilePeer.sep = function() {
	return "/";
}


fan.std.FilePeer.pathSep = function() {
	return ":";
}

fan.std.FilePeer.plusNameOf = function(self, x) {
	var name = x.name();
	if (x.isDir())
		name += "/";
	return self.plus(Uri.fromStr(name));
}

fan.std.FilePeer.copyTo = function(self, to, options) {
	
}
