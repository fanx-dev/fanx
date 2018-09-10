//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-07-14  Jed Young
//

class BufCrypto {
  private const static Str base64chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  private const static Str base64UriChars := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
  private static const Int[] base64inv
  static
  {
    t := Int[,].fill(-1, 128)
    for (i:=0; i<base64chars.size; ++i) t[base64chars[i]] = i
    t['-'] = 62
    t['_'] = 63
    t['='] = 0
    base64inv = t
  }

  **
  ** Encode the buffer contents from 0 to size to a Base64
  ** string as defined by MIME RFC 2045.  No line breaks are
  ** added.  This method is only supported by memory backed
  ** buffers, file backed buffers will throw UnsupportedErr.
  **
  ** Example:
  **   Buf.make.print("Fan").toBase64    => "RmFu"
  **   Buf.fromBase64("RmFu").readAllStr => "Fan"
  **
  static extension Str toBase64(Buf buf) { doBase64(buf, base64chars, true) }

  ** Encode the buffer contents from 0 to size to a
  ** Uri-safe Base64 string as defined by RFC 4648.
  ** This means '+' is encoded as '-', and '/' is
  ** encoded as '_'. Additionally, no padding is applied.
  ** This method is only supported by memory-backed buffers;
  ** file-backed buffers will throw UnsupportedErr.
  **
  ** Example:
  **   Buf.make.print("safe base64~~").toBase64    => "c2FmZSBiYXNlNjR+fg=="
  **   Buf.make.print("safe base64~~").toBase64Uri => "c2FmZSBiYXNlNjR-fg"
  **
  static extension Str toBase64Uri(Buf buf) { doBase64(buf, base64UriChars, false) }


  private static Str doBase64(Buf self, Str table, Bool pad) {
    buf := self.unsafeArray
    size := self.size
    s := StrBuf(size*2)
    i := 0
    // append full 24-bit chunks
    end := size-2
    for (; i<end; i += 3)
    {
      n := buf[i].and(0xff).shiftl(16) + buf[i+1].and(0xff).shiftl(8) + buf[i+2].and(0xff)
      s.addChar(table[n.shiftr(18).and(0x3f)])
       .addChar(table[n.shiftr(12).and(0x3f)])
       .addChar(table[n.shiftr(6).and(0x3f)])
       .addChar(table[n.and(0x3f)])
    }

    // pad and encode remaining bits
    rem := size - i
    if (rem > 0)
    {
      n := buf[i].and(0xff).shiftl(10).or(rem == 2 ? buf[size-1].and(0xff).shiftl(2) : 0)
      s.addChar(table[n.shiftr(12).and(0x3f)])
       .addChar(table[n.shiftr(6).and(0x3f)])
      if (rem == 2) {
        s.addChar(table[n.and(0x3f)])
      }
      else if (pad) s.addChar('=')

      if (pad) s.addChar('=')
    }

    return s.toStr
  }


  **
  ** Decode the specified Base64 string into its binary contents
  ** as defined by MIME RFC 2045.  Any characters which are not
  ** included in the Base64 character set are safely ignored.
  **
  ** Example:
  **   Buf.make.print("Fan").toBase64    => "RmFu"
  **   Buf.fromBase64("RmFu").readAllStr => "Fan"
  **
  static Buf fromBase64(Str s) {
    slen := s.size
    si := 0
    max := slen * 6 / 8
    buf := ByteArray(max)
    size := 0

    while (si < slen) {
      n := 0
      v := 0
      for (j:=0; j<4 && si<slen;) {
        ch := s[si++]
        c := ch < 128 ? base64inv[ch] : -1
        if (c >= 0) {
          n = n.or(c.shiftl(18 - (j++) * 6))
          if (ch != '=') v++
        }
      }

      if (v > 1) buf[size++] = n.shiftr(16)
      if (v > 2) buf[size++] = n.shiftr(8)
      if (v > 3) buf[size++] = n
    }

    return MemBuf(buf, size)
  }

  **
  ** Apply the specified message digest algorthm to this buffer's
  ** contents from 0 to size and return the resulting hash.  Digests
  ** are secure one-way hash functions which input an arbitrary sized
  ** buffer and return a fixed sized buffer.  Common algorithms include:
  ** "MD5", "SHA-1", and "SHA-256"; the full list supported is platform
  ** dependent.  On the Java VM, the algorithm maps to those avaialble
  ** via the 'java.security.MessageDigest' API.  Throw ArgErr if the
  ** algorithm is not available.  This method is unsupported for mmap
  ** buffers.
  **
  ** Example:
  **   Buf.make.print("password").print("salt").toDigest("MD5").toHex
  **    =>  "b305cadbb3bce54f3aa59c64fec00dea"
  **
  static extension native Buf toDigest(Buf buf, Str algorithm)

  **
  ** Compute a cycle reduancy check code using this buffer's contents
  ** from 0 to size.  The supported algorithm names:
  **    - "CRC-16": also known as CRC-16-ANSI, CRC-16-IBM; used by
  **      USB, ANSI X3.28, and Modbus
  **    - "CRC-32": used by Ethernet, MPEG-2, PKZIP, Gzip, PNG
  **    - "CRC-32-Adler": used by Zlib
  **
  ** Raise ArgErr is algorithm is not available.  This method is
  ** only supported for memory based buffers.
  **
  static extension native Int crc(Buf buf, Str algorithm)

  **
  ** Generate an HMAC message authentication as specified by RFC 2104.
  ** This buffer is the data input, 'algorithm' specifies the hash digest,
  ** and 'key' represents the secret key:
  **   - 'H': specified by algorthim parameter - "MD5" or "SHA1"
  **   - 'K': secret key specified by key parameter
  **   - 'B': fixed at 64
  **   - 'text': this instance
  **
  ** The HMAC is computed using:
  **   ipad = the byte 0x36 repeated B times
  **   opad = the byte 0x5C repeated B times
  **   H(K XOR opad, H(K XOR ipad, text))
  **
  ** Throw ArgErr if the algorithm is not available.  This method is
  ** only supported for memory buffers.
  **
  ** Examples:
  **   "hi there".toBuf.hmac("MD5", "secret".toBuf)
  **
  static extension native Buf hmac(Buf buf, Str algorithm, Buf key)

  **
  ** Generate a password based cryptographic key.  Supported algoriths:
  **   - "PBKDF2WithHmacSHA1"
  **   - "PBKDF2WithHmacSHA256"
  **
  ** Parameters:
  **   - password: secret used to generate resulting cryptographic key
  **   - salt: cryptographic salt
  **   - iterations: number of iterations (the 'c' term)
  **   - keyLen: desired length of key in bytes (not bits!)
  **
  ** Throw ArgErr if the algorithm is not available.  This method is
  ** only supported for memory buffers.
  **
  static native Buf pbk(Str algorithm, Str password, Buf salt, Int iterations, Int keyLen)
}

