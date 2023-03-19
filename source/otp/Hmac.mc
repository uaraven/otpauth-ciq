import Toybox.Lang;
import Toybox.Test;
import Sha;
import Hex;

(:glance)
module Hmac {
    const BLOCK_SIZE = 64;

    function hmacSha(key as Array<Number>, algorithm as Number, text) as Array<Number> {

        if (key.size() > BLOCK_SIZE) {
            key = Sha.encodeHash(key, algorithm) as Array<Number>;
        }
        
        // HMAC = H(K XOR opad, H(K XOR ipad, text)), where H = SHA1/SHA256
        var ipad = new [BLOCK_SIZE];
        var opad = new [BLOCK_SIZE];
        for (var i = 0; i < BLOCK_SIZE; i++) {
            var k = i < key.size() ? key[i] : 0x00;
            ipad[i] = k ^ 0x36;
            opad[i] = k ^ 0x5C;
        }
        var v1 = Sha.encodeHash(ipad.addAll(text), algorithm);
        return Sha.encodeHash(opad.addAll(v1), algorithm);
    }

    (:test)
    function TestHmacSha1(logger as Test.Logger) {
        var key = "secret key".toUtf8Array();
        var text = "// HMAC = H(K XOR opad, H(K XOR ipad, text)), where H = SHA-1".toUtf8Array();

        var hmac = hmacSha(key, 0, text);
        var hmacStr = Hex.bytesToHex(hmac);
        var expected = "c73367c6514523393d3f34540d59946699da5d04";

        logger.debug("SHA-1: Expected HMAC: '" + expected + "', actual: '" + hmacStr + "'");
        return expected.equals(hmacStr);
    }

    (:test)
    function TestHmacSha256(logger as Test.Logger) {
        var key = "secret key".toUtf8Array();
        var text = "// HMAC = H(K XOR opad, H(K XOR ipad, text)), where H = SHA256".toUtf8Array();

        var hmac = hmacSha(key, 1, text);
        var hmacStr = Hex.bytesToHex(hmac);
        var expected = "1cf13f8c98a2f62206056ed3ae16140da1e4b877cf375e4762b3e6c241e94905";

        logger.debug("SHA-256: Expected HMAC: '" + expected + "', actual: '" + hmacStr + "'");
        return expected.equals(hmacStr);
    }
}
    