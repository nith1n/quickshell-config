// Notifications.qml
pragma Singleton

import QtQuick
import Quickshell.Services.Notifications

NotificationServer {
    id: root

    // Do Not Disturb flag
    property bool dnd: false

    // Active popup toasts currently showing on-screen
    property var popups: []

    bodySupported: true
    bodyMarkupSupported: true
    bodyHyperlinksSupported: true
    bodyImagesSupported: true
    actionsSupported: true
    imageSupported: true

    onNotification: (notif) => {
        // Track the notification so it stays in history
        notif.tracked = true;

        // Auto-remove from popups if dismissed or closed
        notif.closed.connect((reason) => {
            root.removePopup(notif);
        });

        // Show toast banner if Do Not Disturb is off
        if (!root.dnd) {
            root.addPopup(notif);
        }
    }

    function addPopup(notif) {
        // Avoid duplicate popups for the same notification ID
        for (var i = 0; i < popups.length; i++) {
            if (popups[i] && popups[i].id === notif.id) return;
        }
        var list = popups.slice();
        list.push(notif);
        popups = list;
    }

    function removePopup(notif) {
        var list = [];
        for (var i = 0; i < popups.length; i++) {
            if (popups[i] && popups[i].id !== notif.id) {
                list.push(popups[i]);
            }
        }
        popups = list;
    }

    function clearAll() {
        if (!trackedNotifications || !trackedNotifications.values) return;
        var list = trackedNotifications.values.slice();
        for (var i = 0; i < list.length; i++) {
            if (list[i]) {
                list[i].dismiss();
            }
        }
        popups = [];
    }

    function toggleDnd() {
        dnd = !dnd;
    }
}
