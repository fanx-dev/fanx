

fan.std.FileBufPeer.prototype.init = function(self, file, mode) {
	var reader = new FileReader();
	var buf = reader.readAsArrayBuffer(file);
	this.m_fp = new DataView(buf);
	this.m_pos = 0;
}

fan.std.FileBufPeer.prototype.size() = function(self) {
	this.fp.byteLength;
}

fan.std.FileBufPeer.prototype.size$() = function(self, x) {
}

fan.std.FileBufPeer.prototype.capacity() = function(self) {
	throw MAX_VALUE;
}

fan.std.FileBufPeer.prototype.capacity$() = function(self, capa) {
}

fan.std.FileBufPeer.prototype.pos() = function(self) {
	return this.m_pos;
}

fan.std.FileBufPeer.prototype.pos$() = function(self, x) {
	this.m_pos = x;
}

fan.std.FileBufPeer.prototype.getByte() = function(self, pos) {
	return this.m_pf.getUint8(pos)
}

fan.std.FileBufPeer.prototype.setByte() = function(self, pos, b) {
	this.m_pf.setUint8(pos, b);
}

fan.std.FileBufPeer.prototype.getBytes() = function(self, pos, dst, off, len) {
	var size = this.m_pf.byteLength-pos;
	if (size > len) size = len;

	for (var i=0; i<size; ++i) {
		dst.set(off+i, this.m_pf.getUint8(pos+i));
	}
	return size;
}

fan.std.FileBufPeer.prototype.setBytes() = function(self, pos, src, off, len) {
	var size = this.m_pf.byteLength-pos;
	if (size > len) size = len;

	for (var i=0; i<size; ++i) {
		this.m_pf.setUint8(pos+i, dst.get(off+i));
	}
	return size;
}

fan.std.FileBufPeer.prototype.close() = function(self) {
}

fan.std.FileBufPeer.prototype.sync() = function(self) {
}

