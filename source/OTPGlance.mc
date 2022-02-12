import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;

import Otp;

(:glance)
class OTPGlance extends WatchUi.GlanceView {

    var codeStore;

    var noCodes as String;
    var code as String;
    var name as String;
    var timeStep as Numeric;

    function initialize() {
        GlanceView.initialize();
        codeStore = new CodeStore();
    }

    // Resources are loaded here
    function onLayout(dc) {
        noCodes = Application.loadResource(Rez.Strings.noCodes);
        if (!codeStore.isEmpty()) {
            var otp = codeStore.getOtpCode().getOtp();
            code = otp.code();
            timeStep = otp.getTimeStep();
            name = codeStore.getOtpCode().getName();
        }
    }

    // onUpdate() is called periodically to update the View
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);


        var w = dc.getWidth();
        var h = dc.getHeight();

        if (codeStore.isEmpty()) {
            dc.drawText(w/2, h/2, Graphics.FONT_GLANCE, noCodes, Graphics.TEXT_JUSTIFY_CENTER + Graphics.TEXT_JUSTIFY_VCENTER);
        } else {

            dc.drawText(5, 2, Graphics.FONT_GLANCE_NUMBER, code, Graphics.TEXT_JUSTIFY_LEFT);

            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(5, 33, Graphics.FONT_GLANCE, name, Graphics.TEXT_JUSTIFY_LEFT);

            var percentLeft = (Time.now().value() % timeStep).toFloat() / timeStep;
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(3);
            var r = (5 + (w-10)*percentLeft).toNumber();
            dc.drawLine(5, h-5, r, h-5);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(r, h-5, w-5, h-5);
        }
    }
}