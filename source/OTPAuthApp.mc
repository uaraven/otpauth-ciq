import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Otp;

(:glance)
class OTPAuthApp extends Application.AppBase {

    var liveUpdates = false;

    function initialize() {
        AppBase.initialize();
        liveUpdates = Application.loadResource(Rez.JsonData.LiveUpdates);
        System.println("LiveUpdates: " + liveUpdates);
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new OTPAuthView(), new OTPAuthInput() ] as Array<Views or InputDelegates>;
    }

    function getGlanceView() {
        if (liveUpdates) {
            var store = new CodeStore();
            var otp = store.getOtpCode();
            if (otp == null) {
                return [ new OTPSimpleGlance() ];
            } else {
                return [ new OTPLiveGlance(otp) ];
            }
        } else {
            return [ new OTPSimpleGlance() ];
        }
    }
}

function getApp() as OTPAuthApp {
    return Application.getApp() as OTPAuthApp;
}
