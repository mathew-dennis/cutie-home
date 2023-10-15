#pragma once

#include "dbus_interface.h"

class Settings : public QObject
{
    Q_OBJECT  
public:
    Settings(QObject* parent = 0);
    void execApp(QString command);
    void autostart();
private:
    static bool readDesktopFile(QIODevice &device, QSettings::SettingsMap &map);

    QSettings::Format m_desktopFormat;
};
