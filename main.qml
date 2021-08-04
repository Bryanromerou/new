import QtQuick 2.4
import QtQuick.Window 2.12

Window {
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
        selection.rotationAmount = rotationAmount
    }

    function resizeImage (){
        scaleAnimX.to = root.width/clippingMask.width * .95
        scaleAnimY.to = root.width/clippingMask.width * .95
        const temp  = root.height/2 - image1.height
        animY.to = temp - (temp+clippingMask.height-image1.y-image1.height)/2
        scaleAnimX.start()
        scaleAnimY.start()
        animX.start()
        animY.start()
    }

    Item{
        property int animationDuration: 300
        rotation: rotationAmount
        id:clippingMask
        x: (parent.width) * .025
        y: parent.height/2 - image1.height
        Flickable{
            interactive: false
            anchors.fill:parent
            contentHeight: 100
            contentWidth:100
            onFlickStarted: {
                console.log("started flick")
            }
            onFlickingChanged: {
                console.log("flicking")
            }
            Image {
                id: image1
        //            opacity: .2
                fillMode: Image.PreserveAspectFit
                sourceSize.width: (root.width) * .95
                source: "/img/color_squares.jpeg"
//                rotation: rotationAmount
            }
        }
        transform: [
            Scale{
                id: clippingScale
            }
        ]

        // Animations Group
        PropertyAnimation{
            id:scaleAnimX
            target: clippingScale
            properties: "xScale"
            duration: clippingMask.animationDuration
        }
        PropertyAnimation{
            id:scaleAnimY
            target: clippingScale
            properties: "yScale"
            duration: clippingMask.animationDuration
        }
        PropertyAnimation{
            id:animX
            target: clippingMask
            properties: "x"
            to: (root.width) * .025
            duration: clippingMask.animationDuration
        }
        PropertyAnimation{
            id:animY
            target: clippingMask
            properties: "y"
            duration: clippingMask.animationDuration
        }
    }

    // Crop Button
    Button1{
        id: cropButton
        text: cropMode ? "Done": "Crop Image"
        x:root.width/2- width/2
        y:root.height - height - 100

        onClicked: {
            root.cropMode = !root.cropMode
            if(!selection){
                if(selectedBefore)
                    selection = selectionComponent.createObject(image1, {"x": memX - 9.5, "y": memY - image1.height+345, "width": memWidth, "height": memHeight})
                else
                    selection = selectionComponent.createObject(image1, {"x": 0, "y": 0 , "width": image1.width, "height": image1.height})
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
                clippingScale.xScale = 1
                clippingScale.yScale = 1
            }else{
                console.log("resizing image")
                resizeImage()
            }
        }
    }

    // Rotate Button
    Button1{
        id: rotateButton
        visible: cropMode
        iconUrl: "/img/img/rotate.png"
        x:20
        width: 40
        height: width
        onClicked: {
            rotationAmount = rotationAmount + 90
            root.rotateImage("right")
        }
    }

    //Reset Button
    Button1{
        id: resetButton
        visible: cropMode
        text: "RESET"
        textColor:"red"
        onClicked: {
            console.log("Reseting Image to original state")
            rotationAmount = 0
            root.rotateImage("right")
            image1.mirror = false
            selection.x = 0
            selection.y = 0
            selection.width = image1.width
            selection.height = image1.height
        }
        x: root.width/2 - width/2
    }

    //Horizontal Button
    Button1{
        id:flip
        visible: cropMode
        x:root.width-width
        text:"Flip"
        onClicked: {
            image1.mirror = !image1.mirror
        }
    }

    //Cancel Crop Button
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
            property int rotationAmount: 0
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

            border {
                width: 10
                color: "gray"
            }
            color: "#35FFFFFF"

            property int rulersSize: 18

            // Start of guide lines
            Rectangle{
                visible: rulers
                y:parent.height/3
                width: parent.width
                height: 1
                color: parent.border.color
            }

            Rectangle{
                visible: rulers
                y:parent.height*2/3
                width: parent.width
                height: 1
                color: parent.border.color
            }

            Rectangle{
                visible: rulers
                x:parent.width/3
                height: parent.height
                width: 1
                color: parent.border.color
            }

            Rectangle{
                visible: rulers
                x:parent.width*2/3
                height: parent.height
                width: 1
                color: parent.border.color
            }
            // End of guide lines

            // MouseArea of selComp that allows the rectangle dragged all over the image
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
//                    resizeImage()
                    displayRulers()
                }
            }

            function moveX(inverse = false){
                if(inverse){
                    clippingMask.x = (parent.width) * .025 - x
                    image1.x = x
                    displayRulers()
                }else{
                    clippingMask.x = (parent.width) * .025 + x
                    image1.x = -x
                    displayRulers()
                }
            }
            function moveY(){
                clippingMask.y = root.height/2 - image1.height + y
                image1.y = -y
                displayRulers()
            }
            function changeWidth(){
                clippingMask.width = width
                displayRulers()
            }
            function changeHeight(){
                clippingMask.height = height
                displayRulers()
            }

            onXChanged: moveX()
            onYChanged: moveY()
            onWidthChanged: changeWidth()
            onHeightChanged: changeHeight()

            // Left
            Rectangle {
                width: rulersSize
                height: rulersSize
                radius: rulersSize
//                color: "steelblue"
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.top

                // Left Bar Rectangle
                Rectangle{
                    z:-2
                    id:leftBar
                    x: width
                    y: rulersSize/2
                    height: selComp.height
                    width: selComp.border.width
                    color:selComp.border.color
                }

                //MouseArea for Top Left handle
                MouseArea{
                    anchors.fill:parent
                    drag{ target: parent; axis: Drag.XAndYAxis}
                    onMouseXChanged: {
                        if(drag.active){
                            if(selComp.x >= 0 || mouseX>0){
                                selComp.width = selComp.width - mouseX
                                selComp.x = selComp.x + mouseX
                                if(selComp.width < 30)
                                    selComp.width = 30
                            }
                        }
                    }
                    onMouseYChanged: {
                        if(drag.active){
                            if(selComp.y >= 0 || mouseY>0){
                                selComp.height = selComp.height - mouseY
                                selComp.y = selComp.y + mouseY
                                if(selComp.height < 50)
                                    selComp.height = 50
                            }
                        }
                    }
                }

                //MouseArea for the Left Bar
                MouseArea {
                    anchors.fill: leftBar
                    drag{ target: parent; axis: Drag.XAxis }
                    onMouseXChanged: {
                        if(drag.active){
                            if(selComp.x >= 0 || mouseX>0){
                                selComp.width = selComp.width - mouseX
                                selComp.x = selComp.x + mouseX
                                if(selComp.width < 30)
                                    selComp.width = 30
                            }
                        }
                    }
                }
            }

            // Right
            Rectangle {
                width: rulersSize
                height: rulersSize
                radius: rulersSize
//                color: "steelblue"
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.bottom

                // Right Bar Rectangle
                Rectangle{
                    z:-2
                    id:rightBar
                    y: -height + rulersSize/2
                    height: selComp.height
                    width: selComp.border.width
                    color: selComp.border.color
                }

                //MouseArea for Top Right handle
                MouseArea{
                    anchors.fill:parent
                    drag{ target: parent; axis: Drag.XAndYAxis}
                    onMouseXChanged: {
                        if(drag.active){
                            selComp.width = selComp.width + mouseX
                            if(selComp.width < 50)
                                selComp.width = 50
                            if(selComp.width+selComp.x > image1.width)
                                selComp.width = image1.width-selComp.x
                        }
                    }
                    onMouseYChanged: {
                        if(drag.active){
                            selComp.height = selComp.height + mouseY
                            if(selComp.height < 50)
                                selComp.height = 50
                            if(selComp.height+selComp.y > image1.height)
                                selComp.height = image1.height-selComp.y
                        }
                    }
                }

                // MouseArea for Right Bar
                MouseArea {
                    anchors.fill: rightBar
                    drag{ target: parent; axis: Drag.XAxis }
                    onMouseXChanged: {
                        if(drag.active){
                            selComp.width = selComp.width + mouseX
                            if(selComp.width < 50)
                                selComp.width = 50
                            if(selComp.width+selComp.x > image1.width)
                                selComp.width = image1.width-selComp.x
                        }
                    }
                }
            }

            // Top
            Rectangle {
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                x: parent.x / 2
//                color: "steelblue"
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.top

                //Top Bar Rectangle
                Rectangle{
//                    color:"blue"
                    z:-2
                    id:topBar
                    x: -width + rulersSize/2
                    y: rulersSize/2
                    width: selComp.width
                    height: selComp.border.width
                    color: selComp.border.color
                }

                //MouseArea for Top Right handle
                MouseArea{
                    anchors.fill:parent
                    drag{ target: parent; axis: Drag.XAndYAxis}
                    onMouseXChanged: {
                        if(drag.active){
                            selComp.width = selComp.width + mouseX
                            if(selComp.width < 50)
                                selComp.width = 50
                            if(selComp.width+selComp.x > image1.width)
                                selComp.width = image1.width-selComp.x
                        }
                    }
                    onMouseYChanged: {
                        if(drag.active){
                            if(selComp.y >= 0 || mouseY>0){
                                selComp.height = selComp.height - mouseY
                                selComp.y = selComp.y + mouseY
                                if(selComp.height < 50)
                                    selComp.height = 50
                            }
                        }
                    }
                }

                //MouseArea for Top Bar
                MouseArea {
                    anchors.fill: topBar
                    drag{ target: parent; axis: Drag.YAxis }
                    onMouseYChanged: {
                        if(drag.active){
                            if(selComp.y >= 0 || mouseY>0){
                                selComp.height = selComp.height - mouseY
                                selComp.y = selComp.y + mouseY
                                if(selComp.height < 50)
                                    selComp.height = 50
                            }
                        }
                    }
                }
            }

            // Bottom
            Rectangle {
                width: rulersSize
                height: rulersSize
                radius: rulersSize
//                color: "steelblue"
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.bottom

                //Bottom Bar Rectangle
                Rectangle{
                    z:-5
                    id:bottomBar
                    x: rulersSize/2
                    y: rulersSize/2 - height
                    width: selComp.width
                    height: selComp.border.width
                    color: selComp.border.color
                }

                // MouseArea for Bottom Right Handle
                MouseArea{
                    anchors.fill:parent
                    drag{ target: parent; axis: Drag.XAndYAxis}
                    onMouseXChanged: {
                        if(drag.active){
                            if(selComp.x >= 0 || mouseX>0){
                                selComp.width = selComp.width - mouseX
                                selComp.x = selComp.x + mouseX
                                if(selComp.width < 30)
                                    selComp.width = 30
                            }
                        }
                    }
                    onMouseYChanged: {
                        if(drag.active){
                            selComp.height = selComp.height + mouseY
                            if(selComp.height < 50)
                                selComp.height = 50
                            if(selComp.height+selComp.y > image1.height)
                                selComp.height = image1.height-selComp.y
                        }
                    }
                }

                //MouseArea for Bottom Bar
                MouseArea {
                    anchors.fill: bottomBar
                    drag{ target: parent; axis: Drag.YAxis }
                    onMouseYChanged: {
                        if(drag.active){
                            selComp.height = selComp.height + mouseY
                            if(selComp.height < 50)
                                selComp.height = 50
                            if(selComp.height+selComp.y > image1.height)
                                selComp.height = image1.height-selComp.y
                        }
                    }
                }
            }
        }
    }
}
