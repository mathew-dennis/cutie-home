#ifndef ADDITIONALSCREEN_H
#define ADDITIONALSCREEN_H

#include <QObject>
#include <QHash>
#include <QList>
#include <QScreen>
#include <QQuickView>
#include <QGuiApplication>
#include <QQmlEngine>

class AdditionalScreen : public QObject {
    Q_OBJECT
public:
    explicit AdditionalScreen(QGuiApplication *app, QQmlEngine *engine, QScreen *primaryScreen, QObject *parent = nullptr);
    ~AdditionalScreen();

    void add(QScreen *screen);
    void remove(QScreen *screen);

private:
    QGuiApplication *m_app;
    QQmlEngine *m_engine;
    QScreen *m_primaryScreen;
    QHash<QScreen *, QList<QQuickView *>> m_externalViews;
};

#endif // ADDITIONALSCREEN_H