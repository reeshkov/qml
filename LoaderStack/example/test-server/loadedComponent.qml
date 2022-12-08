import QtQuick 2.5
import QtQuick.Window 2.2

Rectangle {
    id: example
    anchors.fill: parent
    color: "gray"
    objectName: "loadedComponent.qml"
    property int count: 0
    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log("loadedComponent.qml onClicked objectName="+example.objectName);
            if(example.parent.hasOwnProperty('input')) input({"data":"from "+example.objectName, "count":example.count++});
        }
    }
    Component.onCompleted: {
        console.log("loadedComponent.qml onCompleted objectName="+example.objectName);
    }
    Component.onDestruction: {
        console.log("loadedComponent.qml onDestruction objectName="+example.objectName);
    }
}
