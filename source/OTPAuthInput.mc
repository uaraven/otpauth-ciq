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
    if (WatchUi has :cancelAllAnimations) {
      WatchUi.cancelAllAnimations();
    }
    otpView.nextCode();
    return true;
  }

  function onPreviousPage() {
    if (WatchUi has :cancelAllAnimations) {
      WatchUi.cancelAllAnimations();
    }
    otpView.prevCode();
    return true;
  }
}
