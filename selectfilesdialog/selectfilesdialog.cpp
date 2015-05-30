#include "selectfilesdialog.h"
#include <QDebug>
#include <QApplication>
#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QDeclarativeView>
#include <QtDeclarative>
#include <QFile>
#include <QGraphicsObject>
#ifdef Q_OS_SYMBIAN
//#include <QSystemStorageInfo>
//#include <QMessageBox>
#endif

SelectFilesDialog::SelectFilesDialog() :
    QObject(0)
{
    qmlRegisterUncreatableType<SelectFilesDialog>("com.star.utility", 1, 0, "FilesDialog", "Get back to work, slacker!");

    m_chooseType = FileType;
    m_chooseMode = MultipleChoice;
    m_inverseTheme = false;
    isShow = false;
    m_showImageContent = false;
    eventLoop = NULL;
    qmlView = NULL;


    QFile file(":/selectfilesdialog/icon/configure.bat");
    if(file.open(QIODevice::ReadOnly)){
        QString temp_str = file.readLine();
        int temp_pos = temp_str.lastIndexOf(QRegExp("\\S"));
        if(temp_pos>=0)
            temp_str = temp_str.left(temp_pos+1);
        while(temp_str!=""){
            IconInfo info;
            QStringList temp_list = temp_str.split(":");
            info.filePath = temp_list[0];
            info.suffixList = temp_list.at(1).split(" ");
            iconInfoList<<info;

            temp_str = file.readLine();
            temp_pos = temp_str.lastIndexOf(QRegExp("\\S"));
            if(temp_pos>=0)
                temp_str = temp_str.left(temp_pos+1);
        }
    }else{
        qDebug()<<QString::fromUtf8("SelectFilesDialog:configure.bat打开失败")<<file.errorString();
    }
}

SelectFilesDialog::~SelectFilesDialog()
{
}

int SelectFilesDialog::selectionCount() const
{
    return files.length();
}

SelectFilesDialog::ChooseType SelectFilesDialog::chooseType() const
{
    return m_chooseType;
}

SelectFilesDialog::ChooseMode SelectFilesDialog::chooseMode() const
{
    return m_chooseMode;
}

bool SelectFilesDialog::inverseTheme() const
{
    return m_inverseTheme;
}

QString SelectFilesDialog::currentPath() const
{
    return dir.absolutePath();
}

bool SelectFilesDialog::showImageContent() const
{
    return m_showImageContent;
}

QString SelectFilesDialog::nameFilters() const
{
    return m_nameFilters;
}

int SelectFilesDialog::exec(const QString initPath, Filters filters, SortFlags sortflags)
{
    if(!eventLoop.isNull()){
        this->qmlView->showFullScreen();
        return -1;
    }

    files.clear();

    QEventLoop loop;
    eventLoop = &loop;
    connect(this, SIGNAL(closeLoop()), &loop, SLOT(quit()));

    if(initPath=="")
        dir.setPath(QDir::currentPath());
    else
        dir.setPath(QDir(initPath).absolutePath());

    dir.setFilter((QDir::Filters)((int)filters));
    dir.setSorting((QDir::SortFlags)((int)sortflags));

    QDeclarativeView qmlView;
    this->qmlView = &qmlView;
    qmlView.engine()->rootContext()->setContextProperty("fileDialog", this);
#ifdef HARMATTAN_BOOSTER
    qmlView.setSource(QUrl("qrc:/selectfilesdialog/meego.qml"));
#else
    qmlView.setSource(QUrl("qrc:/selectfilesdialog/symbian.qml"));
#endif
    qmlView.showFullScreen();

    int result = eventLoop->exec(QEventLoop::DialogExec);
    eventLoop = NULL;
    this->qmlView = NULL;

    return result;
}

QVariant SelectFilesDialog::firstSelection() const
{
    if(files.length()>0)
        return files.first();
    return QVariant();
}

QVariant SelectFilesDialog::lastSelection() const
{
    if(files.length()>0)
        return files.last();
    return QVariant();
}

QVariant SelectFilesDialog::at(int index) const
{
    if(index<0||index>=files.length())
        return QVariant();
    return files[index];
}

QVariantList SelectFilesDialog::allSelection() const
{
    return files;
}

QVariantList SelectFilesDialog::getCurrentFilesInfo() const
{
    QVariantList result_list;

    foreach(QFileInfo file_info, dir.entryInfoList()){
        if(file_info.fileName()=="."||file_info.fileName()=="..")
            continue;

        if(file_info.isFile()&&(!containsNameFilters(file_info.fileName()))){
            continue;
        }

        QVariantMap temp_map;
        temp_map["name"] = file_info.fileName();
        temp_map["path"] = file_info.absolutePath();
        temp_map["filePath"] = file_info.absoluteFilePath();
        temp_map["size"] = sizeConvert(file_info.size());
        temp_map["suffix"] = file_info.suffix();
        temp_map["lastModified"] = file_info.lastModified().toString();

        if(file_info.isFile()){
            if(file_info.isSymLink()){
                //qDebug()<<QString::fromUtf8("是连接文件");
                temp_map["type"] = SymLinkFileType;
                temp_map["target"] = file_info.symLinkTarget();
            }else{
                temp_map["type"] = FileType;
            }
        }else if(file_info.isDir()){
            if(file_info.isSymLink()){
                //qDebug()<<QString::fromUtf8("是连接文件夹");
                temp_map["type"] = SymLinkFolderType;
                temp_map["target"] = file_info.symLinkTarget();
            }else{
                temp_map["type"] = FolderType;
            }
        }
        result_list<<temp_map;
    }

    return result_list;
}

bool SelectFilesDialog::cdPath(const QString &newPath)
{
    bool ok = dir.cd(newPath);
    if(ok)
        emit currentPathChanged();
    return ok;
}

void SelectFilesDialog::addSelection(QVariant fileInfo)
{
    if(m_chooseMode == IndividualChoice){//如果是单选模式
        int temp_count = files.length();
        files.clear();
        files.append(fileInfo);
        if(temp_count!=1)
            emit selectionCountChanged();
    }else{
        files.append(fileInfo);
        emit selectionCountChanged();
    }
}

bool SelectFilesDialog::removeSelection(QVariant fileInfo)
{
    for(int i=0; i<files.count(); ++i){
        if(fileInfo == files[i]){
            emit selectionCountChanged();
            return true;
        }
    }
    return false;
}

void SelectFilesDialog::clearSelection()
{
    int temp_count = files.length();
    files.clear();
    if(temp_count!=0)
        emit selectionCountChanged();
}

void SelectFilesDialog::setChooseType(ChooseType arg)
{
    if (m_chooseType != arg) {
        m_chooseType = arg;
        emit chooseTypeChanged(arg);
    }
}

void SelectFilesDialog::setChooseMode(ChooseMode arg)
{
    if (m_chooseMode != arg) {
        m_chooseMode = arg;
        emit chooseModeChanged(arg);
    }
}

QString SelectFilesDialog::getIconPathByFilePath(const QString &filePath) const
{
#ifdef HARMATTAN_BOOSTER
    QString append_str = m_inverseTheme?"-inverse.png":".png";
#else
    QString append_str = m_inverseTheme?".png":"-inverse.png";
#endif
    if(filePath=="")
        return "qrc:/selectfilesdialog/icon/unknow"+append_str;

    QFileInfo file_info(filePath);
    if(file_info.isDir()){
        if(file_info.isRoot()){
#ifdef Q_OS_SYMBIAN
            //foreach (QString drive_str, QtMobility::QSystemStorageInfo::logicalDrives()) {
                //emit addDrive(drive_str);
            //}//测试用的代码
#endif
            QChar ch = filePath[0].toLower();
            QString temp_str = "cdefgz";
            if(temp_str.indexOf(ch)>=0)
                return "qrc:/selectfilesdialog/icon/drive_"+QString(ch)+append_str;
            else
                return "qrc:/selectfilesdialog/icon/drive_f"+append_str;
        }

        if(dirIsEmpty(file_info)){//如果是空文件夹
            return "qrc:/selectfilesdialog/icon/folder_null"+append_str;
        }else{
            return "qrc:/selectfilesdialog/icon/folder_files"+append_str;
        }
    }else if(file_info.isFile()){
        QString suffix = file_info.suffix();
        if(suffix=="")
            return "qrc:/selectfilesdialog/icon/unknow"+append_str;

        if(m_showImageContent){
            QString image_suffix = "jpg jpeg bmp gif png ico tif mbm mif svg svgb svgz nvg";
            if(image_suffix.indexOf(suffix)>=0)
                return "file:///"+filePath;
        }

        foreach(IconInfo info, iconInfoList){
            foreach(QString str, info.suffixList){
                if(str == suffix){
                    return "qrc:/selectfilesdialog/icon/"+info.filePath+append_str;
                }
            }
        }
    }

    return "qrc:/selectfilesdialog/icon/unknow"+append_str;
}

void SelectFilesDialog::setInverseTheme(bool arg)
{
    if (m_inverseTheme != arg) {
        m_inverseTheme = arg;
        emit inverseThemeChanged(arg);
    }
}

void SelectFilesDialog::refresh() const
{
    dir.refresh();
}

bool SelectFilesDialog::isRootPath() const
{
    return dir.isRoot();
}

QVariantList SelectFilesDialog::getDrivesInfoList() const
{
    QVariantList result_list;

    foreach(QFileInfo file_info, dir.drives()){
        QVariantMap temp_map;
        temp_map["name"] = file_info.filePath();
        temp_map["path"] = file_info.absolutePath();
        temp_map["filePath"] = file_info.absoluteFilePath();
        temp_map["size"] = sizeConvert(file_info.size());
        temp_map["lastModified"] = file_info.lastModified().toString();
        temp_map["type"] = DriveType;
        result_list<<temp_map;
    }

    return result_list;
}

void SelectFilesDialog::setShowImageContent(bool arg)
{
    if (m_showImageContent != arg) {
        m_showImageContent = arg;
        emit showImageContentChanged(arg);
    }
}

bool SelectFilesDialog::dirIsEmpty(const QFileInfo &fileInfo) const
{
    QDir dir = fileInfo.dir();
    dir.cd(fileInfo.fileName());
    return dir.entryList().length()<=2;
}

QString SelectFilesDialog::sizeConvert(const qint64 &size) const
{
    if(size<1048576){
        return QString::number(((int)(size/10.24))/100.0).append("KB");
    }else if(size<1073741824){
        return QString::number(((int)(size/10485.76))/100.0).append("MB");
    }else if(size<1099511627776){
        return QString::number(((int)(size/10737418.24))/100.0).append("GB");
    }else{
        return ">=1TB";
    }
}

bool SelectFilesDialog::containsNameFilters(const QString &fileName) const
{
    if(m_nameFilters=="")
        return true;

    QStringList name_filters = m_nameFilters.split(";");

    foreach (QString temp_str, name_filters) {
        QRegExp reg(temp_str);
        if(reg.exactMatch(fileName)){
            return true;
        }
    }

    return false;
}

void SelectFilesDialog::close()
{
    emit closeLoop();
}

void SelectFilesDialog::setNameFilters(QString arg)
{
    if (m_nameFilters != arg) {
        m_nameFilters = arg;
        emit nameFiltersChanged(arg);
    }
}
