

fan.std.NioBufPeer.prototype.init = function(self, file, mode, pos, size) {
	var reader = new FileReader();
	var buf = reader.readAsArrayBuffer(file);
	this.m_fp = new DataView(buf, pos, pos + size);
	this.m_pos = 0;
}

fan.std.NioBufPeer.prototype.size() = function(self) {
	this.fp.byteLength;
}

fan.std.NioBufPeer.prototype.size$() = function(self, x) {
}

fan.std.NioBufPeer.prototype.capacity() = function(self) {
	throw MAX_VALUE;
}

fan.std.NioBufPeer.prototype.capacity$() = function(self, capa) {
}

fan.std.NioBufPeer.prototype.pos() = function(self) {
	return this.m_pos;
}

fan.std.NioBufPeer.prototype.pos$() = function(self, x) {
	this.m_pos = x;
}

fan.std.NioBufPeer.prototype.getByte() = function(self, pos) {
	return this.m_pf.getUint8(pos)
}

fan.std.NioBufPeer.prototype.setByte() = function(self, pos, b) {
	this.m_pf.setUint8(pos, b);
}

fan.std.NioBufPeer.prototype.getBytes() = function(self, pos, dst, off, len) {
	var size = this.m_pf.byteLength-pos;
	if (size > len) size = len;

	for (var i=0; i<size; ++i) {
		dst.set(off+i, this.m_pf.getUint8(pos+i));
	}
	return size;
}

fan.std.NioBufPeer.prototype.setBytes() = function(self, pos, src, off, len) {
	var size = this.m_pf.byteLength-pos;
	if (size > len) size = len;

	for (var i=0; i<size; ++i) {
		this.m_pf.setUint8(pos+i, dst.get(off+i));
	}
	return size;
}

fan.std.NioBufPeer.prototype.close() = function(self) {
}

fan.std.NioBufPeer.prototype.sync() = function(self) {
}

