// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import com.star.utility 1.0

PageStackWindow{
    id:main
    showStatusBar:true
    platformInverted: fileDialog.inverseTheme

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
            height: 54
            gradient: Gradient{
                GradientStop{
                    position: 1;color: fileDialog.inverseTheme?"lightgray":"#313232";
                }
                GradientStop{
                    position: 0;color: fileDialog.inverseTheme?"white":"#595a5a";
                }
            }
            Text{
                anchors.verticalCenter: parent.verticalCenter
                x:10
                text: fileDialog.currentPath
                font.pixelSize: 16
                width: parent.width-x
                elide: Text.ElideMiddle
                color: fileDialog.inverseTheme?"black":"#ddd"
            }
        }

        tools: ToolBarLayout{
            ToolButton{
                iconSource: "toolbar-previous"
                platformInverted: main.platformInverted
                onClicked: {
                    fileDialog.clearSelection()
                    if(fileDialog.cdPath("..")){
                        updateFileList()
                    }else if(fileDialog.isRootPath()){//如果当前已经是根目录
                        mymodel.clear()
                        var fileList = fileDialog.getDrivesInfoList()
                        for(var i in fileList){
                            mymodel.append({"fileInfo": fileList[i]})
                        }
                    }
                }
            }
            ToolButton{
                iconSource: "qrc:/selectfilesdialog/done"+(platformInverted?"-inverted":"")+".svg"
                platformInverted: main.platformInverted
                enabled: fileDialog.selectionCount>0
                onClicked: {
                    fileDialog.close()
                }
            }
            ToolButton{
                iconSource: "qrc:/selectfilesdialog/cancle"+(platformInverted?"-inverted":"")+".svg"
                platformInverted: main.platformInverted
                onClicked: {
                    fileDialog.clearSelection()
                    fileDialog.close()
                }
            }
            ToolButton{
                iconSource: "toolbar-refresh"
                platformInverted: main.platformInverted
                onClicked: {
                    fileDialog.refresh()
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
                    currentSelectionIndex = index
                }

                fileDialog.addSelection(fileInfo)
            }

            function removeSelection(fileInfo, index){
                if(fileDialog.chooseMode == FilesDialog.IndividualChoice){
                    fileDialog.clearSelection()
                    currentSelectionIndex = -1
                }else{
                    fileDialog.removeSelection(fileInfo)
                }
            }
        }
    }

    Component{
        id: componentListDelegate

        Item{
            property bool isSelected: false

            width: parent.width
            height: 60

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
                    Qt.openUrlExternally("file:///"+fileInfo.filePath)
                    break
                }
                case FilesDialog.FolderType:{
                    fileDialog.cdPath(fileInfo.name)
                    fileDialog.clearSelection()
                    updateFileList()
                    break;
                }
                case FilesDialog.SymLinkFileType:{
                    Qt.openUrlExternally("file:///"+fileInfo.target)
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
                width: 50
                height: 50
                anchors.verticalCenter: parent.verticalCenter

                Image{
                    id: fileIcon_image
                    anchors.centerIn: parent
                    sourceSize.width: 50
                    sourceSize.height: 50
                    source: fileDialog.getIconPathByFilePath(fileInfo.filePath)

                    Connections{
                        target: fileDialog
                        onInverseThemeChanged:{
                            fileIcon_image.source = fileDialog.getIconPathByFilePath(fileInfo.filePath)
                        }
                    }
                }
                Image{
                    source: "qrc:/selectfilesdialog/mask"+(fileDialog.inverseTheme?"_symbian.png":"-inverse.png")
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
                            return "qrc:/selectfilesdialog/icon/link"+(fileDialog.inverseTheme?".png":"-inverse.png")
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
                font.pixelSize: 20
                anchors.leftMargin: 10
                anchors.top: fileIcon.top
                width: parent.width-fileIcon.width-30
                elide: Text.ElideRight
                color: fileDialog.inverseTheme?"black":"#ddd"
            }

            Text {
                id: fileOtherInfo
                text: fileInfo.lastModified+" - "+fileInfo.size
                anchors.bottom: fileIcon.bottom
                anchors.left: fileName.left
                font.pixelSize: 12
                width: parent.width-fileIcon.width-30
                elide: Text.ElideRight
                color: fileDialog.inverseTheme?"black":"#ddd"
            }

            Rectangle{
                width: parent.width
                height: 1
                color: fileDialog.inverseTheme?"#aaa":"#666"
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
