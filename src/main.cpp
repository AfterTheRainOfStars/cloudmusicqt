#include <QtGui/QApplication>
#include <QtDeclarative>
#include <QWebSettings>
#include <QDebug>

#include "qmlapplicationviewer.h"
#include "networkaccessmanagerfactory.h"
#include "qmlapi.h"
#include "musicfetcher.h"
#include "musiccollector.h"
#include "blurreditem.h"
#include "musicdownloader.h"
#include "musicdownloadmodel.h"
#include "musicdownloaddatabase.h"
#include "selectfilesdialog.h"

//#define PROXY_HOST "127.0.0.1"

#ifdef PROXY_HOST
#include <QNetworkProxy>
#endif

#define RegisterPlugin(Plugin) \
    qmlRegisterType<Plugin>("com.yeatse.cloudmusic", 1, 0, #Plugin)

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#ifdef Q_OS_SYMBIAN
    QApplication::setAttribute((Qt::ApplicationAttribute)11);   //Qt::AA_CaptureMultimediaKeys
#endif
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    app->setApplicationName("CloudMusic");
    app->setOrganizationName("Yeatse");
    app->setApplicationVersion(VER);

#ifdef PROXY_HOST
    QNetworkProxy::setApplicationProxy(QNetworkProxy(QNetworkProxy::HttpProxy, PROXY_HOST, 8888));
#endif

    RegisterPlugin(MusicInfo);
    RegisterPlugin(MusicFetcher);
    RegisterPlugin(BlurredItem);
    RegisterPlugin(MusicDownloadModel);

    QWebSettings::globalSettings()->setUserStyleSheetUrl(QUrl::fromLocalFile("qml/js/default_theme.css"));

    QScopedPointer<QmlApplicationViewer> viewer(new QmlApplicationViewer);
    viewer->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer->setAttribute(Qt::WA_NoSystemBackground);
    viewer->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer->viewport()->setAttribute(Qt::WA_NoSystemBackground);
    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);

    QScopedPointer<NetworkAccessManagerFactory> factory(new NetworkAccessManagerFactory);
    viewer->engine()->setNetworkAccessManagerFactory(factory.data());

    viewer->rootContext()->setContextProperty("qmlApi", new QmlApi(viewer.data()));
    viewer->rootContext()->setContextProperty("collector", new MusicCollector(viewer.data()));
    viewer->rootContext()->setContextProperty("appVersion", app->applicationVersion());
    viewer->rootContext()->setContextProperty("fileDialog", new SelectFilesDialog());

    MusicDownloader* downloader = MusicDownloader::Instance();
    viewer->rootContext()->setContextProperty("downloader", downloader);
    downloader->pause();
    QObject::connect(qApp, SIGNAL(aboutToQuit()), downloader, SLOT(pause()));
    QObject::connect(qApp, SIGNAL(aboutToQuit()), MusicDownloadDatabase::Instance(), SLOT(freeResource()));

#if defined(HARMATTAN_BOOSTER)
    viewer->setMainQmlFile(QLatin1String("qml/harmattan/main.qml"));
#elif defined(Q_OS_SYSBIAN)//||defined(Q_WS_SIMULATOR)
    viewer->setMainQmlFile(QLatin1String("qml/cloudmusicqt/main.qml"));
#elif defined(Q_WS_SIMULATOR)
    viewer->setMainQmlFile(QLatin1String("qml/harmattan/main.qml"));
#endif
    viewer->showExpanded();

    return app->exec();
}
