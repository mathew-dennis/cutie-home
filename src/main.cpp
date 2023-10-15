#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "settings.h"
#include "notifications.h"
#include "NotificationsAdaptor.h"
#include <QLoggingCategory>
#include <QIcon>
#include <QQuickView>
#include <LayerShellQt6/shell.h>
#include <LayerShellQt6/window.h>

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
    layerShell->setLayer(LayerShellQt::Window::LayerBottom);
    layerShell->setAnchors(LayerShellQt::Window::AnchorTop);
    layerShell->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityNone);
    layerShell->setExclusiveZone(-1);

    view.setSource(QUrl("qrc:/main.qml"));
    view.show();

    Settings *settings = new Settings(view.engine());
    settings->autostart();

    return app.exec();
}
