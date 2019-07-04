/*
Copyright 2019 Daniele Rogora

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4

Page {
    id: page
    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    RemorsePopup {
           id: remorse
    }
    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Logout")
                onClicked: remorse.execute(qsTr("Deleting secrets"), function() {
                    py.call("main.logout", []);
                    Qt.quit();
                });
            }
            MenuItem {
                text: qsTr("Disable Schedule")
                id: schedulepull
                onClicked: function() {
                    if (schedulepull.text === "Disable Schedule") {
                        py.call("main.disable_schedule", []);
                    } else {
                        py.call("main.enable_schedule", []);
                    }
                    maps_list.clear();
                    py.call("main.update_state", []);
                }
            }
            MenuItem {
                text: qsTr("Start cleaning")
                onClicked: function() {
                    py.call("main.start_cleaning", [])
                    maps_list.clear();
                    py.call("main.update_state", []);

                }
            }
            MenuItem {
                text: qsTr("Return to base")
                onClicked: py.call("main.return_to_base", [])
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: function() {maps_list.clear(); py.call("main.update_state", [])}
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        BusyIndicator {
            id: bindicator
            running: true
            visible: true
            size: BusyIndicatorSize.Large
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column
            visible: false
            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Neatoer")
            }
            ListModel {
                 id: robots_list
            }
            ComboBox {
                id: cbox
                width: parent.width
                label: "Device"
                menu: ContextMenu {
                    Repeater {
                        model: robots_list
                        delegate: MenuItem {
                            text: rname
                        }
                    }
                }
                onValueChanged: py.call("main.set_device", [cbox.currentItem.text])
            }
            SectionHeader {
                text: "State"
            }
            Label {
                id: rstate
                color: Theme.primaryColor
                padding: Theme.paddingSmall
            }
            Label {
                id: risdocked
                color: Theme.primaryColor
                padding: Theme.paddingSmall
            }
            Label {
                id: rischarging
                color: Theme.primaryColor
                padding: Theme.paddingSmall
            }
            Label {
                id: rcharge
                color: Theme.primaryColor
                padding: Theme.paddingSmall
            }
            Label {
                id: risscheduleenabled
                color: Theme.primaryColor
                padding: Theme.paddingSmall
            }
            SectionHeader {
                text: "History"
            }
            ListModel {
                 id: maps_list
            }
            ExpandingSectionGroup {
                id: mapexp
                Repeater {
                    model: maps_list
                    ExpandingSection {
                        id: mapdetails
                        title: start
                        content.sourceComponent: Column {
                            Label {
                                text: "Area:" + area + "mq"
                            }
                            Label {
                                text: "Duration: " + end
                            }
                            Label {
                                text: "Launched from " + from
                            }

                            Image {
                                width: 400
                                height: 400
                                source: url
                            }
                        }
                    }
                }
            }
        }
        Python {
                id: py
                Component.onCompleted: {
                    py.addImportPath(Qt.resolvedUrl('../../python/'));
                    py.addImportPath(Qt.resolvedUrl('../../python/pybotvac/'));
                    py.addImportPath(Qt.resolvedUrl('../../python/dateutil/'));
                    py.addImportPath(Qt.resolvedUrl('../../python/requests/'));
                    py.addImportPath(Qt.resolvedUrl('../../python/urllib3/src/'));
                    py.addImportPath(Qt.resolvedUrl('../../python/chardet/'));

                    py.importModule('main',function(){
                        py.call("main.init",[])
                    })
                setHandler('loginrequired', function() {
                    console.log("Login required")
                    pageStack.push(Qt.resolvedUrl("LoginPage.qml"))
                });
                setHandler('loginsuccessful', function() {
                    console.log("Login loginsuccessful")
                    bindicator.visible = false
                    column.visible = true
                });
                setHandler('rfound', function(rname) {
                    console.log("Found " + rname)
                    robots_list.append({"rname": rname});
                });
                setHandler('httperror', function(err) {
                    console.log("Got http error " + err)
                    rstate.text = "Not accessible"
                    rstate.color = "red"
                });
                setHandler('addmap', function(url, start, end, area, from) {
                    //console.log("Map " + url)
                    maps_list.append({"url": url, "start": start, "end": end, "area": area, "from": from});
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
                        console.log("Got state " + state)
                        rstate.text = "State: " + state
                        rstate.color = Theme.primaryColor
                    }

                    risdocked.text = "Docked: " + dock
                    rischarging.text = "Charging: " + charge
                    risscheduleenabled.text = "ScheduleEnabled: " + sched
                    rcharge.text = "Charge: " + chargelevel + "%"
                    schedulepull.text = sched ? "Disable Schedule" : "Enable Schedule"
                });

                }

        }
    }
}
