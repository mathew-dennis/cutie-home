#include "AdditionalScreen.h"
#include <QQmlError>
#include <QQuickItem>
#include <QDebug>
#include <LayerShellQt/shell.h>
#include <LayerShellQt/window.h>

AdditionalScreen::AdditionalScreen(QGuiApplication *app, QQmlEngine *engine, QScreen *primaryScreen, QObject *parent)
    : QObject(parent), m_app(app), m_engine(engine), m_primaryScreen(primaryScreen)
{
    connect(m_app, &QGuiApplication::screenAdded, this, [this](QScreen *screen) {
        add(screen);
    });

    connect(m_app, &QGuiApplication::screenRemoved, this, [this](QScreen *screen) {
        remove(screen);
    });

    for (QScreen *screen : m_app->screens()) {
        add(screen);
    }

    connect(m_app, &QCoreApplication::aboutToQuit, this, [this]() {
        const auto screens = m_externalViews.keys();
        for (QScreen *screen : screens) {
            remove(screen);
        }
    });
}

AdditionalScreen::~AdditionalScreen()
{
    const auto screens = m_externalViews.keys();
    for (QScreen *screen : screens) {
        remove(screen);
    }
}

void AdditionalScreen::add(QScreen *screen)
{
    if (!screen || screen == m_primaryScreen || m_externalViews.contains(screen))
        return;

    qInfo() << "[cutie-home] creating external desktop for requested screen"
            << screen << screen->name() << "geometry" << screen->geometry()
            << "size" << screen->size() << "device pixel ratio" << screen->devicePixelRatio();

    const QSize screenSize = screen->geometry().size();

    auto watchQml = [](QQuickView *window, const QString &label) {
        QObject::connect(window, &QQuickView::statusChanged, window,
                 [window, label](QQuickView::Status status) {
                     if (status == QQuickView::Ready)
                         qInfo() << label << "QML ready";
                     else if (status == QQuickView::Error)
                         for (const QQmlError &error : window->errors())
                             qWarning().noquote() << label << error.toString();
                 });
    };

    // 1. External Wallpaper / Desktop View
    auto *desktopView = new QQuickView(m_engine, nullptr);
    watchQml(desktopView, QStringLiteral("[cutie-home wallpaper]"));
    desktopView->setResizeMode(QQuickView::SizeRootObjectToView);
    desktopView->setScreen(screen);

    LayerShellQt::Window *desktopLayer = LayerShellQt::Window::get(desktopView);
    desktopLayer->setScreenConfiguration(LayerShellQt::Window::ScreenFromQWindow);
    desktopLayer->setLayer(LayerShellQt::Window::LayerBackground);

    LayerShellQt::Window::Anchors desktopAnchors;
    desktopAnchors.setFlag(LayerShellQt::Window::AnchorTop);
    desktopAnchors.setFlag(LayerShellQt::Window::AnchorLeft);
    desktopAnchors.setFlag(LayerShellQt::Window::AnchorRight);
    desktopAnchors.setFlag(LayerShellQt::Window::AnchorBottom);
    desktopLayer->setAnchors(desktopAnchors);
    desktopLayer->setDesiredSize(screenSize);
    desktopLayer->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityNone);
    desktopLayer->setExclusiveZone(-1);
    desktopLayer->setScope(QStringLiteral("cutie-home-external-%1").arg(screen->name()));

    desktopView->setSource(QUrl("qrc:/ExternalDesktop.qml"));
    desktopView->setColor(QColor(Qt::transparent));
    desktopView->resize(screenSize);

    auto *desktopRoot = qobject_cast<QQuickItem *>(desktopView->rootObject());
    if (desktopRoot)
        desktopRoot->setSize(QSizeF(screenSize));
    desktopView->show();

    // 2. External Dock View (with AnchorRight and ExclusiveZone = 88)
    auto *dockView = new QQuickView(m_engine, nullptr);
    watchQml(dockView, QStringLiteral("[cutie-home dock]"));
    dockView->setResizeMode(QQuickView::SizeRootObjectToView);
    dockView->setScreen(screen);

    LayerShellQt::Window *dockLayer = LayerShellQt::Window::get(dockView);
    dockLayer->setScreenConfiguration(LayerShellQt::Window::ScreenFromQWindow);
    dockLayer->setLayer(LayerShellQt::Window::LayerTop);

    LayerShellQt::Window::Anchors dockAnchors;
    dockAnchors.setFlag(LayerShellQt::Window::AnchorBottom);
    dockAnchors.setFlag(LayerShellQt::Window::AnchorLeft);
    dockAnchors.setFlag(LayerShellQt::Window::AnchorRight);
    dockLayer->setAnchors(dockAnchors);
    dockLayer->setDesiredSize(QSize(screenSize.width(), 88));
    dockLayer->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityNone);
    dockLayer->setExclusiveZone(88); // Fixes dock overlap issues
    dockLayer->setScope(QStringLiteral("cutie-dock-external-%1").arg(screen->name()));

    dockView->setSource(QUrl("qrc:/ExternalDock.qml"));
    dockView->setColor(QColor(Qt::transparent));
    dockView->resize(screenSize.width(), 88);

    auto *dockRoot = qobject_cast<QQuickItem *>(dockView->rootObject());
    if (dockRoot)
        dockRoot->setSize(QSizeF(screenSize.width(), 88));
    dockView->show();

    m_externalViews.insert(screen, QList<QQuickView *>{ desktopView, dockView });
}

void AdditionalScreen::remove(QScreen *screen)
{
    const QList<QQuickView *> windows = m_externalViews.take(screen);
    for (auto it = windows.crbegin(); it != windows.crend(); ++it) {
        (*it)->hide();
        delete *it;
    }
}