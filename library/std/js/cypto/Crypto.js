//
// Copyright (c) 2015, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Jan 16  Matthew Giannini  creation
//

/**
 * Utilities for working with Buf crypto operations.
 */
fan.sys.buf_crypto = (function () {

  var crypto = {};

  /**
   * Obtain a derived key using PBKDF2 with given pseudo-random function (PRF).
   *
   * @param {function} PRF - the pseudo-random function to use. Will be called
   * as PRF(key, data) where key and data are both byte arrays. Should return
   * a word array.
   * @param {number} hLen - The length in bytes of the hash returned by PRF
   * @param {byte[]} key - The password to obtain a derived key for
   * @param {byte[]} salt - The salt
   * @param {number} dkLen - The desired length of the derived key in bytes
   * @returns {byte[]} - The derived key. It is dkLen bytes in length.
   */
  crypto.pbkdf2 = function(PRF, hLen, key, salt, iterations, dkLen)
  {
    var F = function F(P, S, c, i) {
      var U_r;
      var U_c;
      var xor = function(a, b) {
        var aw = a;
        var bw = b;
        if (aw.length != bw.length) throw "Lengths don't match";
        for (var i = 0; i < aw.length; ++i) {
          aw[i] ^= bw[i];
        }
        return aw;
      };

      S = S.concat(crypto.wordsToBytes([i]));
      U_r = U_c = PRF(P, S);

      for (var iter = 1; iter < c; ++iter) {
        U_c = PRF(P, crypto.wordsToBytes(U_c));
        U_r = xor(U_r, U_c);
      }
      return crypto.wordsToBytes(U_r);
    };

    var l = Math.ceil(dkLen / hLen);
    var r = dkLen - (l - 1) * hLen;
    var T = [];
    var block;

    for (var i = 1; i <= l; ++i) {
      block = F(key, salt, iterations, i);
      T = T.concat(block);
    }

    return T.slice(0, dkLen);
  }

  /*
   * Convert a byte array to an array of big-endian words.
   */
  crypto.bytesToWords = function(bytes)
  {
    var words = new Array();
    var size = bytes.length;

    // handle full 32-bit words
    for (var i=0; size>3 && (i+4)<=size; i+=4)
    {
      words.push((bytes[i]<<24) | (bytes[i+1]<<16) | (bytes[i+2]<<8) | bytes[i+3]);
    }

    // handle remaning bytes
    var rem = bytes.length % 4;
    if (rem > 0)
    {
      if (rem == 3) words.push((bytes[size-3]<<24) | (bytes[size-2]<<16) | bytes[size-1]<<8);
      if (rem == 2) words.push((bytes[size-2]<<24) | bytes[size-1]<<16);
      if (rem == 1) words.push(bytes[size-1]<<24);
    }

    return words;
  }

  /**
   * Convert an array of big-endian words to a byte array.
   */
  crypto.wordsToBytes = function(dw) {
    var db = new Array();
    for (var i=0; i<dw.length; i++)
    {
      db.push(0xff & (dw[i] >> 24));
      db.push(0xff & (dw[i] >> 16));
      db.push(0xff & (dw[i] >> 8));
      db.push(0xff & dw[i]);
    }
    return db;
  }

  return crypto;

})();
