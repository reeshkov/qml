#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

#ifdef USE_QQMLENGINE
    QQuickView view;
    QQmlEngine *qmlEngine = view.engine();
    //qmlEngine->addImportPath(SRCPATH);
    //qDebug() << ": QML path list" << qmlEngine->importPathList();
    view.connect(view.engine(), &QQmlEngine::quit, &app, &QCoreApplication::quit);
    view.connect(&view, &QQuickView::destroyed, &app, &QCoreApplication::quit);
    view.setSource(QUrl(SRCPATH));
    if (view.status() == QQuickView::Error)
        return -1;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.show();
#else
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral(SRCPATH));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                    &app, [url](QObject *obj, const QUrl &objUrl) { if (!obj && url == objUrl) QCoreApplication::exit(-1); },
                    Qt::QueuedConnection);
    engine.load(url);
#endif

    return app.exec();
}
