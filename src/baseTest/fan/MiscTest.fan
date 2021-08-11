
class MiscTest {
	Int a

	static Void main() {
		testCast
		testBoxing
		testMap
		testStrBuf
		testStrBuf2
		testStackTrace

		testUri
		testFileSystem
		testFile
		testDateTime
		testIncrement
		testLock
		testUuid
		testEnv
		testEnvPath

		testUriEq
		testWriteZip
		testOpenZip
		testReadZip
		testLiteral
	}

	static Void testLiteral() {
		echo(0.1)
		echo(MiscTest#)
		echo(MiscTest#main)
		echo(MiscTest#a)
		echo(10sec)
	}

	static Void testMd5() {
		str := Buf.make.print("password").print("salt").toDigest("MD5").toHex
		echo(str)
    	assert("b305cadbb3bce54f3aa59c64fec00dea" == str)
	}

	static Void testUriEq() {
		u1 := `/path/hello.txt`
		u2 := "/path/hello.txt".toUri
		echo(u1 == u2)

		map := Map.make(64)
		map.set(u2, "u2")
		val := map[`/path/hello.txt`]
		echo(val)
	}

	static Void testWriteZip() {
		file := `test.zip`.toFile
		zip := Zip.write(file.out)
	    out := zip.writeNext(`/path/hello.txt`)
	    out.printLine("hello zip")
	    out.close
	    zip.close
	}

	static Void testOpenZip() {
		file := `test.zip`.toFile
		zip := Zip.open(file)
		contents:= zip.contents
		echo(contents)

		key := contents.keys.first
		uri := `/path/hello.txt`
		echo(key == uri)

		txt := contents[`/path/hello.txt`]?.readAllStr
		echo(txt)
		zip.close
	}

	static Void testReadZip() {
		file := `test.zip`.toFile
		zip := Zip.read(file.in)
		File? entry
		while ((entry = zip.readNext()) != null)
		{
			echo("$entry size=$entry.size")
			echo(entry.readAllStr)
		}
		zip.close
	}

	static Void testOnExit() {
		file := File.createTemp
		file.out.printLine("HI").close
		echo(file)
		file.deleteOnExit
	}

	static Void testEnvPath() {
		echo(Env.cur.homeDir)
		echo(Env.cur.workDir)
		echo(Env.cur.tempDir)
	}

	static Void testEnv() {
		echo(Env.cur.user)
		Env.cur.out.printLine("Hi Env")
		echo(Env.cur.vars)
	}

	static Void testUuid() {
		uuid := Uuid()
		echo(uuid)
	}

	static Void testLock() {
		lock := Lock()
		lock.lock

		t := AtomicInt(10)
		t.increment
		echo(t)

		lock.unlock
	}

	static Void testIncrement() {
		i := 1
		echo(i++)
	}

	static Void testDateTime() {
		dt := DateTime.now
		str := dt.toStr
		echo(str)
		dt2 := DateTime(str)
		echo(dt2)
	}

	static Void testFile() {
		file := File.os("D:\\workspace\\temp\\frTest.txt")
		out := file.out
		out.printLine("Hello")
		out.close

		in := file.in
		str := in.readAllStr
		echo(str)
		in.close
	}

	static Void testUri() {
		uri := `/abc/name/`
		echo(uri)
	}

	static Void testFileSystem() {
		File file := File.os("D:\\workspace")
		echo(file)
		echo(file.size)
		echo(file.list)
	}

	static Void testCast() {
		Int? i := null
		Obj? obj := i
		Str? s := obj

		StrBuf? castNull := (StrBuf?)obj
		Bool isInstanceOf := i is Int?

		echo(castNull)
		echo(isInstanceOf)
	}

	static Void testBoxing() {
		Int a := 1
		echo(a.toStr)

		Int? b := 2
		echo(b.toStr)

		c := a + b
		echo(c)

		d := b + a
		echo(d)
	}

	static Void testMap() {
		map := [:]
		map["a"] = 1
		//map["b"] = 2

		echo(map)
	}

	static Void testStrBuf() {
		buf := StrBuf()
		buf.addChar('a')
		buf.addChar('b')

		i1 := buf[0]
		assert(i1 == 'a')
		i2 := buf[1]
		assert(i2 == 'b')

		str := buf.toStr
		assert(str == "ab")
	}

	static Void testStrBuf2() {
		a := "sys"
		b := [,]
		echo("addPod:$a $b")
	}

	static Void testStackTrace() {
		Err().trace
	}
}
