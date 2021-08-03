import QtQuick 2.4
import QtQuick.Controls 1.3

ApplicationWindow {
    id:root
    title: qsTr("Test Crop")
    width: 375
    height: 812
    property bool cropMode: false
    property int rotationAmount: 0
    visible: true
    property var selection: undefined

    // Calling this function shall rotate "mainImage" based on the root's rotationsAmount which is being change on click of rotateButton
    function rotateImage(direction) {
        if (direction === "right") {
            image1.transform = rot
        }
    }
    Rotation{id : rot; origin.x : image1.width/2 ;origin.y : image1.height/2 ; angle : rotationAmount}

    Image {
        id: image1
        fillMode: Image.PreserveAspectFit
        x: (parent.width) * .025
        y: parent.height/2 - height
        sourceSize.width: (parent.width) * .95
        source: "/img/img/flowers.jpeg"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(!selection)
                    selection = selectionComponent.createObject(parent, {"x": parent.width / 4, "y": parent.height / 4, "width": parent.width / 4, "height": parent.width / 4})
            }
        }
    }

    Button1{
        id: cropButton
//        visible: !drawMode
        text: cropMode ? "Done": "Crop Image"
        onClicked: {
            root.cropMode = !root.cropMode
            if(!selection)
                selection = selectionComponent.createObject(image1, {"x": image1.width / 4, "y": image1.height / 4, "width": image1.width / 4, "height": image1.width / 4})
            else{
                selection.destroy()
            }
        }
        x:root.width/2- width/2
        y:root.height - height - 100
    }

    Button1{
        id: rotateButton
        visible: cropMode
        iconUrl: "/img/img/rotate.png"
        // visible: false -- Should only be visible if image is on screen
        x:20
        width: 40
        height: width
        onClicked: {
            rotationAmount = rotationAmount + 90
            root.rotateImage("right")
        }
    }

    Component {
        id: selectionComponent

        Rectangle {
            id: selComp
            border {
                width: 5
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
                color: "red"
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: rightBar
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
                Rectangle{
                    id:rightBar
                    x:rulersSize/2
                    y: -selComp.height/2 + rulersSize/2
                    height: selComp.height
                    width: selComp.border.width
                    color:parent.color
                }
            }

            Rectangle {
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                color: "orange"
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Rectangle{
                    id:leftBar
                    x: rulersSize/2 - width
                    y: -selComp.height/2 + rulersSize/2
                    height: selComp.height
                    width: selComp.border.width
                    color:parent.color
                }

                MouseArea {
                    anchors.fill: leftBar
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
                color: "green"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.top
                Rectangle{
                    id:topBar
                    x: -width/2 + rulersSize/2
                    y: rulersSize/2
                    width: selComp.width
                    height: selComp.border.width
                    color:parent.color
                }
                MouseArea {
                    anchors.fill: topBar
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
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.bottom

                Rectangle{
                    id:bottomBar
                    x: -width/2 + rulersSize/2
                    y:rulersSize/2 - height
                    width: selComp.width
                    height: selComp.border.width
                    color:parent.color
                }

                MouseArea {
                    anchors.fill: bottomBar
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
