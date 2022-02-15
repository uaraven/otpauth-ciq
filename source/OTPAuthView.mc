import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;
import Toybox.Math;

var codeStore;

class OTPAuthView extends WatchUi.View {

    var updateTimer;

    var indicatorSize; // size of dots indicator
    var startingAngle;
    var indicatorRadius;
    const indicatorAngle = 6;

    function initialize() {
        View.initialize();
        codeStore = new CodeStore();
        updateTimer = new Timer.Timer();
    }

    function min(a, b) {
        return a < b ? a : b;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        var r = min(dc.getWidth(), dc.getHeight());
        indicatorSize = r / 70;
        if (codeStore.size() % 2 == 0) {
            startingAngle = 270 + indicatorAngle/2 * codeStore.size()/2;
        } else {
            startingAngle = 270 + indicatorAngle * (codeStore.size()/2).toNumber();
        }
        indicatorRadius = r/2 - indicatorSize - 10;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        updateTimer.start(method(:onTimer), 1000, true);
        System.println("Starting widget");
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

            drawIndicator(dc);
        }
    }

    function drawIndicator(dc) {
        for (var i = 0; i < codeStore.size(); i++) {
            drawItemCircle(dc, i, i == codeStore.getIndex());
        }
    }

    function drawItemCircle(dc, index as Numeric, selected as Boolean) {
        var angle = startingAngle - indicatorAngle * index;
        var angleR = Math.toRadians(angle);
        var x = dc.getWidth() / 2 + indicatorRadius * Math.sin(angleR);
        var y = dc.getHeight() / 2 - indicatorRadius * Math.cos(angleR);
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        if (selected) {
            dc.fillCircle(x, y, indicatorSize);
        } else {
            dc.drawCircle(x, y, indicatorSize);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        updateTimer.stop();
        System.println("Stopping widget");
    }

    function onTimer() {
        WatchUi.requestUpdate();
    }

}
