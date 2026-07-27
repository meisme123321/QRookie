/*
 Copyright (c) 2024 glaumar <glaumar@geekgo.tech>

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import DeviceManager
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import VrpManager
import org.kde.kirigami as Kirigami

import "Tabs/Games/"
import "Tabs/Downloads/"
import "Tabs/Devices/"
import "Tabs/Users/"

Kirigami.ApplicationWindow {
    id: app

    property VrpManager vrp
    property DeviceManager deviceManager

    visible: true
    width: 1280
    height: 800
    title: qsTr("QRookie")
    Component.onCompleted: {
        deviceManager.enableAutoUpdate();
        if (app.vrp.settings.publicConfigUrl.length === 0) {
            publicConfigDialog.open();
        } else {
            vrp.updateMetadataQml();
        }
    }

    StackLayout {
        currentIndex: bar.currentIndex
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.topMargin: 10

        Games {
            id: games_tab
        }

        Downloads {
            id: downloads_tab
        }

        Device {
            id: device_tab
        }

        Users {
            id: users_tab
        }

    }

    vrp: VrpManager {
    }

    deviceManager: vrp.deviceManager()

    Dialog {
        id: publicConfigDialog
        modal: true
        title: qsTr("Public Config URL")
        standardButtons: Dialog.Ok | Dialog.Cancel

        contentItem: ColumnLayout {
            spacing: 10
            width: 560

            Text {
                text: qsTr("Enter the public config URL to download VRP metadata and install packages.")
                wrapMode: Text.WordWrap
                width: parent.width
            }

            TextField {
                id: publicConfigUrlField
                text: app.vrp.settings.publicConfigUrl
                placeholderText: qsTr("https://example.com/vrp-public.json")
                Layout.fillWidth: true
                focus: true
            }

            Text {
                id: urlErrorText
                text: qsTr("A valid public config URL is required.")
                color: "red"
                visible: publicConfigUrlField.text.trim().length === 0
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }

        onAccepted: {
            if (publicConfigUrlField.text.trim().length > 0) {
                app.vrp.settings.publicConfigUrl = publicConfigUrlField.text.trim();
                vrp.updateMetadataQml();
            } else {
                publicConfigDialog.open();
            }
        }

        onRejected: {
            Qt.quit();
        }
    }

    header: TabBar {
        id: bar

        TabButton {
            text: qsTr("Games")
        }

        TabButton {
            text: qsTr("Downloads")
        }

        TabButton {
            text: qsTr("Devices")
        }

        TabButton {
            text: qsTr("Users")
            visible: app.deviceManager.usersList.length > 1
            width: visible ? undefined : 0
        }

    }

}
