#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtGui/QGuiApplication>
#include <QStandardPaths>

#include <launcher.h>

Launcher::Launcher(QQuickView *view, QObject *parent)
    : QObject(parent), m_view(view)
{
	this->desktopFormat =
		QSettings::registerFormat("desktop", readDesktopFile, nullptr);
}

bool Launcher::readDesktopFile(QIODevice &device, QSettings::SettingsMap &map)
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

void Launcher::loadAppList()
{
	QStringList dataDirList = QStandardPaths::standardLocations(
		QStandardPaths::ApplicationsLocation);
	qDebug() << dataDirList;
	for (int dirI = 0; dirI < dataDirList.count(); dirI++) {
		QDir *curAppDir = new QDir(dataDirList.at(dirI));
		if (curAppDir->exists()) {
			QStringList entryFiles =
				curAppDir->entryList(QDir::Files);
			for (int fileI = 0; fileI < entryFiles.count();
			     fileI++) {
				QString curEntryFileName = entryFiles.at(fileI);
				QSettings *curEntryFile = new QSettings(
					dataDirList.at(dirI) + "/" +
						curEntryFileName,
					desktopFormat);
				QString desktopType =
					curEntryFile
						->value("Desktop Entry/Type")
						.toString();
				if (desktopType == "Application") {
					QVariantMap appData;
					QStringList keys =
						curEntryFile->allKeys();
					foreach(QString key, keys) {
						appData.insert(
							key,
							curEntryFile->value(
								key));
					}

					QString appHidden =
						curEntryFile
							->value("Desktop Entry/Hidden")
							.toString();
					QString appNoDisplay =
						curEntryFile
							->value("Desktop Entry/NoDisplay")
							.toString();
					qDebug() << "Loading app list...";
					if (appHidden != "true" && appNoDisplay != "true") {
 					   QObject *rootObject = m_view->rootObject();
   					   QQuickItem *rootItem = qobject_cast<QQuickItem *>(rootObject);
   					   if (rootItem) {
          				    qDebug() << "Loading app list...";
      					    QMetaObject::invokeMethod(rootItem, "addApp", Q_ARG(QVariant, appData));
    					} else {
      					    qDebug() << "Error: Root item is null or cannot be cast to QQuickItem";
   					    }
					}
				}
				delete curEntryFile;
			}
		}
		delete curAppDir;
	}
}