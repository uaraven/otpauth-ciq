import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;
import Toybox.Math;

var codeStore;

class OTPAuthView extends WatchUi.View {

    const indicatorAngle = 7.5;

    var updateTimer;

    var indicatorSize; // size of dots indicator
    var startingAngle;
    var indicatorRadius;
    var isInstinct as Boolean;

    var instinctOffset = 0; // second screen offset from top right corner
    var instinctR = 0;

    var screenShape;

    function initialize() {
        View.initialize();
        codeStore = new CodeStore();
        updateTimer = new Timer.Timer();
        isInstinct = "true".equals( WatchUi.loadResource(Rez.Strings.Instinct));
        var settings = System.getDeviceSettings();
        screenShape = settings.screenShape;
    }

    function min(a, b) {
        return a < b ? a : b;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        var r = min(dc.getWidth(), dc.getHeight());
        indicatorSize = r / 65;
        if (codeStore.size() % 2 == 0) {
            startingAngle = 270 + indicatorAngle/2 * codeStore.size()/2;
        } else {
            startingAngle = 270 + indicatorAngle * (codeStore.size()/2).toNumber();
        }
        indicatorRadius = r/2 - indicatorSize - 10;
        if (isInstinct) {
            if (dc.getWidth() == 176) { //instinct 2 
                instinctOffset = 31;
                instinctR = 28;
            } else { // instinct 2s
                instinctOffset = 25;
                instinctR = 20;
            }
        }
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
        drawRoundScreen(dc);
    }

    function drawRoundScreen(dc as Dc) as Void {
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
            if (isInstinct) {
                drawTimeStepInstinct(dc);
            } else {
                if (screenShape == System.SCREEN_SHAPE_ROUND) {
                    drawTimeStepRound(dc);
                } else {
                    drawTimeStepSquare(dc);
                }
            }
            drawIndicator(dc);
        }
    }

    function drawTimeStepRound(dc as Dc) as Void {
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

    function drawTimeStepSquare(dc as Dc) as Void {
        var percentTimeLeft = codeStore.getOtpCode().getOtp().getPercentTimeLeft();
    
        dc.setPenWidth(4);
        var w = dc.getWidth();
        var h = dc.getHeight();
        var end = ((w-10)*percentTimeLeft).toNumber();
        var color =  codeStore.getOtpCode().getOtp().getSecondsLeft() < 5 
            ? Graphics.COLOR_RED
            : Graphics.COLOR_BLUE;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(5, h-10, end, h-10);
    }

    function drawTimeStepInstinct(dc as Dc) as Void {
        var percentTimeLeft = codeStore.getOtpCode().getOtp().getPercentTimeLeft();
    
        dc.setPenWidth(4);
        var start = 90;
        var end = (360*percentTimeLeft + 90).toNumber();
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w-instinctOffset, instinctOffset, instinctR, Graphics.ARC_COUNTER_CLOCKWISE, start, end);
    }

    function drawIndicator(dc as Dc) as Void {
        if (codeStore.size() > 1) {
            for (var i = 0; i < codeStore.size(); i++) {
                drawItemCircle(dc, i, i == codeStore.getIndex());
            }
        }
    }

    function drawItemCircle(dc as Dc, index as Numeric, selected as Boolean) as Void {
        var angle = startingAngle - indicatorAngle * index;
        var angleR = Math.toRadians(angle);
        var x;
        if (screenShape == System.SCREEN_SHAPE_ROUND)  {
            x = dc.getWidth() / 2 + indicatorRadius * Math.sin(angleR);
        } else {
            x = indicatorSize*2;
        }
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

    function onTimer() as Void {
        WatchUi.requestUpdate();
    }

}
