#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "settings.h"
#include "notifications.h"
#include "NotificationsAdaptor.h"
#include <QLoggingCategory>
#include <QIcon>
#include <QDebug>
#include <QQuickView>
#include <QQmlError>
#include <QHash>
#include <QScreen>
#include <QSize>
#include <LayerShellQt/shell.h>
#include <LayerShellQt/window.h>

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

	Settings *settings = new Settings(view.engine());
	settings->autostart();

	Notifications *notifications = new Notifications(&view);
	new NotificationsAdaptor(notifications);
	QDBusConnection::sessionBus().registerObject(
		"/org/freedesktop/Notifications", notifications);
	QDBusConnection::sessionBus().registerService(
		"org.freedesktop.Notifications");

	QHash<QScreen *, QList<QQuickView *>> externalViews;
	auto watchQml = [](QQuickView *window, const QString &label) {
		QObject::connect(window, &QQuickView::statusChanged, window,
				 [window, label](QQuickView::Status status) {
					 if (status == QQuickView::Ready)
						 qInfo() << label << "QML ready";
					 else if (status == QQuickView::Error)
						 for (const QQmlError &error :
					      window->errors())
							 qWarning().noquote()
								 << label << error.toString();
				 });
	};
	auto removeExternalScreen = [&externalViews](QScreen *screen) {
		const QList<QQuickView *> windows = externalViews.take(screen);
		for (auto it = windows.crbegin(); it != windows.crend(); ++it) {
			(*it)->hide();
			delete *it;
		}
	};
	auto addExternalScreen = [&view, &externalViews,
				  watchQml](QScreen *screen) {
		if (!screen || screen == view.screen() ||
		    externalViews.contains(screen))
			return;
		qInfo() << "[cutie-home] creating external desktop for"
			<< screen->name() << screen->geometry() << "screen size"
			<< screen->size();
		const QSize screenSize = screen->geometry().size();

		auto *desktopView = new QQuickView(view.engine(), nullptr);
		watchQml(desktopView, QStringLiteral("[cutie-home wallpaper]"));
		desktopView->setResizeMode(QQuickView::SizeRootObjectToView);
		desktopView->setScreen(screen);
		LayerShellQt::Window *desktopLayer =
			LayerShellQt::Window::get(desktopView);
		desktopLayer->setScreenConfiguration(
			LayerShellQt::Window::ScreenFromQWindow);
		desktopLayer->setLayer(LayerShellQt::Window::LayerBackground);
		LayerShellQt::Window::Anchors desktopAnchors;
		desktopAnchors.setFlag(LayerShellQt::Window::AnchorTop);
		desktopAnchors.setFlag(LayerShellQt::Window::AnchorBottom);
		desktopAnchors.setFlag(LayerShellQt::Window::AnchorLeft);
		desktopAnchors.setFlag(LayerShellQt::Window::AnchorRight);
		desktopLayer->setAnchors(desktopAnchors);
		desktopLayer->setDesiredSize(screenSize);
		desktopLayer->setKeyboardInteractivity(
			LayerShellQt::Window::KeyboardInteractivityNone);
		desktopLayer->setExclusiveZone(-1);
		desktopLayer->setScope("cutie-home-external");
		desktopView->setSource(QUrl("qrc:/ExternalDesktop.qml"));
		desktopView->setColor(QColor(Qt::transparent));
		desktopView->resize(screenSize);
		desktopView->show();
		qInfo() << "[cutie-home] wallpaper window screen"
			<< desktopView->screen()->name() << "window size"
			<< desktopView->size();

		auto *dockView = new QQuickView(view.engine(), nullptr);
		watchQml(dockView, QStringLiteral("[cutie-home dock]"));
		dockView->setResizeMode(QQuickView::SizeRootObjectToView);
		dockView->setScreen(screen);
		LayerShellQt::Window *dockLayer =
			LayerShellQt::Window::get(dockView);
		dockLayer->setScreenConfiguration(
			LayerShellQt::Window::ScreenFromQWindow);
		dockLayer->setLayer(LayerShellQt::Window::LayerTop);
		LayerShellQt::Window::Anchors dockAnchors;
		dockAnchors.setFlag(LayerShellQt::Window::AnchorBottom);
		dockAnchors.setFlag(LayerShellQt::Window::AnchorLeft);
		dockAnchors.setFlag(LayerShellQt::Window::AnchorRight);
		dockLayer->setAnchors(dockAnchors);
		dockLayer->setDesiredSize(QSize(screenSize.width(), 88));
		dockLayer->setKeyboardInteractivity(
			LayerShellQt::Window::KeyboardInteractivityNone);
		dockLayer->setExclusiveZone(0);
		dockLayer->setScope("cutie-dock-external");
		dockView->setSource(QUrl("qrc:/ExternalDock.qml"));
		dockView->setColor(QColor(Qt::transparent));
		dockView->resize(screenSize.width(), 88);
		dockView->show();
		qInfo() << "[cutie-home] dock window screen"
			<< dockView->screen()->name() << "window size"
			<< dockView->size();

		externalViews.insert(
			screen, QList<QQuickView *>{ desktopView, dockView });
	};

	QObject::connect(&app, &QGuiApplication::screenAdded, &app,
			 [addExternalScreen](QScreen *screen) {
				 addExternalScreen(screen);
			 });
	QObject::connect(&app, &QGuiApplication::screenRemoved, &app,
			 [removeExternalScreen](QScreen *screen) {
				 removeExternalScreen(screen);
			 });
	for (QScreen *screen : app.screens())
		addExternalScreen(screen);
	QObject::connect(&app, &QCoreApplication::aboutToQuit, &app,
			 [&externalViews, &removeExternalScreen]() {
				 const auto screens = externalViews.keys();
				 for (QScreen *screen : screens)
					 removeExternalScreen(screen);
			 });

	return app.exec();
}
