import Toybox.WatchUi;

class OTPAuthInput extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        onNextPage();
    }

    function onNextPage() {
        codeStore.selectNext();
        WatchUi.requestUpdate();
    }

    function onPreviousPage() {
        codeStore.selectPrev(); 
        WatchUi.requestUpdate();
    }
}

