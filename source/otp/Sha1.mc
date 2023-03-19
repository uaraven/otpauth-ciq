import Toybox.Lang;
import Toybox.Test;
import Toybox.Cryptography;
import Toybox.System;
import Hex;

(:glance)
module Sha {

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
} 
