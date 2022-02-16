import Toybox.System;
import Toybox.WatchUi;


(:glance)
class OTPSimpleGlance extends WatchUi.GlanceView {

    var title as String;

    function initialize() {
        GlanceView.initialize();
    }

    // Resources are loaded here
    function onLayout(dc) {
        title = WatchUi.loadResource(Rez.Strings.GlanceTitle);
    }

    // onUpdate() is called periodically to update the View
    function onUpdate(dc) {
        View.onUpdate(dc);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.drawText(5, h/2, Graphics.FONT_MEDIUM, title, Graphics.TEXT_JUSTIFY_LEFT + Graphics.TEXT_JUSTIFY_VCENTER);
    }
}