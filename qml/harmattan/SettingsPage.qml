import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import com.star.utility 1.0

Page {
    id: page

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    orientationLock: PageOrientation.LockPortrait

    function selectFolder(a, defaultDir){
        fileDialog.inverseTheme = theme.inverted
        fileDialog.chooseType = FilesDialog.FolderType
        fileDialog.chooseMode = FilesDialog.IndividualChoice
        fileDialog.exec(defaultDir, FilesDialog.Dirs|FilesDialog.Drives)
        if(fileDialog.selectionCount>0){
            return fileDialog.firstSelection()
        }

        return null
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: contentCol.height

        Column {
            id: contentCol
            width: parent.width
            ViewHeader {
                title: "设置"
            }
            SelectionListItem {
                width: flickable.width
                title: "下载目录"
                subTitle: downloader.targetDir
                onClicked: {
                    var dir = selectFolder("选择文件夹:", downloader.targetDir)
                    if (dir) downloader.targetDir = dir.filePath
                }
            }

            SelectionListItem {
                id: timer_stop_music

                width: flickable.width
                title: "定时关闭"
                subTitle: cdTimer.active ? "程序将在%1分钟后关闭".arg(cdTimer.timeLeft)
                                         : "未启动"
                onClicked: cdDiagComp.createObject(page)
                Component {
                    id: cdDiagComp
                    TimePickerDialog {
                        id: diag
                        property bool isClosing: false
                        titleText: "设定程序关闭的时间"
                        acceptButtonText: "启动"
                        rejectButtonText: "关闭"
                        Component.onCompleted: {
                            cdTimer.active = false
                            hour = Math.floor(cdTimer.timeLeft / 60)
                            minute = cdTimer.timeLeft % 60
                            open()
                        }
                        onAccepted: {
                            var result = hour * 60 + minute
                            if (result > 0) {
                                cdTimer.timeLeft = result
                                cdTimer.active = true
                            }

                            diag.destroy()
                        }

                        onRejected: {
                            diag.destroy()
                        }
                    }
                }
            }
        }
    }
}
