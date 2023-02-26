import Toybox.Lang;
import Toybox.Test;
import Hex;

(:glance)
module Sha {

    function encodeSha1(message as Array<Number>) as Array<Number> {
        var msgSize = message.size();
        var blocks = new [((msgSize+8)/64 + 1)*16] as Array<Number>;
        var blocksSize = blocks.size();

        for (var i = 0; i < blocksSize; i++) {
            blocks[i] = 0;
        }

        for (var i = 0; i < msgSize; i++) {
            blocks[i >> 2] |= message[i] << (24 - (i % 4) * 8);
        }
        blocks[msgSize >> 2] |= 0x80 << (24 - (msgSize % 4) * 8);
        blocks[blocksSize - 1] = msgSize * 8;

        var w = new [80];

        var a = 0x67452301;
        var b = 0xEFCDAB89;
        var c = 0x98BADCFE;
        var d = 0x10325476;
        var e = 0xC3D2E1F0;

        for (var i = 0; i < blocksSize; i+=16) {
            var olda = a;
            var oldb = b;
            var oldc = c;
            var oldd = d;
            var olde = e;

            for (var j = 0; j < 80; j++) {
                w[j] = (j < 16)  ? blocks[i + j] : ( rol(w[j-3] ^ w[j-8] ^ w[j-14] ^ w[j-16], 1) );
                var t = rol(a, 5) + e + w[j] +
                   ( (j < 20) ?  0x5A827999 + ((b & c) | ((~b) & d))
                   : (j < 40) ?  0x6ED9EBA1 + (b ^ c ^ d)
                   : (j < 60) ? 0x8F1BBCDC + ((b & c) | (b & d) | (c & d))
                   : 0xCA62C1D6 + (b ^ c ^ d) );
                e = d;
                d = c;
                c = rol(b, 30);
                b = a;
                a = t;
            }
            a += olda;
            b += oldb;
            c += oldc;
            d += oldd;
            e += olde;
        }
        var words = [a, b, c, d, e];

        var res = new [20];
        for (var i = 0; i < 20; i++) {
            res[i] = words[i >> 2] >> (8 * (3 - (i & 0x03))) & 0xFF ;
        }

        return res;
    }

    function rol(num, cnt) {
        var mask = (1 << cnt) - 1;
        var leftPart = (num << cnt) & (~mask);
        var rightPart = (num >> (32 - cnt)) & (mask);
        return leftPart | rightPart;
    }

    (:test)
    function TestSha1(logger as Test.Logger) {
        var shaResult = encodeSha1("test sha1".toUtf8Array());
        var shaHex = Hex.bytesToHex(shaResult);
        var expected = "b99c071333d4dbca0d9298e5c8d7480f176cafdc";
        logger.debug("Expected sha1='" + expected + "', actual: '" + shaHex + "'");
        return shaHex.equals(expected);
    }

    (:test)
    function TestSha1Longer(logger as Test.Logger) {
        var shaResult = encodeSha1("Monkey C is a duck typed language[1], and does not have true primitive types. The Boolean, Char, Number, Long, Float, and Double types are all objects, which means primitives can have methods just like other objects.".toUtf8Array());
        var shaHex = Hex.bytesToHex(shaResult);
        var expected = "ad5f7c787f6d6fb2c23287bdb631f0413240015f";
        logger.debug("Expected sha1='" + expected + "', actual: '" + shaHex + "'");
        return shaHex.equals(expected);
    }
} 
