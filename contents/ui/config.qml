/*
    SPDX-FileCopyrightText: 2015 Ivan Safonov <safonov.ivan.s@gmail.com>
    SPDX-FileCopyrightText: 2024 Steve Storey <sstorey@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as QQD2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root
    twinFormLayouts: parentLayout

    // Image properties
    property string cfg_Image
    property string cfg_OverlayImage
    property int cfg_FillMode

    // Rainflake properties
    property string cfg_Rainflake
    property int cfg_Particles
    property int cfg_Size
    property int cfg_Velocity

    Kirigami.Separator {
        id: backgroundSeparator
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18nd("plasma_applet_org.kde.rain", "Background")
        visible: true
    }

    Column {
        Kirigami.FormData.label: ""
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            text: i18nd("plasma_applet_org.kde.rain", "Image:")
        }

        QQC2.Button {
            width: 240
            height: 135
            text: "                                                    "

            Image {
                id: backgroundImage
                anchors.margins: 2
                anchors.fill: parent
                fillMode: cfg_FillMode
                source: cfg_Image
                antialiasing: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        imageFileDialog.target = "background"
                        imageFileDialog.open()
                    }
                }
            }
        }

        QQC2.Label {
            text: i18nd("plasma_applet_org.kde.rain", "Overlay Background:")
        }

        QQC2.Button {
            width: 240
            height: 135
            text: "                                                    "

            Image {
                id: overlayBackgroundImage
                anchors.margins: 2
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: cfg_OverlayImage
                antialiasing: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        imageFileDialog.target = "overlay"
                        imageFileDialog.open()
                    }
                }
            }
        }
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: i18nd("plasma_applet_org.kde.rain", "Positioning:")

        model: [
            {
                'label': i18nd("plasma_applet_org.kde.image", "Scaled and Cropped"),
                'fillMode': Image.PreserveAspectCrop
            },
            {
                'label': i18nd("plasma_applet_org.kde.image", "Scaled"),
                'fillMode': Image.Stretch
            },
            {
                'label': i18nd("plasma_applet_org.kde.image", "Scaled, Keep Proportions"),
                'fillMode': Image.PreserveAspectFit
            },
            {
                'label': i18nd("plasma_applet_org.kde.image", "Centered"),
                'fillMode': Image.Pad
            },
            {
                'label': i18nd("plasma_applet_org.kde.image", "Tiled"),
                'fillMode': Image.Tile
            }
        ]
        textRole: "label"
        valueRole: "fillMode"
        Component.onCompleted: currentIndex = indexOfValue(cfg_FillMode)
        onActivated: cfg_FillMode = currentValue
    }

    Kirigami.Separator {
        id: rainSeparator
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18nd("plasma_applet_org.kde.rain", "Rain")
        visible: true
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: i18nd("plasma_applet_org.kde.rain", "Rainflake:")

        textRole: "name"
        valueRole: 'filePath'
        model: [{
            name: "Gota",
            filePath: "data/rainflake1.png"
        }]

        Component.onCompleted: currentIndex = indexOfValue(cfg_Rainflake)
        onActivated: cfg_Rainflake = currentValue
    }

    QQC2.SpinBox {
        Kirigami.FormData.label: i18nd("plasma_applet_org.kde.rain", "Number of rainflakes zzzzzzz:")

        value: cfg_Particles
        from: 100
        to: 500
        onValueChanged: cfg_Particles = value
    }

    QQD2.FileDialog {
        id: imageFileDialog
        property string target: "background"
        title: i18nd("plasma_applet_org.kde.rain", "Please choose an image")
        nameFilters: [ "Image files (*.png *.jpg)", "All files (*)" ]
        onAccepted: {
            if (target === "overlay") {
                cfg_OverlayImage = selectedFile
                overlayBackgroundImage.source = selectedFile
            } else {
                cfg_Image = selectedFile
                backgroundImage.source = selectedFile
            }
        }
    }
}
