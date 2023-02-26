import Toybox.WatchUi;

class OTPAuthInput extends WatchUi.BehaviorDelegate {

    private var otpView as OTPAuthView;

    function initialize(view as OTPAuthView) {
        BehaviorDelegate.initialize();
        otpView = view;
    }

    function onSelect() {
        onNextPage();
        return true;
    }

    function onNextPage() {
        WatchUi.cancelAllAnimations();
        otpView.nextCode();
        return true;
    }

    function onPreviousPage() {
        WatchUi.cancelAllAnimations();
        otpView.prevCode();
        return true;
    }

}

