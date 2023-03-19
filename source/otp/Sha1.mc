import Toybox.Lang;
import Toybox.Test;
import Toybox.Cryptography;
import Toybox.System;
import Hex;

(:glance)
module Sha {

    function encodeHash(message as Array<Number>, algorithm as Number) as Array<Number> {
        var hash = new Hash({:algorithm => algorithm as Toybox.Cryptography.HashAlgorithm});
        hash.update(toByteArray(message));
        return toArray(hash.digest());
    }

    function encodeSha1(message as Array<Number>) as Array<Number> {
        var sha = new Hash({:algorithm => Cryptography.HASH_SHA1});
        sha.update(toByteArray(message));
        return toArray(sha.digest());
    }

    function toArray(ba as ByteArray) as Array<Number> {
        var res = new [ba.size()];
        for (var i=0; i < res.size(); i++) {
            res[i] = ba[i];
        }
        return res;
    }

    function toByteArray(a as Array<Number>) as ByteArray {
        var res = []b;
        for (var i=0; i < a.size(); i++) {
            res = res.add(a[i].toNumber());
        }
        return res;
    }

    (:test)
    function testSha1(logger as Test.Logger) {
        var message = "test".toUtf8Array();
        var hash = encodeHash(message, 0);
        var actual = Hex.bytesToHex(hash);
        var expected = "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3";
        if (!expected.equals(actual)) {
            logger.debug(Lang.format("Expected: '$1$', actual: '$2$'", [expected, actual]));
            return false;
        }
        return true;
    }

    (:test)
    function testSha256(logger as Test.Logger) {
        var message = "test".toUtf8Array();
        var hash = encodeHash(message, 1);
        var actual = Hex.bytesToHex(hash);
        var expected = "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08";
        if (!expected.equals(actual)) {
            logger.debug(Lang.format("Expected: '$1$', actual: '$2$'", [expected, actual]));
            return false;
        }
        return true;
    }
} 
