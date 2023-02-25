import Toybox.WatchUi;

class OTPAuthInput extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        onNextPage();
        return true;
    }

    function onNextPage() {
        codeStore.selectNext();
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        codeStore.selectPrev(); 
        WatchUi.requestUpdate();
        return true;
    }
}

