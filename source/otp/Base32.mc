import Toybox.System;
import Toybox.Test;
import Toybox.StringUtil;
import Toybox.Lang;


(:glance)
module Base32 {

    const BASE32 = ['A', 'B', 'C', 'D', 'E', 'F', 'G' ,'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R' ,'S', 'T' ,'U', 'V', 'W', 'X', 'Y', 'Z', '2', '3', '4', '5', '6', '7']b;
    const SHIFT = 5;
    const CSIZE = 8;

    function base32decode(encoded)  {
        var padding = encoded.find("=");
        if (padding != null) {
            encoded = encoded.substring(0, padding);
        }
        var encodedChars = removeSpaces(encoded.toUpper().toCharArray());
        var result = new [encodedChars.size() * SHIFT / CSIZE];

        var buffer = 0;
        var next = 0;
        var bitsLeft = 0;
        
        for (var i = 0; i < encodedChars.size(); i++) {
            buffer <<= SHIFT;
            buffer |= BASE32.indexOf(encodedChars[i]) & 0x1F;
            bitsLeft += SHIFT;
            if (bitsLeft >= CSIZE) {
                result[next] = (buffer >> (bitsLeft - CSIZE) & 0xFF);
                bitsLeft -= CSIZE;
                next++;
            }
        }
        return result;
    }

    function isBase32Character(c as Lang.Char) as Boolean {
        return (c >= 'A' && c <= 'Z') || c == '2' || c == '3' || c == '4' || c == '5' || c == '6' || c == '7';
    }

    function removeSpaces(chars as Array<Char>) as Array<Char> {
        var res = [];
        for (var i = 0; i < chars.size(); i++) {
            if (isBase32Character(chars[i])) {
                res.add(chars[i]);
            }
        }
        return res;
    }

    (:test)
    function TestBase32Decode(logger as Test.Logger) {
        var result = base32decode("JBSWY3DP");
        var expected = [72, 101, 108, 108, 111];
        logger.debug("Expected: '" + expected + "', actual: '" + result + "'");
        return arraysEqual(expected, result);
    }
    
    (:test)
    function TestBase32DecodeLonger(logger as Test.Logger) {
        var result = base32decode("KRUGS4ZANFZSAYJAOJSWC3BAON2HKZTGEA======");
        var expected = [84, 104, 105, 115, 32, 105, 115, 32, 97, 32, 114, 101, 97, 108, 32, 115, 116, 117, 102, 102, 32];
        logger.debug("Expected: '" + expected + "', actual: '" + result + "'");
        return arraysEqual(expected, result);
    }

     (:test)
    function TestBase32DecodeSpaced(logger as Test.Logger) {
        var result = base32decode("KRUG S4ZA NFZS AYJA OJSW C3BA ON2H KZTG EA");
        var expected = [84, 104, 105, 115, 32, 105, 115, 32, 97, 32, 114, 101, 97, 108, 32, 115, 116, 117, 102, 102, 32];
        logger.debug("Expected: '" + expected + "', actual: '" + result + "'");
        return arraysEqual(expected, result);
    }


    function arraysEqual(a as Array<Number>, b as Array<Number>) as Boolean {
        if (a.size() != b.size()) {
            return false;
        }
        for (var i = 0; i < a.size(); i++) {
            if (a[i] != b[i]) {
                return false;
            }
        }
        return true;
    }
}