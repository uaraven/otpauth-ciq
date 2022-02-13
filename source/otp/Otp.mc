import Toybox.Time;
import Toybox.Test;

import Hmac;
import Base32;

(:glance)
module Otp {

    const powers = [1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 1000000000];

    class BaseOtp {
        private var digits;
        private var secret;

        function initialize(secretKey, digitCount) {
            digits = digitCount;
            secret = secretKey;
        }

        function getSecret() {
            return secret;
        }

        function setDigitCount(num) {
            self.digits = num;
        }

        function getDigitCount() {
            return digits;
        }

        function code() as String {
            return "";
        }

    }

    class Hotp extends BaseOtp {
        private var counter;

        // secretKey - secret value encoded with Base32
        // digitCount - number of digits in the OTP code
        function initialize(secretKey, digitCount) {
            BaseOtp.initialize(secretKey, digitCount);
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
            var hash = Hmac.hmacSha1(getSecret(), text);
            var offset = (hash[hash.size()-1] & 0x0F).toNumber();
            var binary = ((hash[offset] & 0x7f) << 24) |
                         ((hash[offset+1] & 0xff) << 16) |
                         ((hash[offset+2] & 0xff) << 8) |
                         ((hash[offset+3]) & 0xff);

            var otp = binary % powers[getDigitCount()];
            var format = "%0" + getDigitCount() + "d";
            return otp.format(format);
        }

        function code() as String {
            return generate();
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
        private var cachedCode as String;
        private var cachedTime as Long;

        // secretKey - secret value encoded with Base32
        // digitCount - number of digits in the OTP code
        // timeStep - time window for a TOTP code
        function initialize(secretKey, digitCount, timeStep) {
            Hotp.initialize(secretKey, digitCount);
            self.timeStep = timeStep;
            self.cachedCode = null;
            self.cachedTime = 0;
        }

        function codeForEpoch(epoch) as String {
            var time = (epoch / timeStep).toLong();
            if (time != cachedTime || cachedCode == null || "".equals(cachedCode)) {
                System.println("generating code");
                cachedTime = time;
                setCounter(time);
                cachedCode = generate();
            }
            return cachedCode;
        }

        function code() as String {
            var now = Time.now().value();
            return codeForEpoch(now);
        }

        function getTimeStep() {
            return timeStep;
        }

        function getPercentTimeLeft()  as Float {
            var now = Time.now().value();
            return 1 - (now % timeStep).toFloat() / timeStep;
        }
    }

    function TotpFromBase32(key as String) as Totp {
        var secret = Base32.base32decode(key);
        var totp = new Totp(secret, 6, 30);
        return totp;
    }

    function TotpFromBase32Digits(key as String, digits as Numeric) as Totp {
        var secret = Base32.base32decode(key);
        var totp = new Totp(secret, digits, 30);
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