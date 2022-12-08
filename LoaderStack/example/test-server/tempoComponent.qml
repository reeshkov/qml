import QtQuick 2.5
import QtQuick.Window 2.2


Text {
    id: example
    anchors.fill: parent
    color: "green"
    objectName: "tempoComponent.qml"
    property int count: 5
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    text: count
    styleColor: "red"
    smooth: true
    font.pointSize : 45
    textFormat: Text.StyledText

    Timer{
        repeat: true
        running: true
        interval: 1000
        onTriggered: {
            if(0 >=count){
                example.destroy();
            }else{
                if(example.parent.hasOwnProperty('input')) input({"data":"from loaded", "count":example.count});
                console.log("tempoComponent.qml timer count ="+example.count--);
            }
        }
    }
    Component.onCompleted: {
        console.log("tempoComponent.qml onCompleted objectName="+example.objectName);
    }
    Component.onDestruction: {
        console.log("tempoComponent.qml onDestruction objectName="+example.objectName);
    }
}
