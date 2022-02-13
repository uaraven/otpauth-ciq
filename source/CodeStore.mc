import Toybox.Lang;
import Toybox.Application;

import Otp;
import Base32;

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
        var enabled = Application.Properties.getValue("enabled" + index);
        var name = Application.Properties.getValue("name" + index);
        var secret = Application.Properties.getValue("code" + index);
        var digits = Application.Properties.getValue("digits" + index);
        if (!enabled || "".equals(secret)) {
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
        if (otps.size() == 0) {
            return;
        }
        var nextIndex = lastUsedIndex + 1;
        while (!otps.hasKey(nextIndex)) {
            if (nextIndex > MAX_CODES) {
                nextIndex = 1;
            } else {
                nextIndex += 1;
            }
        }
        lastUsedIndex = nextIndex;
        saveLastUsedIndex();
    }

    function selectPrev() {
        if (otps.size() == 0) {
            return;
        }
        var nextIndex = lastUsedIndex - 1;
        while (!otps.hasKey(nextIndex)) {
            if (nextIndex <= 0) {
                nextIndex = MAX_CODES;
            } else {
                nextIndex -= 1;
            }
        }
        lastUsedIndex = nextIndex;
        saveLastUsedIndex();
    }

    function getOtpCode() as OtpCode {
        if (otps.size() == 0) {
            return null;
        }
        return otps.get(lastUsedIndex);
    }
}