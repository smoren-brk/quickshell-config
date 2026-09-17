pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQml.Models

Singleton {
    id: root

    property alias notificationModel: notificationListModel
    property alias popupNotificationModel: popupListModel
    readonly property int notificationCount: notificationListModel.count
    readonly property int popupNotificationCount: popupListModel.count

    function iconSource(notification: var): string {
        const source = notification.image || notification.appIcon;
        if (!source)
            return "";
        if (source.startsWith("/") )
            return "file://" + source;
        if (source.includes(":"))
            return source;
        return Quickshell.iconPath(source);
    }

    function notificationRecord(notification: var): var {
        return {
            notification: notification,
            notificationId: notification.id,
            appName: notification.appName || "Notification",
            summary: notification.summary || "Notification",
            body: notification.body || "",
            icon: iconSource(notification),
            receivedAt: new Date()
        };
    }

    function removeById(notificationId: int): void {
        for (let index = 0; index < notificationListModel.count; index++) {
            if (notificationListModel.get(index).notificationId === notificationId) {
                notificationListModel.remove(index);
                break;
            }
        }
        removePopupById(notificationId);
    }

    function removePopupById(notificationId: int): void {
        for (let index = 0; index < popupListModel.count; index++) {
            if (popupListModel.get(index).notificationId === notificationId) {
                popupListModel.remove(index);
                return;
            }
        }
    }

    function dismissById(notificationId: int): void {
        for (let index = 0; index < notificationListModel.count; index++) {
            const record = notificationListModel.get(index);
            if (record.notificationId === notificationId) {
                const notification = record.notification;
                removeById(notificationId);
                if (notification)
                    notification.dismiss();
                return;
            }
        }
    }

    function clear(): void {
        const tracked = [];
        for (let index = 0; index < notificationListModel.count; index++)
            tracked.push(notificationListModel.get(index).notification);
        notificationListModel.clear();
        popupListModel.clear();
        for (const notification of tracked) {
            if (notification)
                notification.dismiss();
        }
    }

    Instantiator {
        model: server.trackedNotifications
        delegate: Connections {
            required property var modelData
            target: modelData
            function onClosed(reason) { root.removeById(modelData.id); }
        }
    }

    ListModel { id: notificationListModel }
    ListModel { id: popupListModel }

    NotificationServer {
        id: server

        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        actionsSupported: false
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => {
            notification.tracked = true;
            root.removeById(notification.id);
            const record = root.notificationRecord(notification);
            notificationListModel.insert(0, record);
            popupListModel.append(record);
        }
    }
}
