import Toybox.Lang;
import Toybox.Test;

module Hex {

    function bytesToHex(bytes as Array<Number>) as String {
        var s = "";
        for (var i = 0; i < bytes.size(); i++) {
            var l = bytes[i] & 0x0F;
            var h = (bytes[i] >> 4) & 0x0F;
            s = s + hexChars[h] + hexChars[l];
         }
         return s;
    }

    const hexChars = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'];


    (:test)
    function testBytesToHex(logger as Test.Logger) {
        var a1 = [169, 74, 143, 229];
        var actual = bytesToHex(a1);
        if (!"a94a8fe5".equals(actual)) {
            logger.debug(Lang.format("bytesToHex() Expected: '$1$', actual: '$2$'", ["a94a8fe5", actual]));
            return false;
        }
        return true;
    }
}
