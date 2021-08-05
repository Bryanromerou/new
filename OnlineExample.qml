import QtQuick 2.5

import QtQuick.Window 2.2

import QtQuick.Controls 1.2

import QtGraphicalEffects 1.0



Window {

visible: true

width: 1050

height: 800

title: qsTr("photo picker")



maximumHeight : image_choose.height

maximumWidth : image_choose.width+250

minimumHeight : 250

minimumWidth : 250



Rectangle{

id:orign_file

width: 800

height: 800

anchors.right: opt_area.left

anchors.top: parent.top

implicitWidth: 250

implicitHeight: 250



Image {

id: image_choose

clip:true

anchors.fill: parent

asynchronous: true

fillMode: Image.PreserveAspectFit

source: "./img/img/flowers.jpeg"

}



Rectangle{

id:a

width: 10000

height:10000

anchors.right: visi_area.left

color:"black"

opacity: 0.4

}



Rectangle{

id:c

width: 10000

height:10000

anchors.left: visi_area.right

color:"black"

opacity: 0.4

}



Rectangle{

id:b

width: visi_area.width

height:10000

anchors.bottom: visi_area.top

anchors.right: visi_area.right

color:"black"

opacity: 0.4

}



Rectangle{

id:d

width: visi_area.width

height:10000

anchors.top: visi_area.bottom

anchors.left: visi_area.left

color:"black"

opacity: 0.4

}



Rectangle {

id:visi_area

x:(parent.width-visi_area.width)/2

y:(parent.height-visi_area.height)/2

width: 250

height: 250

color: "transparent"

clip:true

MouseArea {

id:dragArea

anchors.fill: parent

drag.target: visi_area

drag.minimumX: 0

drag.minimumY: orign_file.height*0.15

drag.maximumX: orign_file.width-visi_area.width

drag.maximumY: orign_file.width*0.85-visi_area.height

// onWheel: {

 // // Each scroll is a multiple of 120

// var datla = wheel.angleDelta.y/120;

// if(datla > 0)

// {

// image_choose.scale = image_choose.scale/0.8

// }

// else

// {

// image_choose.scale = image_choose.scale*0.8

// }

// }

}

}

 //Bottom slider

Rectangle{

id:line

width: parent.width*0.6

height: 5

z:2

anchors.horizontalCenter: parent.horizontalCenter

anchors.bottom: parent.bottom

anchors.bottomMargin: 50

color:"white"



Rectangle{

id:middle

anchors.verticalCenter: parent.verticalCenter

anchors.horizontalCenter: parent.horizontalCenter

width: 3

height: 30

color:"black"

}



Rectangle{

id:slide

height: 20

width: 20

x:parent.width/2-slide.width/2

radius: height/2

z:2

color:"orange"

anchors.verticalCenter: parent.verticalCenter



MouseArea{

anchors.fill: parent

//drag.target: slide

drag.minimumX : 0

drag.maximumX : line.width

}



states: [

State {

name: "left_move"

PropertyChanges {

target: slide

x: x+(parent.width)/5

}

},

State {

name: "right_move"

PropertyChanges {

target: slide

x: x-(parent.width)/5

}

}



]





}



//left

Rectangle{

id:narrow

width: 30

height: 30

radius: height/2

anchors.verticalCenter: parent.verticalCenter

anchors.right: line.left

anchors.rightMargin: 50

color:"lightgray"

Label{

anchors.centerIn: parent

text:"-"

}

MouseArea{

anchors.fill: parent

onClicked: {

if(slide.x>0){

slide.x = slide.x - line.width/10

image_choose.scale=image_choose.scale-0.2

bbb.scale=bbb.scale-0.2

aaa.scale=aaa.scale-0.2

}

}

}

}



//right

Rectangle{

id:expand

width: 30

height: 30

radius: height/2

anchors.verticalCenter: parent.verticalCenter

anchors.left: line.right

anchors.leftMargin: 50

color:"lightgray"

Label{

anchors.centerIn: parent

text:"+"

}

MouseArea{

anchors.fill: parent

onClicked: {

if(slide.x<line.width){

slide.x = slide.x + line.width/10

image_choose.scale=image_choose.scale+0.2

bbb.scale=bbb.scale+0.2

aaa.scale=aaa.scale+0.2

}

}

}

}

}

}



 // Preview area

Rectangle{

id:opt_area

width: 250

height: parent.height

anchors.right: parent.right

anchors.top: parent.top



Button{

id:clip

width: 100

height: 50

anchors.top: parent.top

anchors.right: parent.right

 text: "Preview"

onClicked: {

file_rec.grabToImage(function(result) {

result.saveToFile("C:\\Users\\user\\Desktop\\target.png");

//aaa.source = result.url

});

}

}



 //square display

Rectangle{

id:file_rec

width: 250

height: 250

anchors.bottom: parent.bottom

anchors.right: parent.right

clip:true

color:"transparent"

Image {

id: bbb

width: 800//image_choose.width

height: 800//image_choose.height

fillMode: Image.PreserveAspectFit

asynchronous: true

x:-visi_area.x

y:-visi_area.y

 source: "./img/img/flowers.jpeg"

}

}



 //Circular display

Rectangle{

id:file_circular

width: 250

height: 250

radius: height/2

color:"black"

anchors.verticalCenter: parent.verticalCenter

anchors.right: parent.right

clip:true

Image {

id: aaa

width: 800

height: 800

fillMode: Image.PreserveAspectFit

x:-visi_area.x

y:-visi_area.y

 source: "./img/img/flowers.jpeg"

}



Rectangle{

width: 250

height: 250

color:"transparent"

opacity: 0.8

z:2

anchors.centerIn: file_circular

Rectangle{

width: 250

height: 250

radius: height/2

anchors.fill: parent

color:"black"

opacity: 0.4

}

}

}

}



}
