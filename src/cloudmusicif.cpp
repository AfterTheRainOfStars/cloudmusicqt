#include "cloudmusicif.h"
#include <QDBusConnection>
#include <QDebug>

Cloudmusicif::Cloudmusicif(QApplication *app, QDeclarativeView *view) :
    QDBusAbstractAdaptor(app),
    m_view(view)
{
    QDBusConnection bus = QDBusConnection::sessionBus();
    bus.registerService("com.cloudmusicif");
    bus.registerObject("/com/cloudmusicif", app);
}

void Cloudmusicif::activateWindow()
{
    qDebug()<<QString::fromUtf8("点击了通知消息");

    if(m_view!=NULL)
        m_view->activateWindow();
}
