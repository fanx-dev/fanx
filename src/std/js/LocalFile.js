
fan.std.LocalFile = function(){}

fan.std.LocalFile.make = function(file, uri, checked) {
	var f = new fan.std.LocalFile();
	f._uri = uri;
	return f;
}

fan.std.LocalFile.store = function() {
	return new fan.std.FileStore();
}

fan.std.LocalFile.size = function() {
	return this.file.size;
}

fan.std.LocalFile.exists = function() {
	return true;
}


fan.std.LocalFile.modified = function() {
	var mills = this.lastModified;
	return fan.std.TimePoint.fromMillis(mills);
}

fan.std.LocalFile.modified$ = function(time) {
}

fan.std.LocalFile.osPath = function() {
	return this.file.webkitRelativePath;
}

fan.std.LocalFile.list = function() {
	return fan.sys.List.make(0);
}

fan.std.LocalFile.normalize = function() {
	return this;
}

fan.std.LocalFile.createFile = function() {
	return this;
}

fan.std.LocalFile.createDir = function() {
	return this;
}

fan.std.LocalFile.create = function() {
	if (this.isDir())
		fan.std.LocalFile.createDir(jfile);
	else
		fan.std.LocalFile.createFile(jfile);
	return this;
}

fan.std.LocalFile.moveTo = function(to) {
	return to;
}

fan.std.LocalFile.delete = function() {
}

fan.std.LocalFile.deleteOnExit = function() {
}

fan.std.LocalFile.in = function() {
	throw fan.sys.UnsupportedErr.make("");
}

fan.std.LocalFile.out = function() {
	throw fan.sys.UnsupportedErr.make("");
}

