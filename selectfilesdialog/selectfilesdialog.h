#ifndef SELECTFILESDIALOG_H
#define SELECTFILESDIALOG_H

#include <QObject>
#include <QVariantMap>
#include <QUrl>
#include <QFileInfo>
#include <QDir>
#include <QPointer>
#include <QEventLoop>

class QDeclarativeView;
class SelectFilesDialog : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int selectionCount READ selectionCount NOTIFY selectionCountChanged FINAL)
    //记录用户选择了多少了文件/文件夹
    Q_PROPERTY(ChooseType chooseType READ chooseType WRITE setChooseType NOTIFY chooseTypeChanged)
    //chooseType为控制文件夹可选还是文件可选，值为FileType时只能选择文件
    //FolderType为文件夹，FileType|FolderType为都可以
    Q_PROPERTY(ChooseMode chooseMode READ chooseMode WRITE setChooseMode NOTIFY chooseModeChanged)
    //chooseMode为控制可选多项还是单项,为true时只能选择单个文件或文件夹
    Q_PROPERTY(bool inverseTheme READ inverseTheme WRITE setInverseTheme NOTIFY inverseThemeChanged)
    //inversej记录界面是否反色显示（正常为亮色，反色为暗色）
    Q_PROPERTY(QString currentPath READ currentPath NOTIFY currentPathChanged FINAL)
    //记录当前所在的绝对路径
    Q_PROPERTY(bool showImageContent READ showImageContent WRITE setShowImageContent NOTIFY showImageContentChanged)
    //记录是否在管理器中把图片当做自己个图标显示（可能会导致滑动不流畅）
    Q_PROPERTY(QString nameFilters READ nameFilters WRITE setNameFilters NOTIFY nameFiltersChanged)
    //文件名的过滤器（只对文件名有效）

    Q_ENUMS(ChooseType)
    Q_ENUMS(ChooseMode)
    Q_ENUMS(Filter)
    Q_ENUMS(SortFlag)
    Q_FLAGS(Filters)
    Q_FLAGS(SortFlags)

public:
    SelectFilesDialog();
    ~SelectFilesDialog();

    enum ChooseType{
        NoType,//任何类型都不可选择
        FolderType,//文件夹类型
        SymLinkFolderType,//链接文件夹类型
        FileType,//文件类型
        SymLinkFileType,//链接文件类型
        DriveType,//磁盘驱动器类型
        AllType//所有类型
    };

    enum ChooseMode{
        IndividualChoice,//单项选择
        MultipleChoice//多项选择
    };

    enum Filter{
        Dirs        = 0x001,
        Files       = 0x002,
        Drives      = 0x004,
        NoSymLinks  = 0x008,
        AllEntries  = Dirs | Files | Drives,
        TypeMask    = 0x00f,
#ifdef QT3_SUPPORT
        All         = AllEntries,
#endif

        Readable    = 0x010,
        Writable    = 0x020,
        Executable  = 0x040,
        PermissionMask    = 0x070,
#ifdef QT3_SUPPORT
        RWEMask     = 0x070,
#endif

        Modified    = 0x080,
        Hidden      = 0x100,
        System      = 0x200,

        AccessMask  = 0x3F0,

        AllDirs       = 0x400,
        CaseSensitive = 0x800,
        NoDotAndDotDot = 0x1000, // ### Qt5 NoDotAndDotDot = NoDot|NoDotDot
        NoDot         = 0x2000,
        NoDotDot      = 0x4000,

        NoFilter = -1
#ifdef QT3_SUPPORT
        ,DefaultFilter = NoFilter
#endif
    };
    Q_DECLARE_FLAGS(Filters, Filter)

    enum SortFlag {
        Name        = 0x00,
        Time        = 0x01,
        Size        = 0x02,
        Unsorted    = 0x03,
        SortByMask  = 0x03,

        DirsFirst   = 0x04,
        Reversed    = 0x08,
        IgnoreCase  = 0x10,
        DirsLast    = 0x20,
        LocaleAware = 0x40,
        Type        = 0x80,
        NoSort = -1
#ifdef QT3_SUPPORT
        ,DefaultSort = NoSort
#endif
    };
    Q_DECLARE_FLAGS(SortFlags, SortFlag)

    int selectionCount() const;
    ChooseType chooseType() const;
    ChooseMode chooseMode() const;
    bool inverseTheme() const;
    QString currentPath() const;
    bool showImageContent() const;
    QString nameFilters() const;

public Q_SLOTS:
    int exec(const QString initPath="", Filters filters=NoFilter, SortFlags sortflags=NoSort);

    QVariant firstSelection() const;
    QVariant lastSelection() const;
    QVariant at(int index) const;
    QVariantList allSelection() const;
    QVariantList getCurrentFilesInfo() const;

    bool cdPath(const QString& newPath);

    void addSelection(QVariant fileInfo);
    bool removeSelection(QVariant fileInfo);
    void clearSelection();
    void setChooseType(ChooseType arg);
    void setChooseMode(ChooseMode arg);

    QString getIconPathByFilePath(const QString& filePath) const;
    void setInverseTheme(bool arg);
    //设置主题色
    void refresh () const;
    //刷新当前目录
    bool isRootPath() const;
    //返回当前目录是否是根目录
    QVariantList getDrivesInfoList() const;
    void setShowImageContent(bool arg);
    void close();
    void setNameFilters(QString arg);

Q_SIGNALS:
    void closeLoop();
    void chooseTypeChanged(ChooseType arg);
    void chooseModeChanged(ChooseMode arg);
    void inverseThemeChanged(bool arg);
    void currentPathChanged();
    void selectionCountChanged();
    void showImageContentChanged(bool arg);
    void nameFiltersChanged(QString arg);

private Q_SLOTS:

private:
    QVariantList files;
    QDir dir;
    QDeclarativeView *qmlView;
    QPointer<QEventLoop> eventLoop;

    ChooseType m_chooseType;
    ChooseMode m_chooseMode;

    struct IconInfo{
        QString filePath;
        QStringList suffixList;
    };
    QList<IconInfo> iconInfoList;
    bool m_inverseTheme;//记录主题色的模式（亮色或者暗色）
    bool isShow;//记录文件对话框是否正在显示中
    QString m_currentPath;//记录当前绝对路径
    bool m_showImageContent;//记录是否把图片资源当做自己的图标显示
    QString m_nameFilters;

    bool dirIsEmpty(const QFileInfo& fileInfo) const;
    //判断一个文件夹是否为空的
    QString sizeConvert(const qint64& size) const;
    //将字节转化成更方便查看的单位，例如KB MB GB
    bool containsNameFilters(const QString& fileName) const;
};

#endif // SELECTFILESDIALOG_H
