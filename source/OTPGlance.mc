import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Timer;
import Toybox.Application;
import Toybox.Lang;

import Otp;

(:glance)
class OTPGlance extends WatchUi.GlanceView {
  const LIVE_UPDATE = "liveUpdate";
  const LINE_HEIGHT = 7;

  var otp;
  var timer;
  var firstRun as Boolean;
  var suppressLiveUpdates as Boolean = false;
  var liveGlances as Boolean;
  var liveGlancesStored = false;
  var title as String?;
  var refreshCount;
  var topOffset = 0;
  var bottomOffset = 0;

  function initialize(otp) {
    GlanceView.initialize();
    self.otp = otp;
    self.firstRun = true;
    self.liveGlances = false;
    self.refreshCount = 0;

    topOffset = (
      WatchUi.loadResource(Rez.JsonData.GlanceTopOffset) as String
    ).toNumber();

    bottomOffset = (
      WatchUi.loadResource(Rez.JsonData.GlanceBottomOffset) as String
    ).toNumber();

    var lv = Application.Storage.getValue(LIVE_UPDATE);
    liveGlancesStored = lv != null;
    if (lv != null && lv == true) {
      self.liveGlances = true;
      self.firstRun = false;
      System.println("Enabling live updates");
    }
    var supportsLiveGlances =
      WatchUi.loadResource(Rez.JsonData.LiveGlances) as String;
    var showLiveGlance =
      Application.Properties.getValue("show_glance") as Boolean;
    if (supportsLiveGlances.equals("FALSE") || !showLiveGlance) {
      System.println("Force disable live glances");
      self.suppressLiveUpdates = true;
    }
  }

  function timerCallback() as Void {
    WatchUi.requestUpdate();
    if (liveGlances) {
      timer.start(method(:timerCallback), 1000, false);
      if (!liveGlancesStored) {
        // save
        Application.Storage.setValue(LIVE_UPDATE, true);
        self.liveGlancesStored = true;
      }
    } else {
      if (!self.firstRun) {
        if (refreshCount > 3 && !liveGlances) {
          // if liveGlances hasn't changed to true in 3 refreshes, just forget about it
          return;
        }
        if (refreshCount < 5) {
          refreshCount += 1;
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

    var h = dc.getHeight();

    dc.drawText(
      5,
      h / 2,
      Graphics.FONT_MEDIUM,
      title,
      Graphics.TEXT_JUSTIFY_LEFT + Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawLiveGlance(dc) {
    if (otp == null) {
      drawSimpleGlance(dc);
      return;
    }

    var w = dc.getWidth();
    var h = dc.getHeight();
    var y = topOffset;

    // next two lines are used for debugging glance rendering
    // dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
    // dc.fillRectangle(0, 0, w, h);

    var codeHeight =
      dc.getFontHeight(Graphics.FONT_GLANCE_NUMBER) -
      dc.getFontDescent(Graphics.FONT_GLANCE_NUMBER);
    var nameHeight = dc.getFontHeight(Graphics.FONT_GLANCE);

    var dividerHeight =
      (dc.getHeight() - codeHeight - nameHeight - LINE_HEIGHT) / 2;
    if (dividerHeight < 0) {
      dividerHeight = 0;
    }

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    dc.drawText(
      5,
      y,
      Graphics.FONT_GLANCE_NUMBER,
      otp.getOtp().code(),
      Graphics.TEXT_JUSTIFY_LEFT
    );
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

    y = y + dividerHeight + codeHeight;
    dc.drawText(
      5,
      y,
      Graphics.FONT_GLANCE,
      otp.getName(),
      Graphics.TEXT_JUSTIFY_LEFT
    );
    var lineY = h - LINE_HEIGHT + bottomOffset;

    var x = ((w - 10) * otp.getOtp().getPercentTimeLeft()).toNumber();
    if (otp.getOtp().getSecondsLeft() < 5) {
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    }
    dc.setPenWidth(LINE_HEIGHT);
    dc.drawLine(5, lineY, x, lineY);
    dc.setPenWidth(LINE_HEIGHT);
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.drawLine(x, lineY, w - 5, lineY);
  }

  // onUpdate() is called periodically to update the View
  function onUpdate(dc) {
    if (firstRun || suppressLiveUpdates || (self.otp == null && !liveGlances)) {
      drawSimpleGlance(dc);
      firstRun = false;
    } else {
      self.liveGlances = true;
      drawLiveGlance(dc);
    }
  }
}
