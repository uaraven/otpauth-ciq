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

  private var view;

  function getInitialView() as [WatchUi.Views] or
    [WatchUi.Views, WatchUi.InputDelegates] {
    var authView = new OTPAuthView();
    view = authView;
    return [authView, new OTPAuthInput(authView)];
  }

  function onSettingsChanged() as Void {
    if (view != null) {
      view.reload();
    }
    WatchUi.requestUpdate();
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
