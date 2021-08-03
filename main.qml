import QtQuick 2.4
import QtQuick.Controls 1.3

ApplicationWindow {
    id:root
    title: qsTr("Test Crop")
    width: 375
    height: 832
    property bool cropMode: false
    property int rotationAmount: 0
    visible: true
    property var selection: undefined
    property bool selectedBefore: false
    property real memX: 0 // holds the last x of selection
    property real memY: 0 // holds the last x of selection
    property real memHeight: 50 // holds the last width of selection
    property real memWidth: 50 // holds the last height of selection

    // Calling this function shall rotate "mainImage" based on the root's rotationsAmount which is being change on click of rotateButton
    function rotateImage(direction) {
        if (direction === "right") {
            image1.transform = rot
        }
    }

    function resizeImage (){
        console.log("resizing the image")
        clippingMask.x = (root.width) * .025
//        image1.paintedWidth = root.width
//        image1.fillMode = Image.PreserveAspectCrop
//        clippingMask.scale = root.height/clippingMask.height
    }
    Rotation{id : rot; origin.x : image1.width/2 ;origin.y : image1.height/2 ; angle : rotationAmount}

    Item{
        id:clippingMask
        x: (parent.width) * .025
        y: parent.height/2 - image1.height
        Image {
            id: image1
            fillMode: Image.PreserveAspectFit
//            autoTransform:true
            sourceSize.width: (root.width) * .95

            source: "/img/img/flowers.jpeg"
        }

    }

    Button1{
        id: cropButton
        text: cropMode ? "Done": "Crop Image"
        onClicked: {
            root.cropMode = !root.cropMode
            if(!selection){
                if(selectedBefore)
                    selection = selectionComponent.createObject(image1, {"x": memX - 10, "y": memY - image1.height+50, "width": memWidth, "height": memHeight})
                else
                    selection = selectionComponent.createObject(image1, {"x": image1.width / 4, "y": image1.height / 4, "width": image1.width / 4, "height": image1.width / 4})
            }
            else{
                clippingMask.clip = true
                selectedBefore = true
                memX = clippingMask.x
                memY = clippingMask.y
                memHeight = clippingMask.height
                memWidth = clippingMask.width
                root.selectedBefore = true
                selection.destroy()
            }
            if(root.cropMode){
                clippingMask.clip = false
            }else{
                resizeImage()
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

    Button1{
        id: resetButton
        visible: cropMode
        // visible: false -- Should only be visible if image is on screen
        text: "RESET"
        textColor:"red"
        onClicked: {
            console.log("Reseting Image to original state")
            rotationAmount = 0
            root.rotateImage("right")
        }
        x: root.width/2 - width/2
    }

    Button1{
        id:flip
        visible: cropMode
        x:root.width-width
        text:"Flip"
        onClicked: {
            image1.mirror = !image1.mirror
        }
    }

    Button1{
        id:cancelButton
        visible: cropMode
        text:"Cancel"
        onClicked:{
            root.cropMode = !root.cropMode
            selection.destroy()
        }
        anchors.right: cropButton.left
        anchors.top: cropButton.top
        anchors.rightMargin: 10
    }


    Component {
        id: selectionComponent

        Rectangle {
            id: selComp
            property bool rulers: false
            Component.onCompleted:displayRulers()
            Timer {id: timer}
            function delay(delayTime, cb) {
                timer.interval = delayTime;
                timer.repeat = false;
                timer.triggered.connect(cb);
                timer.start();
            }

            function displayRulers(){
                rulers = true
                delay(3000,()=>{
                      rulers = false
                })
            }

            function resizeWindow (){
                console.log("resizing the window on release")
            }

            border {
                width: 5
                color: "steelblue"
            }
            color: "#354682B4"

            property int rulersSize: 18

            Rectangle{
                visible: rulers
                y:parent.height/3
                width: parent.width
                height: 1
                color: "steelblue"
            }

            Rectangle{
                visible: rulers
                y:parent.height*2/3
                width: parent.width
                height: 1
                color: "steelblue"
            }

            Rectangle{
                visible: rulers
                x:parent.width/3
                height: parent.height
                width: 1
                color: "steelblue"
            }

            Rectangle{
                visible: rulers
                x:parent.width*2/3
                height: parent.height
                width: 1
                color: "steelblue"
            }


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
                onReleased: {
                    displayRulers()
                }
            }


            onXChanged: {
                console.log("moving square in the x direction -> " + x)
                clippingMask.x = (parent.width) * .025 + x
                image1.x = -x
                displayRulers()
            }
            onYChanged: {
                console.log("moving square in the y direction -> "+ y)
                clippingMask.y = root.height/2 - image1.height + y
                image1.y = -y
                displayRulers()
            }
            onWidthChanged: {
                console.log("width changing -> "+width)
                clippingMask.width = width
                displayRulers()
            }
            onHeightChanged: {
                console.log("height changing -> "+height)
                clippingMask.height = height
                displayRulers()
            }

            Rectangle {
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                color: "steelblue"
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Rectangle{
                    id:rightBar
                    x:rulersSize/2
                    y: -selComp.height/2 + rulersSize/2
                    height: selComp.height
                    width: selComp.border.width
                    color:selComp.border.color
                }

                MouseArea {
                    anchors.fill: rightBar
                    drag{ target: parent; axis: Drag.XAxis }
                    onMouseXChanged: {
                        if(drag.active){
                            console.log(selComp.x+selComp.width)
                            selComp.width = selComp.width - mouseX
                            selComp.x = selComp.x + mouseX
                            if(selComp.width < 30)
                                selComp.width = 30
//                            else if(selComp.width+selComp.x >root.width*95)
//                                selComp.width = root.width*95
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

                Rectangle{
                    id:leftBar
                    x: rulersSize/2 - width
                    y: -selComp.height/2 + rulersSize/2
                    height: selComp.height
                    width: selComp.border.width
                    color: selComp.border.color
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
                color: "steelblue"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.top
                Rectangle{
                    id:topBar
                    x: -width/2 + rulersSize/2
                    y: rulersSize/2
                    width: selComp.width
                    height: selComp.border.width
                    color: selComp.border.color
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
                color: "steelblue"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.bottom

                Rectangle{
                    id:bottomBar
                    x: -width/2 + rulersSize/2
                    y:rulersSize/2 - height
                    width: selComp.width
                    height: selComp.border.width
                    color: selComp.border.color
                }

                MouseArea {
                    anchors.fill: bottomBar
                    drag{ target: parent; axis: Drag.YAxis }
                    onMouseYChanged: {
                        if(drag.active){
                            console.log(selComp.height)
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
