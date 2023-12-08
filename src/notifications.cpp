#include "notifications.h"

#include <QQuickView>
#include <QQuickItem>

Notifications::Notifications(QObject *parent) : QObject(parent)
{
}

QStringList Notifications::GetCapabilities() {
    QStringList caps = QStringList();
    caps.append("body");
    caps.append("persistence");
    return caps;
}

uint Notifications::Notify(QString app_name, uint replaces_id, QString app_icon, QString summary, QString body, QStringList actions, QVariantMap hints, int expire_timeout) {
    ++currentId;
    if (replaces_id != 0) {
        QMetaObject::invokeMethod(((QQuickView *)parent())->rootObject(), "delNotification", Q_ARG(QVariant, replaces_id));
    }
    QMetaObject::invokeMethod(((QQuickView *)parent())->rootObject(), "addNotification", 
        Q_ARG(QVariant, summary), Q_ARG(QVariant, body), Q_ARG(QVariant, (replaces_id != 0) ? replaces_id : currentId));
    return (replaces_id != 0) ? replaces_id : currentId;
}

void Notifications::CloseNotification(uint id) {
    QMetaObject::invokeMethod(((QQuickView *)parent())->rootObject(), "delNotification", Q_ARG(QVariant, id));
}

QString Notifications::GetServerInformation(QString &vendor, QString &version, QString &spec_version) {
    vendor = "Cutie Community Project";
    version = "0.0.1";
    spec_version = "1.2";
    return "Cutie Shell";
}
