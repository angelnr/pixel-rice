import QtQuick 2.2
import QtQuick.Controls

TextField {
    placeholderTextColor: config.color
    palette.text: config.color
    font.pointSize: config.fontSize
    font.family: config.font
    width: parent.width
    height: 42
    background: Rectangle {
        color: "#142126"
        opacity: 1.0
        radius: 0
        border.width: 2
        border.color: parent.focus ? config.selected_color : "#223138"
        anchors.fill: parent
    }
}
