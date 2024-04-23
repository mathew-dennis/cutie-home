#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <QQmlContext>
#include "settings.h"
#include "notifications.h"
#include "NotificationsAdaptor.h"
#include <QLoggingCategory>
#include <QIcon>
#include <QQuickView>
#include <LayerShellQt6/shell.h>
#include <LayerShellQt6/window.h>
#include "launcher.h" // Include the header file for launcher

int main(int argc, char *argv[])
{
	LayerShellQt::Shell::useLayerShell();

	QIcon::setThemeName("hicolor");
	QIcon::setThemeSearchPaths(QStringList("/usr/share/icons"));

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

	QCoreApplication::setOrganizationName("Cutie Community Project");
	QCoreApplication::setApplicationName("Cutie Shell");

	QGuiApplication app(argc, argv);
	QQuickView view;

	LayerShellQt::Window *layerShell = LayerShellQt::Window::get(&view);
	layerShell->setLayer(LayerShellQt::Window::LayerBackground);
	layerShell->setAnchors(LayerShellQt::Window::AnchorTop);
	layerShell->setKeyboardInteractivity(
		LayerShellQt::Window::KeyboardInteractivityNone);
	layerShell->setExclusiveZone(-1);
	layerShell->setScope("cutie-home");

	view.setSource(QUrl("qrc:/main.qml"));
	view.setColor(QColor(Qt::transparent));
	view.show();

	QQmlApplicationEngine engine;
	Launcher *launcher = new Launcher(&engine);
	engine.rootContext()->setContextProperty("launcher", launcher);
   	
	engine.load(url);
	launcher->loadAppList();
    
	Settings *settings = new Settings(view.engine());
	settings->autostart();

	Notifications *notifications = new Notifications(&view);
	new NotificationsAdaptor(notifications);
	QDBusConnection::sessionBus().registerObject(
		"/org/freedesktop/Notifications", notifications);
	QDBusConnection::sessionBus().registerService(
		"org.freedesktop.Notifications");

	return app.exec();
}