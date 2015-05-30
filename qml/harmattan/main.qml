import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
//import QtMobility.systeminfo 1.2
import com.yeatse.cloudmusic 1.0

import "../js/api.js" as Api
import "../js/util.js" as Util
import "../js/inheritProperties.js" as Hehe

PageStackWindow {
    id: app

    focus: true
    //showStatusBar: false

    property Item privateStyle: Item{
        property int statusBarHeight: app.inPortrait?72:56
        property int tabBarHeightPortrait: screen.isPortrait?72:56
        property int toolBarHeightPortrait: screen.isPortrait?72:56
        property int scrollBarThickness: 20

        function toolBarIconPath(iconId){
            var prefix = "icon-m-"
            // check if id starts with prefix and use it as is
            // otherwise append prefix and use the inverted version if required
            if (iconId.indexOf(prefix) !== 0)
                iconId =  prefix.concat(iconId).concat(theme.inverted ? "-white" : "");
            return "image://theme/" + iconId;
        }
    }

    property Item myscreen: Item{
        width: 480
        height: 854
    }

    initialPage: MainPage {}

    platformStyle: PageStackWindowStyle{
        property int graphicSizeSmall: 60
        property int graphicSizeLarge: 100
        property int fontSizeSmall: 20
        property int fontSizeLarge: 26
        property int fontSizeMedium: 24
        property color colorNormalLight: "white"
        property color colorNormalMid: "#888"
        property color colorDisabledMid: "#888"
        property int paddingSmall: 10
        property int paddingMedium: 20
        property int paddingLarge: 30
        property string fontFamilyRegular: ""
    }

    Binding{
        target: theme
        property: "inverted"
        value: true
    }

    Binding{//设置背景透明度
        target: app.children[1].children[0].children[1]
        property: "opacity"
        value: 0.5
    }

    Binding{
        target: pageStack.toolBar.children[4]
        property: "source"
        value: ""
    }

    Binding{
        target: pageStack.toolBar.children[4]
        property: "height"
        value: screen.isPortrait?72:56
    }

    QtObject {
        id: internal

        function initialize() {
            Api.qmlApi = qmlApi
            resetBackground()
            user.initialize()
            checkForUpdate()
        }

        function resetBackground() {
            for (var i = 0; i < app.children.length; i++) {
                var child = app.children[i]
                if (/*child != volumeIndicator && */child.hasOwnProperty("color")) {
                    child.z = -2
                    break
                }
            }
        }

        function checkForUpdate() {
            var xhr = new XMLHttpRequest
            xhr.onreadystatechange = function() {
                        if (xhr.readyState == XMLHttpRequest.DONE) {
                            if (xhr.status == 200) {
                                var resp = JSON.parse(xhr.responseText)
                                if (Util.verNameToVerCode(appVersion) < Util.verNameToVerCode(resp.ver)) {
                                    var diag = updateDialogComp.createObject(app)
                                    diag.message = "当前版本: %1\n最新版本: %2\n%3".arg(appVersion).arg(resp.ver).arg(resp.desc)
                                    diag.downUrl = resp.url
                                    diag.open()
                                }
                            }
                        }
                    }
            xhr.open("GET", "http://yeatse.com/cloudmusicqt/meego.ver")
            xhr.send(null)
        }

        property Component updateDialogComp: Component {
            QueryDialog {
                id: dialog
                property bool closing: false
                property string downUrl
                titleText: "目测新版本粗现"
                acceptButtonText: "下载"
                rejectButtonText: "取消"
                onAccepted: Qt.openUrlExternally(downUrl)
                onStatusChanged: {
                    if (status == DialogStatus.Closing)
                        closing = true
                    else if (status == DialogStatus.Closed && closing)
                        dialog.destroy()
                }
                Component.onDestruction: app.forceActiveFocus()
            }
        }
    }

    Connections {
        target: qmlApi
        onProcessCommand: {
            console.log("qml api: process command", commandId)
            if (commandId == 1) {
                player.bringToFront()
            }
            else if (commandId == 2) {
                if (pageStack.currentPage == null
                        || pageStack.currentPage.objectName != player.callerTypeDownload)
                    pageStack.push(Qt.resolvedUrl("DownloadPage.qml"))
            }
        }
    }

    Connections {
        target: downloader
        onDownloadCompleted: {
            var msg = success ? "下载完成:" : "下载失败:"
            msg += musicName
            qmlApi.showNotification("网易云音乐", msg, 2)
        }
    }

    CloudMusicUser {
        id: user
    }

    /*DeviceInfo {
        id: deviceInfo
    }*/

    CountDownTimer {
        id: cdTimer
        onTriggered: Qt.quit()
    }

    /*VolumeIndicator {
        id: volumeIndicator
        volume: Math.min(deviceInfo.voiceRingtoneVolume, 30)
    }*/

    PlayerPage {
        id: player
    }

    BlurredItem {
        id: background
        z: -1
        anchors.fill: parent
        source: backgroundImage.status == Image.Ready ? backgroundImage : null
        onHeightChanged: refresh()

        Image {
            id: backgroundImage
            anchors.fill: parent
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            source: player.coverImageUrl
            visible: false
        }
    }

    InfoBanner {
        id: infoBanner

        z: 999999

        function showMessage(msg) {
            infoBanner.text = msg
            infoBanner.show()
        }

        function showDevelopingMsg() {
            showMessage("此功能正在建设中...> <")
        }
    }

    Keys.onUpPressed: volumeIndicator.volumeUp()
    Keys.onDownPressed: volumeIndicator.volumeDown()

    Component.onCompleted: {
        internal.initialize()
        //Hehe.inheritProperties(app.children[1].children[1].children[0])
    }
}
