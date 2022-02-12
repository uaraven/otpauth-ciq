import Toybox.Time;
import Toybox.Test;

import Hmac;
import Base32;

module Otp {

    const powers = [1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 1000000000];

    class Hotp {
        private var digits;
        private var secret;
        private var counter;

        // secretKey - secret value encoded with Base32
        // digitCount - number of digits in the OTP code
        function initialize(secretKey, digitCount) {
            digits = digitCount;
            secret = secretKey;
            counter = 0;
        }

        protected function intToBytes(v as Numeric) as Lang.Array {
            var result = [0,0,0,0,0,0,0,0];
            for (var i = 7; i >= 0 ;i--) {
                var b = v & 0xFF;
                result[i] = b;
                v = v >> 8;
            }
            return result;
        }

        protected function generate() as String {
            var text = intToBytes(counter);
            counter += 1;
            var hash = Hmac.hmacSha1(secret, text);
            var offset = (hash[hash.size()-1] & 0x0F).toNumber();
            var binary = ((hash[offset] & 0x7f) << 24) |
                         ((hash[offset+1] & 0xff) << 16) |
                         ((hash[offset+2] & 0xff) << 8) |
                         ((hash[offset+3]) & 0xff);

            var otp = binary % powers[digits];
            var format = "%0" + digits + "d";
            return otp.format(format);
        }

        function code() as String {
            return generate();
        }

        function getSecret() {
            return secret;
        }

        function getDigitCount() {
            return digits;
        }

        function getCounter() {
            return counter;
        }

        function setCounter(newCounter) {
            self.counter = newCounter;
        }
    }

    class Totp extends Hotp {
        private var timeStep = 30;

        // secretKey - secret value encoded with Base32
        // digitCount - number of digits in the OTP code
        // timeStep - time window for a TOTP code
        function initialize(secretKey, digitCount, timeStep) {
            Hotp.initialize(secretKey, digitCount);
            self.timeStep = timeStep;
        }

        function codeForEpoch(epoch) as String {
            setCounter((epoch / timeStep).toLong());
            return generate();
        }

        function code() as String {
            var now = Time.now().value() ;
            setCounter((now / timeStep).toLong());
            return generate();
        }

        function getTimeStep() {
            return timeStep;
        }
    }

    function TotpFromBase32(key as String) as Totp {
        var secret = Base32.base32decode(key);
        var totp = new Totp(secret, 6, 30);
        return totp;
    }
    

    (:test)
    function TestOtp(logger as Test.Logger) {
        var key = "12345678901234567890";
	    var otp = new Totp(key.toUtf8Array(), 8, 30);

        var expected = "94287082";
	    var actual = otp.codeForEpoch(59);
        if (!expected.equals(actual)) {
            logger.debug(Lang.format("Expected: '$1$', actual: '$2$'", [expected, actual]));
            return false;
        } else {
            return true;
        }

        expected = "07081804";
        actual = otp.codeForEpoch(1111111109);
	    if (!expected.equals(actual)) {
            logger.debug(Lang.format("Expected: '$1$', actual: '$2$'", [expected, actual]));
            return false;
        } else {
            return true;
        }
    }
}