
fan.std.LocalFilePeer = function(){}


fan.std.LocalFilePeer.init = function(self) {
	var path = self.uri().m_pathStr;
	self.peer = new File("", uri.toStr());
}

fan.std.LocalFilePeer.make = function(file, uri) {
	var f = new fan.std.LocalFile();
	f.peer = file;
	f._uri = uri;
	return f;
}

fan.std.LocalFilePeer.store = function(self) {
	return new fan.std.FileStore();
}

fan.std.LocalFilePeer.size = function(self) {
	return self.peer.size;
}

fan.std.LocalFilePeer.exists = function(self) {
	return true;
}


fan.std.LocalFilePeer.modified = function(self) {
	var mills = self.peer.lastModified;
	return fan.std.TimePoint.fromMillis(mills);
}

fan.std.LocalFilePeer.modified$ = function(self, time) {
}

fan.std.LocalFilePeer.osPath = function(self) {
	return self.peer.webkitRelativePath;
}

fan.std.LocalFilePeer.list = function(self) {
	return fan.sys.List.make(0);
}

fan.std.LocalFilePeer.normalize = function(self) {
	return self;
}

fan.std.LocalFilePeer.createFile = function(self) {
	return self;
}

fan.std.LocalFilePeer.createDir = function(self) {
	return self;
}

fan.std.LocalFilePeer.create = function(self) {
	if (self.isDir())
		fan.std.LocalFilePeer.createDir(jfile);
	else
		fan.std.LocalFilePeer.createFile(jfile);
	return self;
}

fan.std.LocalFilePeer.moveTo = function(self, to) {
	return to;
}

fan.std.LocalFilePeer.delete = function(self, to) {
}

fan.std.LocalFilePeer.deleteOnExit = function(self, to) {
}

fan.std.LocalFilePeer.in = function(self, to) {
	throw fan.sys.UnsupportedErr.make("");
}

fan.std.LocalFilePeer.out = function(self, to) {
	throw fan.sys.UnsupportedErr.make("");
}

