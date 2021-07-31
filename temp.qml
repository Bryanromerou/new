Item{
    y: backgroundRectangle.height/2 -mainImage.height/2
    x:  (Window.width) * .025
    onXChanged: {

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
