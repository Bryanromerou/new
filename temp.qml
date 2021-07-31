import QtQuick 2.4
import QtQuick.Controls 1.3

ApplicationWindow {
    title: qsTr("Test Crop")
    width: 640
    height: 480
    visible: true
    property var selection: undefined

    Image {
        id: image1
        anchors.fill: parent
        source: "img/img/flowers.jpeg"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(!selection)
                    selection = selectionComponent.createObject(parent, {"x": parent.width / 4, "y": parent.height / 4, "width": parent.width / 2, "height": parent.width / 2})
            }
        }
    }

    Component {
        id: selectionComponent

        Rectangle {
            id: selComp
            border {
                width: 2
                color: "steelblue"
            }
            color: "#354682B4"

            property int rulersSize: 18

            MouseArea {     // drag mouse area
                anchors.fill: parent
                drag{
                    target: parent
                    minimumX: 0
                    minimumY: 0
                    maximumX: parent.parent.width - parent.width
                    maximumY: parent.parent.height - parent.height
                    smoothed: true
                }

                onDoubleClicked: {
                    parent.destroy()        // destroy component
                }
            }

            Rectangle {
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                color: "steelblue"
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.XAxis }
                    onMouseXChanged: {
                        if(drag.active){
                            selComp.width = selComp.width - mouseX
                            selComp.x = selComp.x + mouseX
                            if(selComp.width < 30)
                                selComp.width = 30
                        }
                    }
                }
            }

            Rectangle {
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                color: "steelblue"
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.XAxis }
                    onMouseXChanged: {
                        if(drag.active){
                            selComp.width = selComp.width + mouseX
                            if(selComp.width < 50)
                                selComp.width = 50
                        }
                    }
                }
            }

            Rectangle {
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                x: parent.x / 2
                y: 0
                color: "steelblue"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.top

                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.YAxis }
                    onMouseYChanged: {
                        if(drag.active){
                            selComp.height = selComp.height - mouseY
                            selComp.y = selComp.y + mouseY
                            if(selComp.height < 50)
                                selComp.height = 50
                        }
                    }
                }
            }


            Rectangle {
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                x: parent.x / 2
                y: parent.y
                color: "steelblue"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.bottom

                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.YAxis }
                    onMouseYChanged: {
                        if(drag.active){
                            selComp.height = selComp.height + mouseY
                            if(selComp.height < 50)
                                selComp.height = 50
                        }
                    }
                }
            }
        }
    }
}
