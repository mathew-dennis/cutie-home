#ifndef LAUNCHER_H
#define LAUNCHER_H

#include <QObject>
#include <QSettings>
#include <QProcess>
#include <QDir>
#include <QQuickView>

class Launcher : public QObject {
	Q_OBJECT

public:
    explicit Launcher(QQuickView *view, QObject *parent = nullptr);
    Q_INVOKABLE void loadAppList();

private:
    QQuickView *m_view; // Store a pointer to the QQuickView instance

    public Q_SLOTS:

    signals:

    private:
	static bool readDesktopFile(QIODevice &device,
				    QSettings::SettingsMap &map);
	QSettings::Format desktopFormat;
};

#endif // LAUNCHER_H