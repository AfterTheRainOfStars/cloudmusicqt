#ifndef CLOUDMUSICIF_H
#define CLOUDMUSICIF_H

#include <QDBusAbstractAdaptor>
#include <QApplication>
#include <QDeclarativeView>

class Cloudmusicif : public QDBusAbstractAdaptor
{
    Q_OBJECT

    Q_CLASSINFO("D-Bus Interface", "com.cloudmusicqt")
public:
    explicit Cloudmusicif(QApplication *app, QDeclarativeView *view);
    
public slots:
    void activateWindow();

private:
    QDeclarativeView *m_view;
};

#endif // CLOUDMUSICIF_H
