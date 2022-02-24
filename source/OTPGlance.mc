import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Timer;
import Toybox.Application;

import Otp;

(:glance)
class OTPGlance extends WatchUi.GlanceView {

    const LIVE_UPDATE = "liveUpdate";

    var otp;
    var timer;
    var firstRun as Boolean;
    var liveGlances as Boolean;
    var liveGlancesStored = false;
    var title as String;
    var refreshCount;

    function initialize(otp) {
        GlanceView.initialize();
        self.otp = otp;
        self.firstRun = true;
        self.liveGlances = false;
        self.refreshCount = 0;

        var lv = Application.Storage.getValue(LIVE_UPDATE);
        if (lv != null && lv == true) {
            self.liveGlances = true;
            self.firstRun = false;
            self.liveGlancesStored = true;
            System.println("Enabling live updates");
        }
    }

    function timerCallback() {
        WatchUi.requestUpdate();
        if (liveGlances) {
            timer.start(method(:timerCallback), 1000, false);
            if (!liveGlancesStored) { // save 
                Application.Storage.setValue(LIVE_UPDATE, true);
                self.liveGlancesStored = true;
            }
        } else {
            if (!self.firstRun) {
                if (refreshCount > 3 && !liveGlances)  { // if liveGlances hasn't changed to true in 3 refreshes, just forget about it
                    return;
                }
                if (refreshCount < 5) {
                    refreshCount +=1;  
                }
                timer.start(method(:timerCallback), 1000, false);
            }
        }
    }

    function onShow() {
        View.onShow();
        timer = new Timer.Timer();
        timer.start(method(:timerCallback), 250, false);
        System.println("Starting glance");
    }

    function onHide() {
        View.onHide();
        timer.stop();
        System.println("Closing glance");
    }

    // Resources are loaded here
    function onLayout(dc) {
        title = WatchUi.loadResource(Rez.Strings.GlanceTitle);
    }

    function drawSimpleGlance(dc) {
        View.onUpdate(dc);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.drawText(5, h/2, Graphics.FONT_MEDIUM, title, Graphics.TEXT_JUSTIFY_LEFT + Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawLiveGlance(dc) {
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

    // onUpdate() is called periodically to update the View
    function onUpdate(dc) {
        if (firstRun || self.otp == null && !liveGlances) {
            drawSimpleGlance(dc);
            firstRun = false;
        } else {
            self.liveGlances = true;
            drawLiveGlance(dc);
        }
    }
}