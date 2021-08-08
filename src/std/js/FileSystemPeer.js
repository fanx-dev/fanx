fan.std.FileSystemPeer = function(){}

fan.std.FileSystemPeer.exists = function(path) {
	return true;
}
fan.std.FileSystemPeer.size = function(path) {
	return 0;
}
fan.std.FileSystemPeer.modified = function(path) {
	return 0;
}
fan.std.FileSystemPeer.setModified = function(path, time) {
	return true;
}
fan.std.FileSystemPeer.uriToPath = function(uri) {
	return uri;
}
fan.std.FileSystemPeer.pathToUri = function(ospath) {
	return ospath;
}
fan.std.FileSystemPeer.list = function(path) {
	var list = fan.sys.List.make(1);
	return list;
}
fan.std.FileSystemPeer.normalize = function(path) {
	return path;
}
fan.std.FileSystemPeer.createDirs = function(path) {
	return false;
}
fan.std.FileSystemPeer.createFile = function(path) {
	return false;
}
fan.std.FileSystemPeer.moveTo = function(path, to) {
	return false;
}
fan.std.FileSystemPeer.copyTo = function(path, to) {
	return false;
}
fan.std.FileSystemPeer.delete = function(path) {
	return true
}
fan.std.FileSystemPeer.isReadable = function(path) {
	return true;
}
fan.std.FileSystemPeer.isWritable = function(path) {
	return true;
}
fan.std.FileSystemPeer.isExecutable = function(path) {
	return false;
}
fan.std.FileSystemPeer.isDir = function(path) {
	return false;
}
fan.std.FileSystemPeer.tempDir = function() {
	return "/temp/"
}
fan.std.FileSystemPeer.osRoots = function(osPath) {
	var list = fan.sys.List.make(1);
	list.add("/");
	return list;
}
fan.std.FileSystemPeer.getSpaceInfo = function(path, out) {
	a[0] = 0;
	a[1] = 0;
	a[2] = 0;
}
fan.std.FileSystemPeer.fileSep = function() {
	return "/";
}
fan.std.FileSystemPeer.pathSep = function() {
	return ":";
}
