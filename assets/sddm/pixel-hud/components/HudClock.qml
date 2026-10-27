import QtQuick 2.8
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import org.kde.plasma.plasma5support 2.0 as PlasmaCore

ColumnLayout {
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    readonly property var now: timeSource.data["Local"]["DateTime"]

    Label {
        text: {
            var d = parent.now
            if (!d) return ""
            var h = ("0" + d.getHours()).slice(-2)
            var m = ("0" + d.getMinutes()).slice(-2)
            return h + ":" + m
        }
        color: "#5cc8d7"
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? "#0e1418" : "transparent"
        font.pointSize: 34
        font.family: config.font
        Layout.alignment: Qt.AlignHCenter
    }
    Label {
        text: {
            var d = parent.now
            if (!d) return ""
            var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
            var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
            return days[d.getDay()] + " " + ("0" + d.getDate()).slice(-2) + " " + months[d.getMonth()]
        }
        color: "#b48ead"
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? "#0e1418" : "transparent"
        font.pointSize: 17
        font.family: config.font
        Layout.alignment: Qt.AlignHCenter
    }
    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }
}
