import Toybox.WatchUi;

class OTPAuthInput extends WatchUi.BehaviorDelegate {

    const ANIM_TIME = 0.20;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        onNextPage();
        return true;
    }

    function onNextPage() {
        WatchUi.cancelAllAnimations();
        animateText(code, codeY, -40, method(:scrollCodeInFromBelow));
        animateText(name, nameY, -20, method(:scrollNameInFromBelow));
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        WatchUi.cancelAllAnimations();
        animateText(code, codeY, screenHeight+20, method(:scrollCodeInFromAbove));
        animateText(name, nameY, screenHeight+40, method(:scrollNameInFromAbove));
        WatchUi.requestUpdate();
        return true;
    }

    function scrollCodeInFromBelow() as Void {
        codeStore.selectNext();
        animateText(code, screenHeight+20, codeY, null);
    }

    function scrollNameInFromBelow() as Void {
        animateText(name, screenHeight+40, nameY, null);
    }

    function scrollCodeInFromAbove() as Void {
        codeStore.selectPrev();
        animateText(code, -40, codeY, null);
    }

    function scrollNameInFromAbove() as Void {
        animateText(name, -20, nameY, null);
    }

    function animateText(object, ystart, yend, callback) {
        WatchUi.animate(object, :locY, WatchUi.ANIM_TYPE_EASE_OUT, ystart, yend, ANIM_TIME, callback);
    }
}

