import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;
import Toybox.Math;
import Toybox.Lang;

class OTPAuthView extends WatchUi.View {
  const indicatorAngle = 7.5;
  const ANIM_TIME = 0.2;
  const INSTINCT_INDICATOR_LINE_WIDTH = 6;
  const INDICATOR_LINE_WIDTH = 8;

  var codeStore;

  var updateTimer;

  var indicatorSize; // size of dots indicator
  var startingAngle;
  var indicatorRadius;
  var isInstinct as Boolean;
  var isCrossover as Boolean;

  var instinctOffsetY = 0; // second screen offset from top right corner
  var instinctOffsetX = 0;
  var instinctR = 0;

  var screenShape;

  var noCodes as WatchUi.Text?;
  var code as WatchUi.Text?;
  var name as WatchUi.Text?;

  var screenHeight as Number?;

  var codeY as Number?;
  var nameY as Number?;

  var scrolling as Boolean = false;

  function initialize() {
    View.initialize();
    codeStore = new CodeStore();
    updateTimer = new Timer.Timer();
    isInstinct = WatchUi.loadResource(Rez.JsonData.Instinct) as Boolean;
    var settings = System.getDeviceSettings();
    screenShape = settings.screenShape;

    isCrossover = WatchUi.View has :setClockHandPosition;
  }

  function min(a, b) {
    return a < b ? a : b;
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.MainLayout(dc));

    code = View.findDrawableById("code") as WatchUi.Text;
    name = View.findDrawableById("name") as WatchUi.Text;
    noCodes = View.findDrawableById("no_codes") as WatchUi.Text;

    screenHeight = dc.getHeight();
    codeY = code.locY;
    nameY = name.locY;

    var r = min(dc.getWidth(), dc.getHeight());
    indicatorSize = r / 65;
    if (codeStore.size() % 2 == 0) {
      startingAngle = 270 + ((indicatorAngle / 2) * codeStore.size()) / 2;
    } else {
      startingAngle = 270 + indicatorAngle * (codeStore.size() / 2).toNumber();
    }
    indicatorRadius = r / 2 - indicatorSize - 20;
    if (isInstinct) {
      if (WatchUi has :getSubscreen) {
        var w = dc.getWidth();
        var secondary = WatchUi.getSubscreen();
        if (secondary != null) {
          instinctR =
            min(secondary.width / 2, secondary.height / 2) -
            INSTINCT_INDICATOR_LINE_WIDTH;
          instinctOffsetX = w - (secondary.x + secondary.width / 2);
          instinctOffsetY = secondary.y + secondary.height / 2 - 1;
        }
      } else {
        if (dc.getWidth() == 176) {
          //instinct 2
          instinctOffsetX = 31;
          instinctOffsetY = 31;
          instinctR = 28;
        } else {
          // instinct 2s
          instinctOffsetX = 25;
          instinctOffsetY = 25;
          instinctR = 20;
        }
      }
    }
  }

  function nextCode() {
    if (codeStore.size() <= 1) {
      return;
    }
    scrolling = true; // disable showing new code until we scrolled the old one out of view
    codeStore.selectNext();
    codeStore.getOtpCode().getOtp().code(); // ensure the new code is calculated *before* we start animation

    // start scrolling
    animateOut(code, codeY, -40, method(:scrollCodeInFromBelow));
    animateOut(name, nameY, -20, method(:scrollNameInFromBelow));
  }

  function prevCode() {
    if (codeStore.size() <= 1) {
      return;
    }
    scrolling = true; // disable showing new code until we scrolled the old one out of view
    codeStore.selectPrev();
    codeStore.getOtpCode().getOtp().code(); // ensure the new code is calculated *before* we start animation

    // start scrolling
    animateOut(code, codeY, screenHeight + 20, method(:scrollCodeInFromAbove));
    animateOut(name, nameY, screenHeight + 40, method(:scrollNameInFromAbove));
  }

  function scrollCodeInFromBelow() as Void {
    scrolling = false; // enable showing the new code
    animateIn(code, screenHeight + 20, codeY, null);
  }

  function scrollNameInFromBelow() as Void {
    animateIn(name, screenHeight + 40, nameY, null);
  }

  function scrollCodeInFromAbove() as Void {
    scrolling = false; // enable showing the new code
    animateIn(code, -40, codeY, null);
  }

  function scrollNameInFromAbove() as Void {
    animateIn(name, -20, nameY, null);
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    updateTimer.start(method(:onTimer), 500, true);
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
    if (!scrolling) {
      if (codeStore.isEmpty()) {
        code.setText("");
        name.setText("");
      } else {
        var otpCode = codeStore.getOtpCode();
        noCodes.setText("");
        code.setText(otpCode.getOtp().code());
        name.setText(otpCode.getName());
      }
    }
    View.onUpdate(dc);
    if (!codeStore.isEmpty()) {
      if (isCrossover) {
        drawTimestepCrossover();
      } else if (isInstinct) {
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

    dc.setPenWidth(INDICATOR_LINE_WIDTH);
    var start = 90;
    var end = (360 * percentTimeLeft + 90).toNumber();
    var w = dc.getWidth();
    var h = dc.getHeight();
    var color =
      codeStore.getOtpCode().getOtp().getSecondsLeft() < 5
        ? Graphics.COLOR_RED
        : Graphics.COLOR_BLUE;
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    dc.drawArc(
      w / 2,
      h / 2,
      h / 2 - 3,
      Graphics.ARC_COUNTER_CLOCKWISE,
      start,
      end
    );
  }

  function drawTimeStepSquare(dc as Dc) as Void {
    var percentTimeLeft = codeStore.getOtpCode().getOtp().getPercentTimeLeft();

    dc.setPenWidth(INDICATOR_LINE_WIDTH);
    var w = dc.getWidth();
    var h = dc.getHeight();
    var end = ((w - 10) * percentTimeLeft).toNumber();
    var color =
      codeStore.getOtpCode().getOtp().getSecondsLeft() < 5
        ? Graphics.COLOR_RED
        : Graphics.COLOR_BLUE;
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    dc.drawLine(5, h - 10, end, h - 10);
  }

  (:crossover)
  function drawTimestepCrossover() as Void {
    var percentTimeLeft = codeStore.getOtpCode().getOtp().getPercentTimeLeft();

    var angle = 180 * percentTimeLeft - 90;

    setClockHandPosition({
      :clockState => ANALOG_CLOCK_STATE_HOLDING,
      :hour => -90,
      :minute => angle,
    });
  }

  (:allDevices)
  function drawTimestepCrossover() as Void {}
  (:instinct)
  function drawTimestepCrossover() as Void {}

  (:allDevices)
  function drawTimeStepInstinct(dc as Dc) as Void {}
  (:crossover)
  function drawTimeStepInstinct(dc as Dc) as Void {}

  (:instinct)
  function drawTimeStepInstinct(dc as Dc) as Void {
    var percentTimeLeft = codeStore.getOtpCode().getOtp().getPercentTimeLeft();

    dc.setPenWidth(INSTINCT_INDICATOR_LINE_WIDTH);
    var start = 90;
    var end = (360 * percentTimeLeft + 90).toNumber();
    var w = dc.getWidth();
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawArc(
      w - instinctOffsetX,
      instinctOffsetY,
      instinctR,
      Graphics.ARC_COUNTER_CLOCKWISE,
      start,
      end
    );
  }

  function drawIndicator(dc as Dc) as Void {
    if (codeStore.size() > 1) {
      for (var i = 0; i < codeStore.size(); i++) {
        drawItemCircle(dc, i, i == codeStore.getIndex());
      }
    }
  }

  function drawItemCircle(
    dc as Dc,
    index as Numeric,
    selected as Boolean
  ) as Void {
    var angle = startingAngle - indicatorAngle * index;
    var angleR = Math.toRadians(angle);
    var x;
    if (screenShape == System.SCREEN_SHAPE_ROUND) {
      x = dc.getWidth() / 2 + indicatorRadius * Math.sin(angleR);
    } else {
      x = indicatorSize * 2;
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
    if (isCrossover) {
      setClockHandPosition({
        :clockState => ANALOG_CLOCK_STATE_SYSTEM_TIME,
      });
    }
    System.println("Stopping widget");
  }

  function onTimer() as Void {
    WatchUi.requestUpdate();
  }

  function animateOut(object, ystart, yend, callback) {
    WatchUi.animate(
      object,
      :locY,
      WatchUi.ANIM_TYPE_EASE_OUT,
      ystart,
      yend,
      ANIM_TIME,
      callback
    );
  }

  function animateIn(object, ystart, yend, callback) {
    WatchUi.animate(
      object,
      :locY,
      WatchUi.ANIM_TYPE_EASE_IN,
      ystart,
      yend,
      ANIM_TIME,
      callback
    );
  }
}
