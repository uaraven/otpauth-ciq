import Toybox.Graphics;
import Toybox.WatchUi;

import Toybox.Time;
import Toybox.Timer;

var codeStore;

class OTPAuthView extends WatchUi.View {

    var updateTimer;

    function initialize() {
        View.initialize();
        codeStore = new CodeStore();
        updateTimer = new Timer.Timer();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        updateTimer.start(method(:onTimer), 1000, true);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        var code = View.findDrawableById("code");
        var name = View.findDrawableById("name");
        var noCodes = View.findDrawableById("no_codes");
        if (codeStore.isEmpty()) {
            code.setText("");
            name.setText("");
        } else {
            var otpCode = codeStore.getOtpCode();
            noCodes.setText("");
            code.setText(otpCode.getOtp().code());
            name.setText(otpCode.getName());
        }
        View.onUpdate(dc);
        if (!codeStore.isEmpty()) {
            var percentTimeLeft = codeStore.getOtpCode().getOtp().getPercentTimeLeft();
        
            dc.setPenWidth(4);
            var start = 90;
            var end = (360*percentTimeLeft + 90).toNumber();
            var w = dc.getWidth();
            var h = dc.getHeight();
            var color =  codeStore.getOtpCode().getOtp().getSecondsLeft() < 5 
                ? Graphics.COLOR_RED
                : Graphics.COLOR_BLUE;
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(w/2, h/2, h/2-3, Graphics.ARC_COUNTER_CLOCKWISE, start, end);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        updateTimer.stop();
    }

    function onTimer() {
        WatchUi.requestUpdate();
    }

}
