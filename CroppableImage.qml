import QtQuick 2.0
import QtQuick.Window 2.2

Item {
    id: root
    property color drawColor: "red"
    property int penWidth: 5
    property bool cropMode: false
    property bool drawMode: false
    property int rotationAmount: 0
    property url source : "file:///home/bryan/Pictures/butterfiy.jpeg"
    property bool undoEnabled: canvas.undoStack.length !== 0
    property bool redoEnabled: canvas.redoStack.length !== 0
    property var backgroundRectangle: null
    property int centerX: (Window.width) * .025 + mainImage.width/2
    property int centerY: clippingRect.y + mainImage.width/2

    function cropPicture(){
        console.log("now cropping picture")
        invisibleClipper.clip = true
    }

    function checkIfUndoRedo(){
        undoEnabled = canvas.undoStack.length !== 0
        redoEnabled = canvas.redoStack.length !== 0
    }
    //Function allows to call CroppableImage.clearDrawing to clear the drawing, allowing to clear the drawing from outside of this component
    function clearDrawing(){
        canvas.clear()
    }

    function undoDrawing(){
        canvas.undo()
    }

    function redoDrawing(){
        canvas.redo()
    }


    property var textInputs : []
    function createTextInput (){
        var component = Qt.createComponent("InputText.qml")
        textInputs.push(component.createObject(root,{"x":0,"y":0,"control":mainImage,"drawMode":drawMode,"rotationAmount":rotationAmount}))
    }
    Item{
        id:invisibleClipper
        anchors.fill:clippingRect
        y: backgroundRectangle.height/2 -mainImage.height/2
        x:  (Window.width) * .025
        property real originalX: (Window.width) * .025
        property real originalY: backgroundRectangle.height/2 -mainImage.height/2
//        clip: !cropMode
        onXChanged: {
            console.log("the x has been changed "+ (x-originalX))
            mainImage.x = -(x-originalX)
        }
        Image{
    //            visible: false    //-- Image should initially false
            id: mainImage
            source: root.source
            fillMode: Image.PreserveAspectFit
            sourceSize.width: (Window.width) * .95
            MouseArea{
                anchors.fill:parent
                onClicked: {
                    // Loops through each of the text on the page an it deselects all of them
                    textInputs.forEach( elm => {
                                           if(elm.objectName !== undefined){
                                               elm.deselectText()
                                           }
                                         }
                                       )
                }
            }


            // This is the canvas component that allows the user to draw on the picture
            Canvas{
                id:canvas
                anchors.fill: parent // Creates the canvas to the size of the parent(being the image)

                property var globalCtx: null
                // These variables are set to recognize any change
                property int lastX: 0
                property int lastY: 0

                property var undoStack : []
                property var redoStack : []
                property var undoStyleStack: []
                property var redoStyleStack: []

                property var events: []
                property var currentStyle: {"color":root.drawColor,"penWidth":root.penWidth}

                //Clear function that clears the canvas completely
                function clear (){
                    var ctx = getContext('2d')
                    canvas.undoStack = []
                    canvas.redoStack = []
                    canvas.undoStyleStack = []
                    canvas.redoStyleStack = []
                    ctx.reset()
                    canvas.requestPaint()
                    root.checkIfUndoRedo()
                }

                function undo (){
                    var ctx = getContext('2d')

                    // If the undo stack has something then pop it into temp and redoStack
                    if(undoStack.length >0){
                        canvas.redoStack.push(canvas.undoStack.pop())
                        canvas.redoStyleStack.push(canvas.undoStyleStack.pop())
                    }

                    ctx.reset()
                    canvas.requestPaint()
                    canvas.drawUndo(ctx)

                    ctx.stroke()
                    canvas.requestPaint()
                }

                function redo (){
                    var ctx = getContext('2d')

                    // If the undo stack has something then pop it into temp and undoStack
                    if(redoStack.length >0){
                        canvas.undoStyleStack.push(canvas.redoStyleStack.pop())
                        canvas.undoStack.push(canvas.redoStack.pop())
                    }

                    ctx.reset()
                    canvas.requestPaint()
                    canvas.drawUndo(ctx)
                    canvas.requestPaint()
                }

                function drawUndo (ctx,beginFlag = false){
                    canvas.undoStack.forEach((line,j)=>{
                        ctx.lineWidth = canvas.undoStyleStack[j].penWidth
                        ctx.strokeStyle = canvas.undoStyleStack[j].color
                        line.forEach((point,i)=>{
                            if(i===0){console.log(`First point -- ${point.x} , ${point.y}`)}
                            if(i === line.length-1){console.log(`Last Point -- ${point.x} , ${point.y}`)}
                            ctx.moveTo(point.x,point.y)
                            if(!beginFlag){
                                beginFlag = true
                                ctx.beginPath()
                            }
                            if(i+1<line.length){
                                ctx.lineTo(line[i+1].x,line[i+1].y)
                            }
                        })
                        ctx.stroke()
                        ctx.closePath()
                    })
                    root.checkIfUndoRedo()
                }

                function hangingPixelFix(incomingLine){
    //                    var lastUndoLine = canvas.undoStack.pop()
    //                    if(!lastUndoLine) return incomingLine
    //                    const incomingX = incomingLine[0].x
    //                    const lastLineX = lastUndoLine[lastUndoLine.length-1].x
    //                    if(incomingX === lastLineX ){
    //                        lastUndoLine.push(incomingLine.pop())
    //                    }
    //                    canvas.undoStack.push(lastUndoLine)
                    return incomingLine
                }

                MouseArea{
                    id:area
                    visible: drawMode
                    anchors.fill:parent
                    onPressed:{
                        canvas.lastX = mouseX
                        canvas.lastY = mouseY
                    }
                    onPositionChanged: {
                        canvas.requestPaint()
                    }
                    onReleased: {
                        canvas.currentStyle = {"color":root.drawColor,"penWidth":root.penWidth}
                        canvas.undoStyleStack.push(canvas.currentStyle)
                        canvas.undoStack.push(canvas.hangingPixelFix(canvas.events))
                        canvas.events = []
                        canvas.redoStack = []
                        root.checkIfUndoRedo()
                        console.log("Closing the path")
                    }
                }

                onPaint: {
                    var ctx = getContext('2d')

                    ctx.lineWidth = root.penWidth
                    ctx.strokeStyle = drawColor;

                    ctx.beginPath()
                    ctx.moveTo(lastX,lastY)
                    lastX = area.mouseX
                    lastY = area.mouseY
                    events.push(Qt.point(lastX,lastY))
                    ctx.lineTo(lastX,lastY)
                    ctx.stroke()

                }


            }
        }
    }



    Rectangle{
        id:clippingRect
        y: backgroundRectangle.height/2 -mainImage.height/2
        x:  (Window.width) * .025
        property real originalX: (Window.width) * .025
        property real originalY: backgroundRectangle.height/2 -mainImage.height/2
        opacity: .5
        width: mainImage.width
        height: mainImage.height
        color: cropMode? "blue" : "transparent"

//        onYChanged: {
//            console.log("the y has been changed "+ (y-originalY))
//            mainImage.y = -(y-originalY)
//            console.log(mainImage.height)
////            console.log(backgroundRectangle.height/2 -mainImage.height/2)
//        }
//        onXChanged: {
//            console.log("the x has been changed "+ (x-originalX))
//            console.log(mainImage.width)
//            mainImage.x = -(x-originalX)
//        }

        // ----------------------------CROPPING COMPONENTS----------------------------
        // Top-Left Handle(0)
        CropHandle{
            id:tl
            // When moved to the left or right also move Bottom-Left(2)
            // When moved up or down also move Top-Right(1)
            dragableArea: mainImage
            visible: cropMode
            x: 0
            y: 0
            onActivated: {
//                    bl.x = xPosition
//                    tr.y = yPosition
                console.log(`xPosition = ${xPosition} `)
                clippingRect.width = mainImage.width - xPosition
//                clippingRect.x = mainImage.x + xPosition
                clippingRect.height = mainImage.height - yPosition
//                clippingRect.y = mainImage.y + yPosition
            }
        }

        // Bottom-Right Handle(3)
        CropHandle{
            id:br
            // When moved to left or right also move Top-Right(1)
            // When moved up or down also move Bottom-Left(0)
            dragableArea: mainImage
            visible: cropMode
            rotation: 180
            x: mainImage.width - br.width
            y: mainImage.height - br.height
            onActivated: {
//                    bl.y = cropBorder.height - tr.height - yPosition
//                    tr.x = cropBorder.width - tr.width - xPosition
                clippingRect.width = mainImage.width - xPosition
                clippingRect.height = mainImage.height - yPosition
            }
        }

        //        Rectangle{
        //            id:cropBorder
        //            visible: cropMode
        //            anchors.fill: mainImage
        //            color: "transparent"
        //            border.color: "white"
        //            border.width: 2
        //        }
            // Top-Right Handle(1)
//            CropHandle{
//                id:tr
//                // When moved to left or right also move Bottom-Right(3)
//                // When moved up or down also move Top-Left(0)
//                dragableArea: parent
//                cropBorder: clippingRect
//                visible: cropMode
//                rotation: 90
//                x: cropBorder.width - tr.width
//                y: cropBorder.y
//                onActivated: {
//                    br.x = cropBorder.width - tr.width - yPosition
//                    tl.y = xPosition

//                    clippingRect.width = clippingRect.width - yPosition
//                    clippingRect.y = clippingRect.y + xPosition
//                    clippingRect.height = clippingRect.height - xPosition
//                }
//            }

            // Bottom-Left Handle(2)
//            CropHandle{
//                id:bl
//                // When moved to left or right also move Top-Left(0)
//                // When moved up or down also move Bottom-Right(3)
//                dragableArea: parent
//                cropBorder: cropBorder
//                visible: cropMode
//                rotation: 270
//                x: cropBorder.x
//                y: cropBorder.height - bl.height
//                onActivated: {
//                    br.y = cropBorder.height - tr.height - xPosition
//                    tl.x = yPosition

//                    clippingRect.width = clippingRect.width - yPosition
//                    clippingRect.x = clippingRect.x + yPosition
//                    clippingRect.height = clippingRect.height - xPosition
//                }
//            }



    }
}
