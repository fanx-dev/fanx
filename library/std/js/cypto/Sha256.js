//
// Copyright (c) 2015, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Jan 16  Matthew Giannini  creation
//


fan.sys.buf_sha256 = (function () {

  var crypto = fan.sys.buf_crypto;
  var ns = {};

  /*
   * Main sha256 function, with its support functions
   */
  function sha256_S (X, n) {return ( X >>> n ) | (X << (32 - n));}
  function sha256_R (X, n) {return ( X >>> n );}
  function sha256_Ch(x, y, z) {return ((x & y) ^ ((~x) & z));}
  function sha256_Maj(x, y, z) {return ((x & y) ^ (x & z) ^ (y & z));}
  function sha256_Sigma0256(x) {return (sha256_S(x, 2) ^ sha256_S(x, 13) ^ sha256_S(x, 22));}
  function sha256_Sigma1256(x) {return (sha256_S(x, 6) ^ sha256_S(x, 11) ^ sha256_S(x, 25));}
  function sha256_Gamma0256(x) {return (sha256_S(x, 7) ^ sha256_S(x, 18) ^ sha256_R(x, 3));}
  function sha256_Gamma1256(x) {return (sha256_S(x, 17) ^ sha256_S(x, 19) ^ sha256_R(x, 10));}
  function sha256_Sigma0512(x) {return (sha256_S(x, 28) ^ sha256_S(x, 34) ^ sha256_S(x, 39));}
  function sha256_Sigma1512(x) {return (sha256_S(x, 14) ^ sha256_S(x, 18) ^ sha256_S(x, 41));}
  function sha256_Gamma0512(x) {return (sha256_S(x, 1)  ^ sha256_S(x, 8) ^ sha256_R(x, 7));}
  function sha256_Gamma1512(x) {return (sha256_S(x, 19) ^ sha256_S(x, 61) ^ sha256_R(x, 6));}

  var sha256_K = new Array
  (
    1116352408, 1899447441, -1245643825, -373957723, 961987163, 1508970993,
    -1841331548, -1424204075, -670586216, 310598401, 607225278, 1426881987,
    1925078388, -2132889090, -1680079193, -1046744716, -459576895, -272742522,
    264347078, 604807628, 770255983, 1249150122, 1555081692, 1996064986,
    -1740746414, -1473132947, -1341970488, -1084653625, -958395405, -710438585,
    113926993, 338241895, 666307205, 773529912, 1294757372, 1396182291,
    1695183700, 1986661051, -2117940946, -1838011259, -1564481375, -1474664885,
    -1035236496, -949202525, -778901479, -694614492, -200395387, 275423344,
    430227734, 506948616, 659060556, 883997877, 958139571, 1322822218,
    1537002063, 1747873779, 1955562222, 2024104815, -2067236844, -1933114872,
    -1866530822, -1538233109, -1090935817, -965641998
  );

  function binb_sha256(m, l)
  {
    var HASH = new Array(1779033703, -1150833019, 1013904242, -1521486534,
                         1359893119, -1694144372, 528734635, 1541459225);
    var W = new Array(64);
    var a, b, c, d, e, f, g, h;
    var i, j, T1, T2;

    /* append padding */
    m[l >> 5] |= 0x80 << (24 - l % 32);
    m[((l + 64 >> 9) << 4) + 15] = l;

    for(i = 0; i < m.length; i += 16)
    {
      a = HASH[0];
      b = HASH[1];
      c = HASH[2];
      d = HASH[3];
      e = HASH[4];
      f = HASH[5];
      g = HASH[6];
      h = HASH[7];

      for(j = 0; j < 64; j++)
      {
        if (j < 16) W[j] = m[j + i];
        else W[j] = safe_add(safe_add(safe_add(sha256_Gamma1256(W[j - 2]), W[j - 7]),
                                              sha256_Gamma0256(W[j - 15])), W[j - 16]);

        T1 = safe_add(safe_add(safe_add(safe_add(h, sha256_Sigma1256(e)), sha256_Ch(e, f, g)),
                                                            sha256_K[j]), W[j]);
        T2 = safe_add(sha256_Sigma0256(a), sha256_Maj(a, b, c));
        h = g;
        g = f;
        f = e;
        e = safe_add(d, T1);
        d = c;
        c = b;
        b = a;
        a = safe_add(T1, T2);
      }

      HASH[0] = safe_add(a, HASH[0]);
      HASH[1] = safe_add(b, HASH[1]);
      HASH[2] = safe_add(c, HASH[2]);
      HASH[3] = safe_add(d, HASH[3]);
      HASH[4] = safe_add(e, HASH[4]);
      HASH[5] = safe_add(f, HASH[5]);
      HASH[6] = safe_add(g, HASH[6]);
      HASH[7] = safe_add(h, HASH[7]);
    }
    return HASH;
  }

  function safe_add (x, y)
  {
    var lsw = (x & 0xFFFF) + (y & 0xFFFF);
    var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
    return (msw << 16) | (lsw & 0xFFFF);
  }

  /*
   * Calculate the HMAC-SHA256 of a key and some data (byte arrays)
   * Returns word array.
   */
  function hmac_sha256(key, data)
  {
    var bkey = crypto.bytesToWords(key);
    if(bkey.length > 16) bkey = binb_sha256(bkey, key.length * 8);

    var ipad = Array(16), opad = Array(16);
    for(var i = 0; i < 16; i++)
    {
      ipad[i] = bkey[i] ^ 0x36363636;
      opad[i] = bkey[i] ^ 0x5C5C5C5C;
    }
    var hash = binb_sha256(ipad.concat(crypto.bytesToWords(data)), 512 + data.length * 8);
    return binb_sha256(opad.concat(hash), 512 + 256);
  }

  /**
   * Calculate the SHA256 hash of data if key is undefined. Otherwise,
   * calculate the HMAC-SHA256 of the data using key. Expects
   * byte array input and returns byte array hash.
   */
  ns.digest = function(data, key)
  {
    var hash;
    if (key === undefined)
      hash = binb_sha256(crypto.bytesToWords(data), data.length * 8);
    else
      hash = hmac_sha256(key, data);
    return crypto.wordsToBytes(hash);
  }

  /**
   * PBKDF2WithHmacSHA256
   */
  ns.pbkdf2 = function(key, salt, iterations, dkLen)
  {
    return crypto.pbkdf2(hmac_sha256, 32, key, salt, iterations, dkLen);
  }

  return ns;

})();
