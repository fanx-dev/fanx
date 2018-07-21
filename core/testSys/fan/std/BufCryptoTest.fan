//
// Copyright (c) 2016, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Feb 16  Matthew Giannini   Creation
//

**
** BufCryptoTest
**
class BufCryptoTest : AbstractBufTest
{

//////////////////////////////////////////////////////////////////////////
// Base64
//////////////////////////////////////////////////////////////////////////

  Void testBase64()
  {
    verifyBase64("", "");
    verifyBase64("Man", "TWFu");
    verifyBase64("@", "QA==")
    verifyBase64("[]", "W10=")
    verifyBase64("brian", "YnJpYW4=")
    verifyBase64("hey!", "aGV5IQ==")
    verifyBase64("123456", "MTIzNDU2")
    verifyBase64("SecretPassword", "U2VjcmV0UGFzc3dvcmQ=")
    verifyBase64("su?_d=1~~", "c3U/X2Q9MX5+")
    verifyBase64(
      "Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.",
      "TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=")

    buf := Buf.make
    300.times |Int i| { buf.write(i) }
    buf.flip
    verifyBufEq(BufCrypto.fromBase64(buf.toBase64), buf)
  }

  Void verifyBase64(Str src, Str base64)
  {
    safe := base64.replace("=", "").replace("+", "-").replace("/", "_")

    verifyEq(makeMem.print(src).toBase64, base64)
    verifyEq(makeMem.print(src).toBase64Uri, safe)

    verifyBufEq(BufCrypto.fromBase64(base64), Buf.make.print(src))
    verifyBufEq(BufCrypto.fromBase64(safe), Buf.make.print(src))

    breaks := StrBuf.make
    base64.each |Int ch, Int i| { breaks.addChar(ch); if (i % 3 == 0) breaks.add("\uabcd\r\n") }
    verifyBufEq(BufCrypto.fromBase64(breaks.toStr), ascii(src))
  }

//////////////////////////////////////////////////////////////////////////
// Digest
//////////////////////////////////////////////////////////////////////////

  Void testDigestMD5()
  {
    verifyDigest("fan", "MD5",
      "50bd8c21bfafa6e4e962f6a948b1ef92")
  }

  Void testDigestSHA1()
  {
    // standard test vectors
    verifyDigest("abc", "SHA-1",
     "a9993e364706816aba3e25717850c26c9cd0d89d")
    // standard - empty buf
    verifyDigest("", "SHA-1",
     "da39a3ee5e6b4b0d3255bfef95601890afd80709")
    // standard - 448 bits
    verifyDigest("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq", "SHA-1",
     "84983e441c3bd26ebaae4aa1f95129e5e54670f1")
    // standard - 896 bits
    verifyDigest("abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu", "SHA-1",
     "a49b2446a02c645bf419f995b67091253a04a259")
    // 'a' 1,000,000 times - takes too long to run in js
    if (!isJs)
    {
      verifyDigest(Buf().fill('a', 1_000_000).flip.readAllStr, "SHA-1",
        "34aa973cd4c4daa4f61eeb2bdbad27316534016f")
    }
  }

  Void testDigestSHA256()
  {
    // standard test vectors
    verifyDigest("abc", "SHA-256",
      "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
    // standard - empty buf
    verifyDigest("", "SHA-256",
      "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    // standard - 448 bits
    verifyDigest("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq", "SHA-256",
      "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1")
    // standard - 896 bits
    verifyDigest("abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu", "SHA-256",
     "cf5b16a778af8380036ce59e7b0492370b249b11e8f07a51afac45037afee9d1")
    // 'a' 1,000,000 times - takes too long to run in js
    if (!isJs)
    {
      verifyDigest(Buf().fill('a', 1_000_000).flip.readAllStr, "SHA-256",
        "cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0")
    }
  }

  Void testBadDigest()
  {
    verifyErr(ArgErr#) { ascii("foo").toDigest("Foo Digest!") }
  }

  Void verifyDigest(Str text, Str algorithm, Str digest)
  {
    verifyEq(makeMem.print(text).toDigest(algorithm).toHex, digest)
    verifyEq(makeFile.print(text).toDigest(algorithm).toHex, digest)
  }

//////////////////////////////////////////////////////////////////////////
// HMAC
//////////////////////////////////////////////////////////////////////////

  Void testHmacMD5()
  {
    // tests from RFC 2202 http://www.faqs.org/rfcs/rfc2202.html
    verifyHmac("Hi There".toBuf,
               Buf().fill(0x0b, 16), "MD5",
               "9294727a3638bb1c13f48ef8158bfc9d")

    verifyHmac("what do ya want for nothing?".toBuf,
               "Jefe".toBuf, "MD5",
               "750c783e6ab0b503eaa86e310a5db738")

    verifyHmac(Buf().fill(0xdd, 50),
               Buf().fill(0xaa, 16), "MD5",
               "56be34521d144c88dbb8c733f0e8b3f6")

    verifyHmac(Buf().fill(0xcd, 50),
               Buf.fromHex("0102030405060708090a0b0c0d0e0f10111213141516171819"), "MD5",
               "697eaf0aca3a3aea3a75164746ffaa79")

    verifyHmac("Test With Truncation".toBuf,
               Buf().fill(0x0c, 16), "MD5",
               "56461ef2342edc00f9bab995690efd4c")

    verifyHmac("Test Using Larger Than Block-Size Key - Hash Key First".toBuf,
               Buf().fill(0xaa, 80), "MD5",
               "6b1ab7fe4bd7bf8f0b62e6ce61b9d0cd")

    verifyHmac("Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data".toBuf,
               Buf().fill(0xaa, 80), "MD5",
               "6f630fad67cda0ee1fb1f562db3aa53e")
  }

  Void testHmacSHA1()
  {
    // tests from RFC 2202 http://www.faqs.org/rfcs/rfc2202.html
    verifyHmac("Hi There".toBuf,
               Buf().fill(0x0b, 20), "SHA1",
               "b617318655057264e28bc0b6fb378c8ef146be00")

    verifyHmac("what do ya want for nothing?".toBuf,
               "Jefe".toBuf, "SHA1",
               "effcdf6ae5eb2fa2d27416d5f184df9c259a7c79")

    verifyHmac(Buf().fill(0xdd, 50),
               Buf().fill(0xaa, 20), "SHA1",
               "125d7342b9ac11cd91a39af48aa17b4f63f175d3")

    verifyHmac(Buf().fill(0xcd, 50),
               Buf.fromHex("0102030405060708090a0b0c0d0e0f10111213141516171819"), "SHA1",
               "4c9007f4026250c6bc8414f9bf50c86c2d7235da")

    verifyHmac("Test With Truncation".toBuf,
               Buf().fill(0x0c, 20), "SHA1",
               "4c1a03424b55e07fe7f27be1d58bb9324a9a5a04")

    verifyHmac("Test Using Larger Than Block-Size Key - Hash Key First".toBuf,
               Buf().fill(0xaa, 80), "SHA1",
               "aa4ae5e15272d00e95705637ce8a3b55ed402112")

    verifyHmac("Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data".toBuf,
               Buf().fill(0xaa, 80), "SHA1",
               "e8e99d0f45237d786d6bbaa7965c7808bbff1a91")
  }

  Void testHmacSHA256()
  {
    // tests from https://tools.ietf.org/html/rfc4868
    verifyHmac("Hi There".toBuf,
               Buf().fill(0x0b, 20), "SHA-256",
               "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7")

    verifyHmac("what do ya want for nothing?".toBuf,
               "Jefe".toBuf, "SHA-256",
               "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843")

    verifyHmac(Buf().fill(0xdd, 50),
               Buf().fill(0xaa, 20), "SHA-256",
               "773ea91e36800e46854db8ebd09181a72959098b3ef8c122d9635514ced565fe")

    verifyHmac(Buf().fill(0xcd, 50),
               Buf.fromHex("0102030405060708090a0b0c0d0e0f10111213141516171819"), "SHA-256",
               "82558a389a443c0ea4cc819899f2083a85f0faa3e578f8077a2e3ff46729665b")

    verifyHmac("Test Using Larger Than Block-Size Key - Hash Key First".toBuf,
               Buf().fill(0xaa, 131), "SHA-256",
               "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54")

    verifyHmac("This is a test using a larger than block-size key and a larger than block-size data. The key needs to be hashed before being used by the HMAC algorithm.".toBuf,
               Buf().fill(0xaa, 131), "SHA-256",
               "9b09ffa71b942fcb27635fbcd5b0e944bfdc63644f0713938a7f51535c3a35e2")
  }

  Void testBadHmac()
  {
    verifyErr(ArgErr#) { "Hi There".toBuf.hmac("SHA-X", "password".toBuf) }
  }

  Void verifyHmac(Buf data, Buf key, Str algorithm, Str expected)
  {
    verifyEq(data.hmac(algorithm, key).toHex, expected)
  }

//////////////////////////////////////////////////////////////////////////
// PBK
//////////////////////////////////////////////////////////////////////////

  Void testPBKDF2WithHmacSHA1()
  {
    // tests from RFC 6070
    verifyPbk("PBKDF2WithHmacSHA1", "password", "salt".toBuf, 1, 20,
      "0c 60 c8 0f 96 1f 0e 71 f3 a9 b5 24 af 60 12 06 2f e0 37 a6")
    verifyPbk("PBKDF2WithHmacSHA1", "password", "salt".toBuf, 4096, 20,
      "4b 00 79 01 b7 65 48 9a be ad 49 d9 26 f7 21 d0 65 a4 29 c1")
    verifyPbk("PBKDF2WithHmacSHA1", "passwordPASSWORDpassword", "saltSALTsaltSALTsaltSALTsaltSALTsalt".toBuf, 4096, 25,
      "3d 2e ec 4f e4 1c 84 9b 80 c8 d8 36 62 c0 e4 4a 8b 29 1a 96 4c f2 f0 70 38")
  }

  Void testPBKDF2WithHmacSHA256()
  {
    // http://stackoverflow.com/questions/5130513/pbkdf2-hmac-sha2-test-vectors/5136918#5136918
    verifyPbk("PBKDF2WithHmacSHA256", "password", "salt".toBuf, 1, 32,
      "12 0f b6 cf fc f8 b3 2c 43 e7 22 52 56 c4 f8 37 a8 65 48 c9 2c cc 35 48 08 05 98 7c b7 0b e1 7b")
    verifyPbk("PBKDF2WithHmacSHA256", "password", "salt".toBuf, 4096, 32,
      "c5 e4 78 d5 92 88 c8 41 aa 53 0d b6 84 5c 4c 8d 96 28 93 a0 01 ce 4e 11 a4 96 38 73 aa 98 13 4a")
    verifyPbk("PBKDF2WithHmacSHA256", "passwordPASSWORDpassword", "saltSALTsaltSALTsaltSALTsaltSALTsalt".toBuf, 4096, 40,
      "34 8c 89 db cb d3 2b 2f 32 d8 14 b8 11 6e 84 cf 2b 17 34 7e bc 18 00 18 1c 4e 2a 1f b8 dd 53 e1 c6 35 51 8c 7d ac 47 e9")
    verifyPbk("PBKDF2WithHmacSHA256", "pencil", BufCrypto.fromBase64("W22ZaJ0SNY7soEsUEjb6gQ=="), 4096, 32,
      "c4a49510323ab4f952cac1fa99441939e78ea74d6be81ddf7096e87513dc615d")
  }

  Void verifyPbk(Str algorithm, Str pass, Buf salt, Int iterations, Int keyLen, Str expected)
  {
    expected = expected.replace(" ", "")
    actual := BufCrypto.pbk(algorithm, pass, salt, iterations, keyLen).toHex
    /*
    echo(">>>> $algorithm $pass $iterations $keyLen")
    echo("     $actual")
    echo("     $expected")
    */
    verifyEq(actual, expected)
  }
}