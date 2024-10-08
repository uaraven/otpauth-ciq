import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Otp;

(:glance)
class OTPAuthApp extends Application.AppBase {
  function initialize() {
    AppBase.initialize();
  }

  function getInitialView() as [WatchUi.Views] or
    [WatchUi.Views, WatchUi.InputDelegates] {
    var view = new OTPAuthView();
    return [view, new OTPAuthInput(view)];
  }

  function getGlanceView() {
    var store = new CodeStore();
    var otp = store.getOtpCode();
    return [new OTPGlance(otp)];
  }
}

function getApp() as OTPAuthApp {
  return Application.getApp() as OTPAuthApp;
}
