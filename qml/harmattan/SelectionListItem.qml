// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.1

Item{
    height: button.height+app.platformStyle.paddingMedium*2

    property string title: ""
    property string subTitle: ""
    signal clicked

    ToolButton{
        id: button

        width: parent.width-app.platformStyle.paddingMedium*2
        height: platformStyle.buttonHeight*2
        anchors.centerIn: parent

        ListItemText {
            mode: "normal"
            role: "SelectionTitle"
            text: title

            width: parent.width

            anchors{
                left: parent.left
                top: parent.top
                right: parent.right
                margins: app.platformStyle.paddingSmall
            }
        }

        ListItemText {
            mode: "normal"
            role: "SelectionSubTitle"
            text: subTitle

            anchors{
                left: parent.left
                bottom: parent.bottom
                right: parent.right
                margins: app.platformStyle.paddingSmall
            }
        }

        Image {
            id: indicator
            source: "./gfx/indicator"+platformStyle.__invertedString+".svg"
            anchors {
                right: parent.right
                rightMargin: app.platformStyle.paddingSmall
                verticalCenter: parent.verticalCenter
            }
        }

        onClicked: {
            parent.clicked()
        }
    }
}
