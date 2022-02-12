import Toybox.System;
import Toybox.WatchUi;

import Otp;

(:glance)
class OTPGlance extends WatchUi.GlanceView {

    var code as Totp;

    function initialize() {
        GlanceView.initialize();
    }

    // Resources are loaded here
    function onLayout(dc) {
    }

    // onUpdate() is called periodically to update the View
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);


        var w = dc.getWidth();
        var h = dc.getHeight();

        
        dc.drawText(w/2, h/2, Graphics.FONT_NUMBER_MILD, "555664", Graphics.TEXT_JUSTIFY_CENTER + Graphics.TEXT_JUSTIFY_VCENTER);
    }
}