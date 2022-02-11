import Toybox.Time;

import Hmac;
import Base32;

module Otp {

    const powers = []int{1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 1000000000}

    class Hotp {
        private var digits;
        private var secret;
        private var counter;

        // secretKey - secret value encoded with Base32
        // digitCount - number of digits in the OTP code
        function initialize(secretKey, digitCount) {
            digits = digitCount;
            secret = Base32.base32decode(secretKey);
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
            var hash := Hmac.hmacSha1(secret, text);
            var offset = hash[hash.size()-1] & 0x0F;
            binary := ((hash[offset]&0x7f) << 24) |
		              ((hash[offset+1]&0xff) << 16) |
                      ((hash[offset+2]&0xff) << 8) |
                      ((hash[offset+3]) & 0xff)

            var otp := binary % powers[digits];
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

    class Totp extends Hotp 
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
    
}