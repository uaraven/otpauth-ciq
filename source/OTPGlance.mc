import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Timer;

import Otp;

(:glance)
class OTPGlance extends WatchUi.GlanceView {

    var codeStore;

    var noCodes as String;
    var code as String;
    var name as String;
    var timeStep as Numeric;

    var updateTimer;

    function initialize() {
        GlanceView.initialize();
        codeStore = new CodeStore();

        updateTimer = new Timer.Timer();

    }

    function onTimer() {
        System.println("requestUpdate");
        WatchUi.requestUpdate();
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

    function onShow() {
        System.println("Show");
        updateTimer.start(method(:onTimer), 1000, true);
    }

    function onHide() {
        System.println("Hide");
        updateTimer.stop();
    }

    // onUpdate() is called periodically to update the View
    function onUpdate(dc) {
        View.onUpdate(dc);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        System.println("onUpdate");

        var w = dc.getWidth();
        var h = dc.getHeight();

        System.println("" + w + "x" + h);

        if (codeStore.isEmpty()) {
            dc.drawText(w/2, h/2, Graphics.FONT_GLANCE, noCodes, Graphics.TEXT_JUSTIFY_CENTER + Graphics.TEXT_JUSTIFY_VCENTER);
        } else {

            dc.drawText(5, 2, Graphics.FONT_GLANCE_NUMBER, code, Graphics.TEXT_JUSTIFY_LEFT);

            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(5, h-5-25, Graphics.FONT_GLANCE, name, Graphics.TEXT_JUSTIFY_LEFT);

            var percentLeft = (Time.now().value() % timeStep).toFloat() / timeStep;
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(3);
            var r = w-10-(5 + (w-10)*percentLeft).toNumber();
            dc.drawLine(r, h-5, 5, h-5);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(w-5, h-5, r, h-5);
        }
    }
}