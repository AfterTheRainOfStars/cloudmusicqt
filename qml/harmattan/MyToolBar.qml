// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.1

Item{
    width: visible && parent ? parent.width : 0
    height: visible && parent ? parent.height : 0

    Image{
        id:backg

        opacity: command.style.toolBarOpacity
        anchors.fill: parent
        source: command.style.toolBarBackgroundImage
    }

    ToolBarLayout{
        id: layout

        anchors.fill: parent
    }

    onChildrenChanged: {
        children[children.length-1].parent = layout
    }
}
