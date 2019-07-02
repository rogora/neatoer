/*
Copyright 2019 Daniele Rogora

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4

CoverBackground {
    Column {
        width: parent.width

        Label {
            id: label
            text: "Neatoer"
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.highlightColor
        }
        Label {
            id: rstate
            text: "Neatoer"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            id: risdocked
            text: "Neatoer"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            id: rischarging
            text: "Neatoer"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            id: rcharge
            text: "Neatoer"
            anchors.horizontalCenter: parent.horizontalCenter
        }

    }
    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: py.call("main.update_state", [])
        }
    }

    Python {
            id: py
            Component.onCompleted: {
                py.addImportPath(Qt.resolvedUrl('../../python/'));
                py.importModule('main',function(){
            })
            setHandler('httperror', function(err) {
                rstate.text = "Not accessible"
                rstate.color = "red"
            });
            setHandler('state', function(state, dock, charge, sched, chargelevel) {
                if (state === 1) {
                    rstate.text = "State: idle"
                    rstate.color = Theme.primaryColor
                } else if (state === 2) {
                    rstate.text = "State: cleaning"
                    rstate.color = Theme.primaryColor
                }
                else if (state === 4) {
                    rstate.text = "State: error"
                    rstate.color = "red"
                }
                else {
                    rstate.text = "State: " + state
                    rstate.color = Theme.primaryColor
                }

                risdocked.text = "Docked: " + dock
                rischarging.text = "Charging: " + charge
                rcharge.text = "Charge: " + chargelevel + "%"
            });

            }
    }

}
