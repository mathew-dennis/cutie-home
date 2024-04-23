#ifndef LAUNCHER_H
#define LAUNCHER_H

#include <QObject>
#include <QSettings>
#include <QProcess>
#include <QDir>

class Launcher : public QObject {
	Q_OBJECT

public:
    explicit Launcher(QQuickView *view, QObject *parent = nullptr);

private:
    QQuickView *m_view; // Store a pointer to the QQuickView instance
	
	Q_INVOKABLE void loadAppList();

    public Q_SLOTS:

    signals:

    private:
	static bool readDesktopFile(QIODevice &device,
				    QSettings::SettingsMap &map);
	QSettings::Format desktopFormat;
};

#endif // LAUNCHER_H