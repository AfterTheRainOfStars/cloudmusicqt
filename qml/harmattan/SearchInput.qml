import QtQuick 1.1
import com.nokia.meego 1.1

TextField {
    id: root

    property bool busy: false

    signal typeStopped
    signal cleared

    onTextChanged: {
        inputTimer.restart()
    }

    platformStyle: TextFieldStyle{
        paddingLeft: searchIcon.width
        paddingRight: clearButton.width
    }

    Timer {
        id: inputTimer
        interval: 500
        onTriggered: root.typeStopped()
    }

    ToolIcon {
        id: searchIcon
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        iconId: "toolbar-search"
    }


    ToolIcon {
        id: clearButton
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        iconId: "toolbar-close"
        opacity: root.activeFocus ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }

        onClicked: {
            root.text = ""
            root.parent.forceActiveFocus()
            root.cleared()
        }
    }
}
