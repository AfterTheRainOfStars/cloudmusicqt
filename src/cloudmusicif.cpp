#include "cloudmusicif.h"
#include <QDBusConnection>

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
    if(m_view!=NULL)
        m_view->activateWindow();
}
