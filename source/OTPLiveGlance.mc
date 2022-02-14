import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Timer;

import Otp;

(:glance)
class OTPLiveGlance extends WatchUi.GlanceView {

    var otp;
    var timer;

    function initialize(otp) {
        GlanceView.initialize();
        self.otp = otp;
    }

    function timerCallback() {
        WatchUi.requestUpdate();
    }

    function onShow() {
        View.onShow();
        timer = new Timer.Timer();
        timer.start(method(:timerCallback), 1000, true);
    }

    function onHide() {
        View.onHide();
        timer.stop();
    }

    // Resources are loaded here
    function onLayout(dc) {
    }

    // onUpdate() is called periodically to update the View
    function onUpdate(dc) {
        View.onUpdate(dc);
        
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var font = h > 100 ? Graphics.FONT_NUMBER_MILD : Graphics.FONT_GLANCE_NUMBER;
        dc.drawText(5, h/3, font, otp.getOtp().code(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(5, 2*h/3, Graphics.FONT_GLANCE, otp.getName(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        var x = ((w -10) *  otp.getOtp().getPercentTimeLeft()).toNumber();
        dc.setPenWidth(4);
        if (otp.getOtp().getSecondsLeft() < 5) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        }
        dc.setPenWidth(4);
        dc.drawLine(5, h-5, x, h-5);
        dc.setPenWidth(5);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, h-5, w-5, h-5);
    }
}