/*
Copyright 2019 Daniele Rogora

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4

Dialog {
    id: loginpage

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    DialogHeader {
        id: dhead
        acceptText: "Login"
    }

    onAccepted: {
        py.call("main.login",[email.text, pwd.text, cbox.currentItem.text])
        dhead.acceptText = "Wait"
    }

    Column {
        width: parent.width
        height: parent.height
        spacing: Theme.paddingLarge

        Item {
            // Spacer
            height: parent.height / 5
            width: 1
        }

        ComboBox {
            id: cbox
            width: parent.width
            label: "Vendor"
            menu: ContextMenu {
                MenuItem { text: "Neato"}
                MenuItem { text: "Vorwerk"}
            }
        }

        TextArea {
            id: email
            x: Theme.horizontalPageMargin
            width: parent.width
            placeholderText: "Email"
            label: "Email"
            color: Theme.secondaryColor
        }
        PasswordField {
            id: pwd
            x: Theme.horizontalPageMargin
            width: parent.width
            text: "Password"
            color: Theme.secondaryColor
        }
    }
    Python {
            id: py
            Component.onCompleted: {
                setHandler('loginsuccessful', function() {
                    console.log("Login ok!")
                });

            }
    }

}
