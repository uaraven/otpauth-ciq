import Toybox.Test;
import Sha;
import Hex;

module Hmac {
    const BLOCK_SIZE = 64;

    function hmacSha1(key, text) {
        if (key.size() > BLOCK_SIZE) {
            key = Sha.encodeSha1(key);
        }
        
        // HMAC = H(K XOR opad, H(K XOR ipad, text)), where H = SHA1
        var ipad = new [BLOCK_SIZE];
        var opad = new [BLOCK_SIZE];
        for (var i = 0; i < BLOCK_SIZE; i++) {
            var k = i < key.size() ? key[i] : 0x00;
            ipad[i] = k ^ 0x36;
            opad[i] = k ^ 0x5C;
        }

        return Sha.encodeSha1(opad.addAll(Sha.encodeSha1(ipad.addAll(text))));
    }

    (:test)
    function TestHmac(logger as Test.Logger) {
        var key = "secret key".toUtf8Array();
        var text = "// HMAC = H(K XOR opad, H(K XOR ipad, text)), where H = SHA1".toUtf8Array();

        var hmac = hmacSha1(key, text);
        var hmacStr = Hex.bytesToHex(hmac);
        var expected = "a3a11aa2efab92ab7cce1f9b8e0aaed566114522";

        logger.debug("Expected HMAC: '" + expected + "', actual: '" + hmacStr + "'");
        return expected.equals(hmacStr);
    }
}
    