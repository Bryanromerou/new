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
    property real memY: 0 // holds the last y of selection
    property real memHeight: 50 // holds the last width of selection
    property real memWidth: 50 // holds the last height of selection

    // Function Description: Calling this function shall rotate "mainImage" based on the root's rotationsAmount which is being change on click of rotateButton
    function rotateImage() {
//        selection.rotationAmount = rotationAmount
    }

    // Function Description: Calls on animations to start once the user is done cropping
    // ----- Scaling X and Y by a value equal to -> original.width/selection.width
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

    Rectangle{
        color: "transparent"
        property int animationDuration: 300
//        rotation: rotationAmount
        id:clippingMask
        x: (parent.width) * .025
        y: parent.height/2 - image1.height

        Image {
            id: image1
            opacity: .7
            fillMode: Image.PreserveAspectFit
            sourceSize.width: (root.width) * .95
            source: "./img/img/flowers.jpeg"
            rotation: rotationAmount
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

        // Selection
        Rectangle {
            visible: false
            id: selComp
            color: "#35FFFFFF"
            border {
                width: 10
                color: "gray"
            }
            property bool rulers: false
            property int rotationAmount: 0
            property int rulersSize: 18
            Component.onCompleted:displayRulers()
            Timer {id: timer}
            x: 0
            y: 0
            width: image1.width
            height: image1.height

            // Function Description: This function takes in two parameters the first being the time in mileseconds
            //                       and the second is a callback function that gets executed once the first parameters time's finished.
            function delay(delayTime, cb) {
                timer.interval = delayTime;
                timer.repeat = false;
                timer.triggered.connect(cb);
                timer.start();
            }

            // Function Description: Displays guidelines, then after 3000 mileseconds it makes them disappear.
            function displayRulers(){
                rulers = true
                delay(3000,()=>{
                      rulers = false
                })
            }

            // MouseArea of selComp that allows the rectangle dragged all over the image
            MouseArea {     // drag mouse area
                anchors.fill: parent
                drag{
                    target: parent
                    minimumX: 0
                    minimumY: 0
                    maximumX: ((rotationAmount-90)%360 == 0 || (rotationAmount-270)%360 == 0) ? image1.height - parent.width + (image1.height-root.width)/2 : image1.width - parent.width
                    maximumY: ((rotationAmount-90)%360 == 0 || (rotationAmount-270)%360 == 0) ? image1.width - parent.height : image1.height - parent.height
                    smoothed: true
                }
                onReleased: {
//                    resizeImage()
                    displayRulers()
                }
            }

            function moveX(){
                console.log(`This is the value of X while moving => ${x}`)
                clippingMask.x = (root.width) * .025 + x
                image1.x = -x
                displayRulers()
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

            // Start of guide lines
            Rectangle{
                visible: parent.rulers
                y:parent.height/3
                width: parent.width
                height: 1
                color: parent.border.color
            }

            Rectangle{
                visible: parent.rulers
                y:parent.height*2/3
                width: parent.width
                height: 1
                color: parent.border.color
            }

            Rectangle{
                visible: parent.rulers
                x:parent.width/3
                height: parent.height
                width: 1
                color: parent.border.color
            }

            Rectangle{
                visible: parent.rulers
                x:parent.width*2/3
                height: parent.height
                width: 1
                color: parent.border.color
            }
            // End of guide lines

            // Left
            Rectangle {
                width: parent.rulersSize
                height: parent.rulersSize
                radius: parent.rulersSize
//                color: "steelblue"
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.top

                // Left Bar Rectangle
                Rectangle{
                    z:-2
                    color:"blue"
                    id:leftBar
                    x: width
                    y: parent.rulersSize/2
                    height: selComp.height
                    width: selComp.border.width
//                    color:selComp.border.color
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
                width: parent.rulersSize
                height: parent.rulersSize
                radius: parent.rulersSize
//                color: "steelblue"
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.bottom

                // Right Bar Rectangle
                Rectangle{
                    z:-2
                    id:rightBar
                    y: -height + parent.rulersSize/2
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
                width: parent.rulersSize
                height: parent.rulersSize
                radius: parent.rulersSize
                x: parent.x / 2
//                color: "steelblue"
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.top

                //Top Bar Rectangle
                Rectangle{
//                    color:"blue"
                    z:-2
                    id:topBar
                    x: -width + parent.rulersSize/2
                    y: parent.rulersSize/2
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
                width: parent.rulersSize
                height: parent.rulersSize
                radius: parent.rulersSize
//                color: "steelblue"
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.bottom

                //Bottom Bar Rectangle
                Rectangle{
                    z:-5
                    id:bottomBar
                    x: parent.rulersSize/2
                    y: parent.rulersSize/2 - height
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

    // Crop Button
    Button1{
        id: cropButton
        text: cropMode ? "Done": "Crop Image"
        x:root.width/2- width/2
        y:root.height - height - 100

        onClicked: {
            if(!cropMode){
                selComp.visible = true
                // Remove clipping and scaling back to original size.
                clippingMask.clip = false
                scaleAnimX.to = 1
                scaleAnimY.to = 1
                scaleAnimX.start()
                scaleAnimY.start()
                clippingMask.color = "red" // This is only for debugging purposes
            }
            else{
                selComp.visible = false
                clippingMask.color = "transparent" // This is only for debugging purposes
                clippingMask.clip = true

                resizeImage()
            }
            root.cropMode = !root.cropMode
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
            root.rotateImage()
        }
    }

    //Reset Button
    Button1{
        id: resetButton
        visible: cropMode
        text: "RESET"
        textColor:"red"
        x: root.width/2 - width/2

        onClicked: {
            console.log("Reseting Image to original state")
            rotationAmount = 0
            image1.mirror = false
            root.rotateImage()
            selection.x = 0
            selection.y = 0
            selection.width = image1.width
            selection.height = image1.height
        }
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

}
