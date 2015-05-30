// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.1
import com.star.utility 1.0

PageStackWindow{
    id:main
    showStatusBar:true

    function updateFileList(){
        mymodel.clear()
        var fileList = fileDialog.getCurrentFilesInfo();
        for(var i in fileList){
            mymodel.append({"fileInfo": fileList[i]})
        }
    }

    initialPage: Page{
        Rectangle{
            id: head_bar
            width: parent.width
            height: 72
            gradient: Gradient{
                GradientStop{
                    position: 1;color: fileDialog.inverseTheme?"black":"lightgray";
                }
                GradientStop{
                    position: 0;color: fileDialog.inverseTheme?"black":"white";
                }
            }
            Text{
                anchors.verticalCenter: parent.verticalCenter
                x:10
                text: fileDialog.currentPath
                font.pixelSize: 22
                width: parent.width-x
                elide: Text.ElideMiddle
                color: fileDialog.inverseTheme?"#ddd":"black"
            }
            Rectangle{
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color: "#333"
                visible: fileDialog.inverseTheme
            }
        }

        tools: ToolBarLayout{
            ToolIcon{
                iconId: "toolbar-up"
                onClicked: {
                    fileDialog.clearSelection()
                    if(fileDialog.cdPath(".."))
                        updateFileList()
                }
            }
            ToolIcon{
                iconId: "toolbar-done"

                enabled: fileDialog.selectionCount>0
                onClicked: {
                    fileDialog.close()
                }
            }
            ToolIcon{
                iconId: "toolbar-cancle"

                onClicked: {
                    fileDialog.clearSelection()
                    fileDialog.close()
                }
            }
            ToolIcon{
                iconId: "toolbar-refresh"
                onClicked: {
                    updateFileList()
                }
            }
        }

        ListView{
            id: list_file
            property int currentSelectionIndex: -1
            //记录当前被选中的条目的索引，当为单选模式时方便其他条目判断自己选择状态是否已经失去

            clip: true
            width: parent.width
            anchors.top: head_bar.bottom
            anchors.bottom: parent.bottom
            model: ListModel{id:mymodel}
            delegate: componentListDelegate

            Component.onCompleted: {
                main.updateFileList()
            }

            function addSelection(fileInfo, index){
                if(fileDialog.chooseMode == FilesDialog.IndividualChoice){
                    fileDialog.clearSelection()
                    currentSelectionIndex = index
                }

                fileDialog.addSelection(fileInfo)
            }

            function removeSelection(fileInfo, index){
                if(fileDialog.chooseMode == FilesDialog.IndividualChoice){
                    currentSelectionIndex = -1
                }else{
                    fileDialog.removeSelection(fileInfo)
                }
            }
        }
    }

    Binding {//设置meego系统控件的主题
        target: theme
        property: "inverted"
        value: fileDialog.inverseTheme
    }

    Component{
        id: componentListDelegate

        Item{
            property bool isSelected: false

            width: parent.width
            height: 80

            function editStatus(){//改变自己的状态，从被选中变为选中，或从选中变为取消选中
                if(rect_background.visible){
                    isSelected = false
                    list_file.removeSelection(fileInfo, index)
                }else{
                    isSelected = true
                    list_file.addSelection(fileInfo, index)
                }
            }

            function openFile(){//打开文件
                switch(fileInfo.type){
                case FilesDialog.FileType:{
                    Qt.openUrlExternally("file://"+fileInfo.filePath)
                    break
                }
                case FilesDialog.FolderType:{
                    fileDialog.cdPath(fileInfo.name)
                    fileDialog.clearSelection()
                    updateFileList()
                    break;
                }
                case FilesDialog.SymLinkFileType:{
                    Qt.openUrlExternally("file://"+fileInfo.target)
                    break
                }
                case FilesDialog.SymLinkFolderType:{
                    fileDialog.cdPath(fileInfo.target)
                    fileDialog.clearSelection()
                    updateFileList()
                    break
                }
                case FilesDialog.DriveType:{
                    fileDialog.cdPath(fileInfo.name)
                    fileDialog.clearSelection()
                    updateFileList()
                    break
                }
                default:break
                }
            }

            Rectangle{
                id: rect_background
                anchors.fill: parent
                visible: isSelected&&(fileDialog.chooseMode == FilesDialog.IndividualChoice?
                                          index == list_file.currentSelectionIndex:true)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#1080DD" }
                    GradientStop { position: 1.0; color: "#6BB2E7" }
                }
            }

            Item{
                id: fileIcon
                x: 10
                width: 64
                height: 64
                anchors.verticalCenter: parent.verticalCenter

                Image{
                    id: fileIcon_image
                    anchors.centerIn: parent
                    sourceSize.width: 64
                    sourceSize.height: 64
                    source: fileDialog.getIconPathByFilePath(fileInfo.filePath)

                    Connections{
                        target: fileDialog
                        onInverseThemeChanged:{
                            fileIcon_image.source = fileDialog.getIconPathByFilePath(fileInfo.filePath)
                        }
                    }
                }
                Image{
                    source: "qrc:/selectfilesdialog/mask"+(fileDialog.inverseTheme?"-inverse.png":"_meego.png")
                    sourceSize.width: fileIcon.width
                    sourceSize.height: fileIcon.height
                    visible: (!rect_background.visible)&&fileDialog.showImageContent
                }
                Image{
                    sourceSize: fileIcon_image.sourceSize
                    source: {
                        var type = fileInfo.type
                        if(type == FilesDialog.SymLinkFolderType||
                                type == FilesDialog.SymLinkFileType){
                            return "qrc:/selectfilesdialog/icon/link"+(fileDialog.inverseTheme?"-inverse.png":".png")
                        }
                        return ""
                    }
                }
            }

            Text {
                id: fileName
                text: fileInfo.name
                font.bold: true
                anchors.left: fileIcon.right
                font.pixelSize: 26
                anchors.leftMargin: 10
                anchors.top: fileIcon.top
                width: parent.width-fileIcon.width-30
                elide: Text.ElideRight
                color: fileDialog.inverseTheme?"#ddd":"black"
            }

            Text {
                id: fileOtherInfo
                text: fileInfo.lastModified+" - "+fileInfo.size
                anchors.bottom: fileIcon.bottom
                anchors.left: fileName.left
                font.pixelSize: 18
                width: parent.width-fileIcon.width-30
                elide: Text.ElideRight
                color: fileDialog.inverseTheme?"#ddd":"black"
            }

            Rectangle{
                width: parent.width
                height: 1
                color: fileDialog.inverseTheme?"#666":"#aaa"
                anchors.bottom: parent.bottom
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    switch(fileDialog.chooseType){
                    case FilesDialog.FolderType:{
                        if(fileInfo.type == FilesDialog.FolderType||
                                fileInfo.type == FilesDialog.DriveType){
                            editStatus()
                        }else{
                            openFile()
                        }
                        break;
                    }

                    case FilesDialog.FileType:{
                        if(fileInfo.type == FilesDialog.FileType){
                            editStatus()
                        }else{
                            openFile()
                        }
                        break;
                    }

                    case FilesDialog.AllType:{
                        editStatus()
                        break;
                    }
                    case FilesDialog.DriveType:{
                        if(fileInfo.type == FilesDialog.DriveType){
                            editStatus()
                        }else{
                            openFile()
                        }
                        break
                    }
                    case FilesDialog.NoType:{
                        openFile()
                        break
                    }

                    default:break
                    }
                }
                onDoubleClicked: {
                    list_file.removeSelection(fileInfo)
                    list_file.removeSelection(fileInfo)
                    //进行两次清楚是防止双击时误选
                    openFile()
                }
            }
        }
    }
}
