#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtGui/QGuiApplication>
#include <QScreen>
#include <qpa/qplatformscreen.h>

#include "settings.h"

Settings::Settings(QObject *parent)
	: QObject(parent)
{
	m_desktopFormat =
		QSettings::registerFormat("desktop", readDesktopFile, nullptr);
}

bool Settings::readDesktopFile(QIODevice &device, QSettings::SettingsMap &map)
{
	QTextStream in(&device);
	QString header;
	while (!in.atEnd()) {
		QString line = in.readLine();
		if (line.startsWith("[") && line.endsWith("]")) {
			header = line.sliced(1).chopped(1);
		} else if (line.contains("=")) {
			map.insert(header + "/" + line.split("=").at(0),
				   line.sliced(line.indexOf('=') + 1));
		} else if (!line.isEmpty() && !line.startsWith("#")) {
			return false;
		}
	}

	return true;
}

void Settings::execApp(QString command)
{
	QStringList args = QStringList();
	args.append("-c");
	args.append(command);
	if (!QProcess::startDetached("bash", args))
		qDebug() << "Failed to run";
}

void Settings::autostart()
{
	QStringList dataDirList;
	dataDirList.append("/etc/xdg");
	dataDirList.append("~/.config");
	for (int dirI = 0; dirI < dataDirList.count(); dirI++) {
		QDir *curAppDir = new QDir(dataDirList.at(dirI) + "/autostart");
		if (curAppDir->exists()) {
			QStringList entryFiles =
				curAppDir->entryList(QDir::Files);
			for (int fileI = 0; fileI < entryFiles.count();
			     fileI++) {
				QString curEntryFileName = entryFiles.at(fileI);
				QSettings *curEntryFile = new QSettings(
					dataDirList.at(dirI) + "/autostart/" +
						curEntryFileName,
					m_desktopFormat);
				QString desktopType =
					curEntryFile
						->value("Desktop Entry/Type")
						.toString();
				if (desktopType == "Application") {
					QString appName =
						curEntryFile
							->value("Desktop Entry/Name")
							.toString();
					QString appHidden =
						curEntryFile
							->value("Desktop Entry/Hidden")
							.toString();
					QString appExec =
						curEntryFile
							->value("Desktop Entry/Exec")
							.toString();
					if (appName != "" && appExec != "" &&
					    appHidden != "true")
						execApp(appExec);
				}
				delete curEntryFile;
			}
		}
		delete curAppDir;
	}
}
