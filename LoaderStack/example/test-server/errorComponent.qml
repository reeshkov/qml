import QtQuick 2.5
import QtQuick.Window 2.2

Rectangle {
    id: example
    anchors.fill: parent
    color: "gray"
    objectName: "errorComponent.qml"
    Some syntaxis error!
    Component.onCompleted: {
        console.log("errorComponent.qml onCompleted objectName="+example.objectName);
    }
}
