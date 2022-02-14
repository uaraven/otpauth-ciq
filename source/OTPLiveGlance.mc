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
        timer.start(method(:timerCallback), 2000, true);
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
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.drawText(5, 5, Graphics.FONT_NUMBER_MILD, otp.getOtp().code(), Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(5, 85, Graphics.FONT_GLANCE, otp.getName(), Graphics.TEXT_JUSTIFY_LEFT);

        var x = ((w -10) *  otp.getOtp().getPercentTimeLeft()).toNumber();
        dc.setPenWidth(4);
        if (otp.getOtp().getSecondsLeft() < 5) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawLine(5, h-5, x, h-5);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, h-5, w-5, h-5);
    }
}