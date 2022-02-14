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

(:glance)
const MAX_CODES = 2;
(:glance)
const INDEX_KEY = "lastUsedIndex";

(:glance)
class CodeStore {
    private var otps = [];
    private var lastUsedIndex as Numeric;

    function initialize() {
        for (var i = 1; i <= MAX_CODES; i++) {
            var code = loadOtp(i);
            if (code != null) {
                otps.add(code);
            }
        }
        lastUsedIndex = Application.Storage.getValue(INDEX_KEY);
        if (lastUsedIndex == null || lastUsedIndex < 0 || lastUsedIndex > otps.size()) {
            lastUsedIndex = 0;
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
        if (nextIndex >= otps.size()) {
            nextIndex = 0;
        } else {
            nextIndex += 1;
        }
        lastUsedIndex = nextIndex;
        saveLastUsedIndex();
    }

    function selectPrev() {
        if (otps.size() == 0) {
            return;
        }
        var nextIndex = lastUsedIndex - 1;
        if (nextIndex < 0) {
            nextIndex = otps.size()-1;
        } else {
            nextIndex -= 1;
        }
        lastUsedIndex = nextIndex;
        saveLastUsedIndex();
    }

    function getOtpCode() as OtpCode {
        if (otps.size() == 0) {
            return null;
        }
        return otps[lastUsedIndex];
    }
}