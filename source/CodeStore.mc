import Toybox.Lang;
import Toybox.Application;

import Otp;
import Base32;

(:glance)
class OtpCode {
  private var otp;
  private var name as String;
  private var slot as Number;

  function initialize(code, codeName, codeSlot) {
    otp = code;
    name = codeName;
    slot = codeSlot;
  }

  function getOtp() {
    return otp;
  }

  function getName() {
    return name;
  }

  function getSlot() {
    return slot;
  }
}

(:glance)
const MAX_CODES = 10;
(:glance)
const SLOT_KEY = "lastUsedSlot";

(:glance)
class CodeStore {
  private var otps as Array<OtpCode> = [];
  private var lastUsedIndex as Numeric;

  function initialize() {
    for (var i = 1; i <= MAX_CODES; i++) {
      var code = loadOtp(i);
      if (code != null) {
        otps.add(code);
      }
    }
    // selection is stored as a settings slot so disabling an account keeps it
    var lastUsedSlot = Application.Storage.getValue(SLOT_KEY);
    lastUsedIndex = 0;
    for (var i = 0; i < otps.size(); i++) {
      if (otps[i].getSlot() == lastUsedSlot) {
        lastUsedIndex = i;
        break;
      }
    }
  }

  private function loadOtp(index) {
    var enabled = Application.Properties.getValue("enabled" + index);
    var name = Application.Properties.getValue("name" + index);
    var secret = Application.Properties.getValue("code" + index);
    var algo = Application.Properties.getValue("algo" + index);
    var digits = Application.Properties.getValue("digits" + index);
    var timeStep = Application.Properties.getValue("timeStep" + index);
    if (!enabled || secret == null || "".equals(secret)) {
      return null;
    }
    if (
      (algo != 0 && algo != 1) ||
      digits == null ||
      digits < 6 ||
      digits > 10 ||
      timeStep == null ||
      timeStep <= 0
    ) {
      return null;
    }
    var key = Base32.base32decode(secret);
    if (key.size() == 0) {
      return null;
    }
    var otp = new Otp.Totp(key, algo, digits, timeStep);
    return new OtpCode(otp, name, index);
  }

  function isEmpty() {
    return otps.size() == 0;
  }

  function size() {
    return otps.size();
  }

  function saveLastUsedIndex() {
    Application.Storage.setValue(SLOT_KEY, otps[lastUsedIndex].getSlot());
  }

  function selectNext() {
    if (otps.size() == 0) {
      return;
    }
    var nextIndex = lastUsedIndex + 1;
    if (nextIndex >= otps.size()) {
      nextIndex = 0;
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
      nextIndex = otps.size() - 1;
    }
    lastUsedIndex = nextIndex;
    saveLastUsedIndex();
  }

  function getIndex() as Numeric {
    return lastUsedIndex;
  }

  function getOtpCode() as OtpCode? {
    if (lastUsedIndex < 0 || lastUsedIndex >= otps.size()) {
      lastUsedIndex = 0;
    }
    if (otps.size() == 0) {
      return null;
    }
    return otps[lastUsedIndex];
  }
}
