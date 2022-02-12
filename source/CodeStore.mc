import Toybox.Lang;
import Toybox.Application;

import Otp;
import Base32;

(:glance)
class OtpCode {
    private var otp;
    private var name as String;

    function initialize(code, codeName) {
        otp = code;
        name = codeName;
    }

    function getOtp() {
        return otp;
    }

    function getName() {
        return name;
    }

}

const MAX_CODES = 2;
const INDEX_KEY = "lastUsedIndex";

(:glance)
class CodeStore {
    private var otps = {};
    private var lastUsedIndex as Numeric;

    function initialize() {
        for (var i = 1; i <= MAX_CODES; i++) {
            var code = loadOtp(i);
            if (code != null) {
                otps[i] = code;
            }
        }
        lastUsedIndex = Application.Storage.getValue(INDEX_KEY);
        if (lastUsedIndex == null) {
            lastUsedIndex = 1;
        }
    }

    private function loadOtp(index) {
        var name = Application.Properties.getValue("name" + index);
        var secret = Application.Properties.getValue("code" + index);
        var digits = Application.Properties.getValue("digits" + index);
        if ("".equals(name) || "".equals(secret)) {
            return null;
        }
        var otp = Otp.TotpFromBase32Digits(secret, digits);
        return new OtpCode(otp, name);
    }

    function isEmpty() {
        return otps.size() == 0;
    }

    function saveLastUsedIndex() {
        Application.Storage.setValue(INDEX_KEY, lastUsedIndex);
    }

    function selectNext() {
        if (otps.size() ==0) {
            return;
        }
        var nextIndex = lastUsedIndex + 1;
        while (!otps.hasKey(nextIndex)) {
            nextIndex += 1;
            if (nextIndex > MAX_SIZE) {
                nextIndex = 1;
            }
        }
        saveLastUsedIndex();
    }

    function selectPrev() {
        if (otps.size() ==0) {
            return;
        }
        var nextIndex = lastUsedIndex - 1;
        while (!otps.hasKey(nextIndex)) {
            nextIndex -= 1;
            if (nextIndex <= 0) {
                nextIndex = MAX_SIZE;
            }
        }
        saveLastUsedIndex();
    }

    function getOtpCode() as OtpCode {
        if (otps.size() == 0) {
            return null;
        }
        return otps.get(lastUsedIndex);
    }
}