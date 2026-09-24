pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQml.Models
import "../components/theme"
import "NotificationData.js" as NotificationData

Singleton {
    id: root

    property var notifications: []
    property var popupIds: []
    property var popupDeadlines: ({})
    property var popupHolds: ({})
    property double lastPopupTick: Date.now()
    readonly property var notificationGroups: NotificationData.group(notifications)
    readonly property var popupGroups: NotificationData.group(notifications.filter(record =>
        popupIds.indexOf(record.notificationId) !== -1))
    readonly property int notificationCount: notifications.length
    readonly property int popupNotificationCount: popupIds.length

    function iconSource(notification: var): string {
        const source = notification.appIcon || notification.image;
        if (!source)
            return "";
        if (source.startsWith("/"))
            return "file://" + source;
        if (source.includes(":"))
            return source;
        return Quickshell.iconPath(source);
    }

    function notificationRecord(notification: var): var {
        return {
            notification: notification,
            notificationId: notification.id,
            sourceKey: NotificationData.sourceKey(notification),
            appName: notification.appName || "Notification",
            summary: notification.summary || "Notification",
            body: notification.body || "",
            icon: iconSource(notification),
            receivedAt: new Date(),
            actions: Array.from(notification.actions).map(action => ({
                identifier: action.identifier, text: action.text
            }))
        };
    }

    function receive(notification: var, showPopup: bool): void {
        if (!notification || !notification.tracked)
            return;
        const record = notificationRecord(notification);
        notifications = [record].concat(notifications.filter(item => item.notificationId !== notification.id));
        if (showPopup) {
            const timeout = notification.expireTimeout;
            popupDeadlines[notification.id] = timeout === 0 ? Infinity
                : Date.now() + (timeout > 0 ? timeout : ShellMetrics.popupTimeoutMs);
            if (popupIds.indexOf(notification.id) === -1)
                popupIds = [notification.id].concat(popupIds);
        }
    }

    function removeById(notificationId: int): void {
        notifications = notifications.filter(record => record.notificationId !== notificationId);
        removePopupById(notificationId);
    }

    function removePopupById(notificationId: int): void {
        popupIds = popupIds.filter(id => id !== notificationId);
        delete popupDeadlines[notificationId];
    }

    function dismissById(notificationId: int): void {
        const record = notifications.find(record => record.notificationId === notificationId);
        removeById(notificationId);
        if (record && record.notification)
            record.notification.dismiss();
    }

    function invokeAction(notificationId: int, identifier: string): void {
        const record = notifications.find(record => record.notificationId === notificationId);
        if (!record || !record.notification)
            return;
        const action = Array.from(record.notification.actions).find(action => action.identifier === identifier);
        if (action)
            action.invoke();
    }

    function clear(): void {
        const tracked = notifications.slice();
        notifications = [];
        popupIds = [];
        popupDeadlines = ({});
        for (const record of tracked) {
            if (record.notification)
                record.notification.dismiss();
        }
    }

    function holdPopups(owner: string, held: bool): void {
        if (held)
            popupHolds[owner] = true;
        else
            delete popupHolds[owner];
    }

    // Timers live in the service so hidden overflow notifications still expire.
    function expirePopups(): void {
        const now = Date.now();
        const elapsed = now - lastPopupTick;
        lastPopupTick = now;
        const held = Object.keys(popupHolds).length > 0;
        for (const id of popupIds.slice()) {
            if (held)
                popupDeadlines[id] += elapsed;
            else if (popupDeadlines[id] <= now)
                removePopupById(id);
        }
    }

    Timer {
        interval: 250
        repeat: true
        running: root.popupNotificationCount > 0
        onRunningChanged: if (running) root.lastPopupTick = Date.now()
        onTriggered: root.expirePopups()
    }

    Instantiator {
        model: server.trackedNotifications
        delegate: Connections {
            required property var modelData
            target: modelData
            function onClosed(reason) { root.removeById(modelData.id); }
            // Replacements update the existing object without emitting server.notification.
            // Coalesce its property changes into one refreshed card and timeout.
            function refresh() { root.receive(modelData, true); }
            function onSummaryChanged() { Qt.callLater(refresh); }
            function onBodyChanged() { Qt.callLater(refresh); }
            function onAppNameChanged() { Qt.callLater(refresh); }
            function onAppIconChanged() { Qt.callLater(refresh); }
            function onImageChanged() { Qt.callLater(refresh); }
            function onActionsChanged() { Qt.callLater(refresh); }
            function onDesktopEntryChanged() { Qt.callLater(refresh); }
            function onExpireTimeoutChanged() { Qt.callLater(refresh); }
            function onHintsChanged() { Qt.callLater(refresh); }
        }
    }

    NotificationServer {
        id: server
        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        actionsSupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => {
            notification.tracked = true;
            // Restored history should not reappear as a new popup after a reload.
            root.receive(notification, !notification.lastGeneration);
        }
    }
}
