﻿import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.4
import QtQuick.Dialogs 1.3

import com.v2ray.desktop.AppProxy 1.1

ColumnLayout {
    id: layoutServer
    anchors.fill: parent
    anchors.margins: 10
    spacing: 20

    RowLayout {
        Image {
            source: "qrc:///images/icon-servers.svg"
            sourceSize.width: 40
            sourceSize.height: 40
        }

        Text {
            text: qsTr("Servers")
            color: "white"
            font.pointSize: 24
        }

        Item {      // spacer item
            Layout.fillWidth: true
            Rectangle {
                anchors.fill: parent
                color: "transparent"
            }
        }

        Button {
            text: qsTr("Add New Servers")
            contentItem: Text {
                text: parent.text
                color: "white"
            }
            background: Rectangle {
                color: parent.enabled ? (parent.down ? "#2980b9" : "#3498db") : "#bdc3c7"
                radius: 4
            }
            onClicked: function() {
                layoutServer.resetPopUpServerFields("add")
                popUpServer.open()
            }
        }
    }

    Item {
         Layout.fillWidth: true
         Layout.fillHeight: true

         ListView {
             id: listViewServers
             anchors.fill: parent
             anchors.rightMargin: 5
             flickableDirection: Flickable.HorizontalAndVerticalFlick
             headerPositioning: ListView.OverlayHeader
             clip: true

             function getColumnWidth(index) {
                 switch (index) {
                     case 0:
                         return listViewServers.width * 0.25
                     case 1:
                         return listViewServers.width * 0.275
                     case 2:
                         return listViewServers.width * 0.175
                     case 3:
                         return listViewServers.width * 0.175
                     case 4:
                         return listViewServers.width * 0.125
                     default:
                         return 0
                 }
             }

             header: Row {
                 spacing: 1
                 z: 4

                 function itemAt(index) {
                     return listViewServersRepeater.itemAt(index)
                 }
                 Repeater {
                     id: listViewServersRepeater
                     model: [
                         qsTr("Name"), qsTr("Server"), qsTr("Protocol"), qsTr("Status"),
                         qsTr("Latency")
                     ]
                     Label {
                         text: modelData
                         color: "white"
                         font.bold: true
                         padding: 10
                         width: listViewServers.getColumnWidth(index)
                         background: Rectangle {
                             color: "#354759"
                         }
                     }
                 }
             }

             model: listModelServers
             delegate: Column {
                 Row {
                     spacing: 1
                     Repeater {
                         model: values
                         ItemDelegate {
                             text: value
                             width: listViewServers.getColumnWidth(index)

                             contentItem: Text {
                                 clip: true
                                 color: "white"
                                 text: parent.text
                             }
                             background: MouseArea {
                                 anchors.fill: parent
                                 acceptedButtons: Qt.RightButton
                                 onClicked: function() {
                                     var serverName = parent.parent.data[0].text,
                                         isConnected = parent.parent.data[3].text === qsTr("Connected")

                                     menuServer.x = parent.x + mouseX
                                     menuServer.y = parent.y + mouseY
                                     menuItemServerName.text = serverName
                                     menuItemConnect.text = isConnected ? qsTr("Disconnect") : qsTr("Connect")
                                     menuServer.open()
                                 }
                             }
                         }
                     }
                 }
                 Rectangle {
                     color: "#3b4d5d"
                     width: parent.width
                     height: 1
                 }
             }

             ListModel {
                 id: listModelServers
             }

             ScrollIndicator.horizontal: ScrollIndicator { }
             ScrollIndicator.vertical: ScrollIndicator { }
         }

         Menu {
            id: menuServer
            padding: 5

            MenuItem {
                id: menuItemServerName
                enabled: false
            }

            MenuSeparator { }

            MenuItem {
                id: menuItemConnect
                text: qsTr("Connect")
                onTriggered: function() {
                    var serverName = menuItemServerName.text,
                        connected = menuItemConnect.text === qsTr("Connect")

                    AppProxy.setServerConnection(serverName, connected)
                }
            }

            MenuItem {
                id: menuItemTestLatency
                text: qsTr("Test Latency")
                onTriggered: function() {
                    menuItemTestLatency.enabled = false
                    menuItemTestAllLatency.enabled = false
                    AppProxy.getServerLatency(menuItemServerName.text)
                }
            }

            MenuItem {
                id: menuItemTestAllLatency
                text: qsTr("Test All Latency")
                onTriggered: function() {
                    menuItemTestLatency.enabled = false
                    menuItemTestAllLatency.enabled = false
                    AppProxy.getServerLatency()
                }
            }

            MenuSeparator { }

            MenuItem {
                id: menuItemEdit
                text: qsTr("Edit")
                onTriggered: function() {
                    AppProxy.getServer(menuItemServerName.text, false)
                }
            }

            MenuItem {
                id: menuItemDuplicate
                text: qsTr("Duplicate")
                onTriggered: function() {
                    AppProxy.getServer(menuItemServerName.text, true)
                }
            }

            MenuItem {
                id: menuItemDelete
                text: qsTr("Delete")
                onTriggered: function() {
                    AppProxy.removeServer(menuItemServerName.text)
                }
            }
        }
    }

    Popup {
        id: popUpServer
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        height: parent.height
        focus: true
        modal: true
        width: parent.width
        background: Rectangle {
            color: "#2e3e4e"
        }
        // The variable is used for saving the old name of server before editing
        property var editServerName

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 20

            RowLayout {
                Label {
                    id: labelServerInformation
                    text: qsTr("Server Information")
                    color: "white"
                    font.pixelSize: 20
                }

                Label {
                    id: labelAddServerMethod
                    text: qsTr("Add new servers by ")
                    color: "white"
                }

                ComboBox {
                    id: comboAddServerMethod
                    Layout.fillWidth: true
                    model: ListModel{
                        ListElement { text: qsTr("Manually setting up a V2Ray server") }
                        ListElement { text: qsTr("Manually setting up a Shadowsocks server") }
                        ListElement { text: qsTr("Subscription URL") }
                        ListElement { text: qsTr("V2Ray config files") }
                        ListElement { text: qsTr("V2Ray Desktop config files") }
                        ListElement { text: qsTr("Shadowsocks config files (gui-config.json)") }
                    }
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                    contentItem: Text {
                        text: comboAddServerMethod.displayText
                        color: "white"
                        leftPadding: 10
                        verticalAlignment: Text.AlignVCenter
                    }
                    onCurrentTextChanged: function() {
                        layoutServerV2rayManually.visible = false
                        layoutServerShadowsocksManually.visible = false
                        layoutServerSubscriptionUrl.visible = false
                        layoutServerJsonFiles.visible = false

                        if ( comboAddServerMethod.currentText === qsTr("Manually setting up a V2Ray server") ) {
                            layoutServerV2rayManually.visible = true
                        } else if ( comboAddServerMethod.currentText === qsTr("Manually setting up a Shadowsocks server") ) {
                            layoutServerShadowsocksManually.visible = true
                        } else if ( comboAddServerMethod.currentText === qsTr("Subscription URL") ) {
                            layoutServerSubscriptionUrl.visible = true
                        } else {
                            layoutServerJsonFiles.visible = true
                        }
                    }
                }
            }

            GridLayout {
                id: layoutServerV2rayManually
                columns: 4
                flow: GridLayout.LeftToRight
                rowSpacing: 20
                columnSpacing: 20

                Label {
                    text: qsTr("Server Name")
                    color: "white"
                    rightPadding: 28
                }

                TextField {
                    id: textV2RayServerName
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: HongKong-Server-1")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    text: qsTr("Auto Connect")
                    color: "white"
                }

                CheckBox {
                    id: checkboxV2RayAutoConnect
                    leftPadding: -2
                }

                Label {
                    text: qsTr("Server Address")
                    color: "white"
                }

                TextField {
                    id: textV2RayServerAddr
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: hk.example.com")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    text: qsTr("Server Port")
                    color: "white"
                }

                TextField {
                    id: textV2RayServerPort
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: 443")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    text: qsTr("ID")
                    color: "white"
                }

                TextField {
                    id: textV2RayId
                    color: "white"
                    Layout.minimumWidth: 200
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: 27848739-7e62-4138-9fd3-098a63964b6b")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    text: qsTr("Alter ID")
                    color: "white"
                }

                TextField {
                    id: textV2RayAlterId
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: 4")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    text: qsTr("Security")
                    color: "white"
                }

                ComboBox {
                    id: comboV2RaySecurity
                    Layout.minimumWidth: 180
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: ListModel{
                        ListElement { text: "Auto"; value: "auto" }
                        ListElement { text: "None"; value: "none" }
                        ListElement { text: "AES-128-GCM"; value: "aes-128-gcm" }
                        ListElement { text: "CHACHA20-POLY1305"; value: "chacha20-poly1305" }
                    }
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                    contentItem: Text {
                        text: comboV2RaySecurity.displayText
                        color: "white"
                        leftPadding: 10
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Label {
                    text: qsTr("MUX")
                    color: "white"
                }

                TextField {
                    id: textMux
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: 8 (-1 for disabled)")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    text: qsTr("Network")
                    color: "white"
                }

                ComboBox {
                    id: comboV2RayNetwork
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: ListModel{
                        ListElement { text: "TCP"; value: "tcp" }
                        ListElement { text: "KCP"; value: "kcp" }
                        ListElement { text: "Websocket"; value: "ws" }
                        ListElement { text: "HTTP/2"; value: "http" }
                        ListElement { text: "Domain Socket"; value: "domainsocket" }
                        ListElement { text: "QUIC"; value: "quic" }
                    }
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                    contentItem: Text {
                        text: comboV2RayNetwork.displayText
                        color: "white"
                        leftPadding: 10
                        verticalAlignment: Text.AlignVCenter
                    }
                    onCurrentTextChanged: function() {
                        labelV2RayTcpHeaderType.visible = false
                        comboV2RayTcpHeaderType.visible = false
                        labelV2RayKcpMtu.visible = false
                        textV2RayKcpMtu.visible = false
                        labelV2RayKcpTti.visible = false
                        textV2RayKcpTti.visible = false
                        labelV2RayKcpUplinkCapcity.visible = false
                        textV2RayKcpUplinkCapcity.visible = false
                        labelV2RayKcpDownlinkCapcity.visible = false
                        textV2RayKcpDownlinkCapcity.visible = false
                        labelV2RayReadBufferSize.visible = false
                        textV2RayKcpReadBufferSize.visible = false
                        labelV2RayKcpWriteBufferSize.visible = false
                        textV2RayKcpWriteBufferSize.visible = false
                        labelV2RayKcpCongestion.visible = false
                        checkboxV2RayKcpCongestion.visible = false
                        labelV2RayNetworkHost.visible = false
                        textV2RayNetworktHost.visible = false
                        labelV2RayNetworkPath.visible = false
                        textV2RayNetworkPath.visible = false
                        labelV2RayDomainSocketFilePath.visible = false
                        textV2RayDomainSocketFilePath.visible = false
                        labelV2RayQuicSecurity.visible = false
                        comboV2RayQuicSecurity.visible = false
                        labelV2RayPacketHeader.visible = false
                        comboV2RayPacketHeader.visible = false
                        labelV2RayQuicKey.visible = false
                        textV2RayQuicKey.visible = false

                        if ( comboV2RayNetwork.currentText === "TCP" ) {
                            labelV2RayTcpHeaderType.visible = true
                            comboV2RayTcpHeaderType.visible = true
                        } else if ( comboV2RayNetwork.currentText === "KCP" ) {
                            labelV2RayKcpMtu.visible = true
                            textV2RayKcpMtu.visible = true
                            labelV2RayKcpTti.visible = true
                            textV2RayKcpTti.visible = true
                            labelV2RayKcpUplinkCapcity.visible = true
                            textV2RayKcpUplinkCapcity.visible = true
                            labelV2RayKcpDownlinkCapcity.visible = true
                            textV2RayKcpDownlinkCapcity.visible = true
                            labelV2RayReadBufferSize.visible = true
                            textV2RayKcpReadBufferSize.visible = true
                            labelV2RayKcpWriteBufferSize.visible = true
                            textV2RayKcpWriteBufferSize.visible = true
                            labelV2RayKcpCongestion.visible = true
                            checkboxV2RayKcpCongestion.visible = true
                            labelV2RayPacketHeader.visible = true
                            comboV2RayPacketHeader.visible = true
                        } else if ( comboV2RayNetwork.currentText === "Websocket" ||
                                    comboV2RayNetwork.currentText === "HTTP/2" ) {
                            labelV2RayNetworkHost.visible = true
                            textV2RayNetworktHost.visible = true
                            labelV2RayNetworkPath.visible = true
                            textV2RayNetworkPath.visible = true
                        } else if ( comboV2RayNetwork.currentText === "Domain Socket" ) {
                            labelV2RayDomainSocketFilePath.visible = true
                            textV2RayDomainSocketFilePath.visible = true
                        } else if ( comboV2RayNetwork.currentText === "QUIC" ) {
                            labelV2RayQuicSecurity.visible = true
                            comboV2RayQuicSecurity.visible = true
                            labelV2RayPacketHeader.visible = true
                            comboV2RayPacketHeader.visible = true
                            labelV2RayQuicKey.visible = true
                            textV2RayQuicKey.visible = true
                        }
                    }
                }

                Label {
                    text: qsTr("Network Security")
                    color: "white"
                }

                ComboBox {
                    id: comboV2RayNetworkSecurity
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: ListModel{
                        ListElement { text: "None"; value: "none" }
                        ListElement { text: "TLS"; value: "tls" }
                    }
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                    contentItem: Text {
                        text: comboV2RayNetworkSecurity.displayText
                        color: "white"
                        leftPadding: 10
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Label {
                    text: qsTr("Allow Insecure")
                    color: "white"
                }

                CheckBox {
                    id: checkboxV2RayAllowInsecure
                    leftPadding: -2
                }

                Label {
                    id: labelV2RayTcpHeaderType
                    text: qsTr("TCP Header")
                    color: "white"
                }

                ComboBox {
                    id: comboV2RayTcpHeaderType
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: ListModel{
                        ListElement { text: "None"; value: "none" }
                        ListElement { text: "HTTP"; value: "http" }
                    }
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                    contentItem: Text {
                        text: comboV2RayTcpHeaderType.displayText
                        color: "white"
                        leftPadding: 10
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Label {
                    id: labelV2RayKcpMtu
                    text: qsTr("MTU")
                    color: "white"
                }

                TextField {
                    id: textV2RayKcpMtu
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Maximum transmission unit. Default value: 1350.")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    id: labelV2RayKcpTti
                    text: qsTr("TTI")
                    color: "white"
                }

                TextField {
                    id: textV2RayKcpTti
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Transmission time interval. Default value: 50.")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    id: labelV2RayKcpUplinkCapcity
                    text: qsTr("Uplink Capcity")
                    color: "white"
                }

                TextField {
                    id: textV2RayKcpUplinkCapcity
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Default value: 5.")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    id: labelV2RayKcpDownlinkCapcity
                    text: qsTr("Downlink Capcity")
                    color: "white"
                }

                TextField {
                    id: textV2RayKcpDownlinkCapcity
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Default value: 5.")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    id: labelV2RayReadBufferSize
                    text: qsTr("Read Buffer Size")
                    color: "white"
                }

                TextField {
                    id: textV2RayKcpReadBufferSize
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Default value: 2.")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    id: labelV2RayKcpWriteBufferSize
                    text: qsTr("Downlink Capcity")
                    color: "white"
                }

                TextField {
                    id: textV2RayKcpWriteBufferSize
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Default value: 2.")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    id: labelV2RayKcpCongestion
                    text: qsTr("Congestion")
                    color: "white"
                }

                CheckBox {
                    id: checkboxV2RayKcpCongestion
                    leftPadding: -2
                }

                Label {
                    id: labelV2RayNetworkHost
                    text: qsTr("Host")
                    color: "white"
                }

                TextField {
                    id: textV2RayNetworktHost
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: example.com")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    id: labelV2RayNetworkPath
                    text: qsTr("Path")
                    color: "white"
                }

                TextField {
                    id: textV2RayNetworkPath
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: /ray")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    id: labelV2RayDomainSocketFilePath
                    text: qsTr("Socket File Path")
                    color: "white"
                }

                TextField {
                    id: textV2RayDomainSocketFilePath
                    color: "white"
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: /path/to/domain/socket/file")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    id: labelV2RayQuicSecurity
                    text: qsTr("QUIC Security")
                    color: "white"
                }

                ComboBox {
                    id: comboV2RayQuicSecurity
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: ListModel{
                        ListElement { text: "None"; value: "none" }
                        ListElement { text: "AES-128-GCM"; value: "aes-128-gcm" }
                        ListElement { text: "CHACHA20-POLY1305"; value: "chacha20-poly1305" }
                    }
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                    contentItem: Text {
                        text: comboV2RayQuicSecurity.displayText
                        color: "white"
                        leftPadding: 10
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Label {
                    id: labelV2RayPacketHeader
                    text: qsTr("Packet Header")
                    color: "white"
                }

                ComboBox {
                    id: comboV2RayPacketHeader
                    Layout.fillWidth: true
                    model: ListModel{
                        ListElement { text: "srtp" }
                        ListElement { text: "utp" }
                        ListElement { text: "wechat-video" }
                        ListElement { text: "dtls" }
                        ListElement { text: "wireguard" }
                    }
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                    contentItem: Text {
                        text: comboV2RayPacketHeader.displayText
                        color: "white"
                        leftPadding: 10
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Label {
                    id: labelV2RayQuicKey
                    text: qsTr("QUIC Key")
                    color: "white"
                }

                TextField {
                    id: textV2RayQuicKey
                    color: "white"
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: Any String")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Button {
                    id: buttonV2RayAddServer
                    text: qsTr("Add Server")
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                    }
                    background: Rectangle {
                        color: parent.enabled ? (parent.down ? "#2980b9" : "#3498db") : "#bdc3c7"
                        radius: 4
                    }
                    onClicked: function() {
                        buttonV2RayAddServer.enabled = false
                        var server = {
                            "serverName": textV2RayServerName.text,
                            "serverAddr": textV2RayServerAddr.text,
                            "serverPort": parseInt(textV2RayServerPort.text),
                            "autoConnect": checkboxV2RayAutoConnect.checked,
                            "id": textV2RayId.text,
                            "alterId": textV2RayAlterId.text,
                            "security": comboV2RaySecurity.currentText,
                            "mux": parseInt(textMux.text),
                            "network": comboV2RayNetwork.currentValue,
                            "networkSecurity": comboV2RayNetworkSecurity.currentText,
                            "allowInsecure": checkboxV2RayAllowInsecure.checked,
                            "tcpHeaderType": comboV2RayTcpHeaderType.currentText,
                            "kcpMtu": parseInt(textV2RayKcpMtu.text),
                            "kcpTti": parseInt(textV2RayKcpTti.text),
                            "kcpUpLink": parseInt(textV2RayKcpUplinkCapcity.text),
                            "kcpDownLink": parseInt(textV2RayKcpDownlinkCapcity.text),
                            "kcpReadBuffer": parseInt(textV2RayKcpReadBufferSize.text),
                            "kcpWriteBuffer": parseInt(textV2RayKcpWriteBufferSize.text),
                            "kcpCongestion": checkboxV2RayKcpCongestion.checked,
                            "networkHost": textV2RayNetworktHost.text,
                            "networkPath": textV2RayNetworkPath.text,
                            "domainSocketFilePath": textV2RayDomainSocketFilePath.text,
                            "quicSecurity": comboV2RayQuicSecurity.currentText,
                            "packetHeader": comboV2RayPacketHeader.currentText,
                            "quicKey": textV2RayQuicKey.text
                        }
                        if (buttonV2RayAddServer.text === qsTr("Add Server")) {
                            AppProxy.addV2RayServer(JSON.stringify(server))
                        } else {
                            AppProxy.editServer(popUpServer.editServerName, "vmess", JSON.stringify(server))
                        }
                    }
                }
            }

            GridLayout {
                id: layoutServerShadowsocksManually
                columns: 4
                flow: GridLayout.LeftToRight
                rowSpacing: 20
                columnSpacing: 20
                visible: false

                Label {
                    text: qsTr("Server Name")
                    color: "white"
                    rightPadding: 28
                }

                TextField {
                    id: textShadowsocksServerName
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: HongKong-Server-1")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    text: qsTr("Auto Connect")
                    color: "white"
                }

                CheckBox {
                    id: checkboxShadowsocksAutoConnect
                    leftPadding: -2
                }

                Label {
                    text: qsTr("Server Address")
                    color: "white"
                }

                TextField {
                    id: textShadowsocksServerAddr
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: hk.example.com")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    text: qsTr("Server Port")
                    color: "white"
                }

                TextField {
                    id: textShadowsocksServerPort
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: 8388")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Label {
                    text: qsTr("Security")
                    color: "white"
                }

                ComboBox {
                    id: comboShadowsocksEncryptionMethod
                    Layout.fillWidth: true
                    model: ListModel{
                        ListElement { text: "AES-128-CFB" }
                        ListElement { text: "AES-128-CTR" }
                        ListElement { text: "AES-128-GCM" }
                        ListElement { text: "AES-192-CFB" }
                        ListElement { text: "AES-192-CTR" }
                        ListElement { text: "AES-192-GCM" }
                        ListElement { text: "AES-256-CFB" }
                        ListElement { text: "AES-256-CTR" }
                        ListElement { text: "AES-256-GCM" }
                        ListElement { text: "BF-CFB" }
                        ListElement { text: "CAMELLIA-128-CFB" }
                        ListElement { text: "CAMELLIA-192-CFB" }
                        ListElement { text: "CAMELLIA-256-CFB" }
                        ListElement { text: "CAST5-CFB" }
                        ListElement { text: "CHACHA20" }
                        ListElement { text: "CHACHA20-IETF" }
                        ListElement { text: "CHACHA20-IETF-POLY1305" }
                        ListElement { text: "DES-CFB" }
                        ListElement { text: "IDEA-CFB" }
                        ListElement { text: "RC4-MD5" }
                        ListElement { text: "SALSA20" }
                        ListElement { text: "SEED-CFB" }
                        ListElement { text: "SERPENT-256-CFB" }
                    }
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                    contentItem: Text {
                        text: comboShadowsocksEncryptionMethod.displayText
                        color: "white"
                        leftPadding: 10
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Label {
                    text: qsTr("Password")
                    color: "white"
                }

                TextField {
                    id: textShadowsocksPassword
                    color: "white"
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Button {
                    id: buttonShadowsocksAddServer
                    text: qsTr("Add Server")
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                    }
                    background: Rectangle {
                        color: parent.enabled ? (parent.down ? "#2980b9" : "#3498db") : "#bdc3c7"
                        radius: 4
                    }
                    onClicked: function() {
                        buttonShadowsocksAddServer.enabled = false
                        var server = {
                            "serverName": textShadowsocksServerName.text,
                            "serverAddr": textShadowsocksServerAddr.text,
                            "serverPort": parseInt(textShadowsocksServerPort.text),
                            "autoConnect": checkboxShadowsocksAutoConnect.checked,
                            "encryption": comboShadowsocksEncryptionMethod.currentText,
                            "password": textShadowsocksPassword.text
                        }
                        if (buttonShadowsocksAddServer.text === qsTr("Add Server")) {
                            AppProxy.addShadowsocksServer(JSON.stringify(server))
                        } else {
                            AppProxy.editServer(popUpServer.editServerName, "shadowsocks", JSON.stringify(server))
                        }
                    }
                }
            }

            GridLayout {
                id: layoutServerSubscriptionUrl
                columns: 2
                flow: GridLayout.LeftToRight
                rowSpacing: 20
                columnSpacing: 20
                visible: false

                Label {
                    text: qsTr("Subscription URL")
                    color: "white"
                    rightPadding: 2
                }

                TextField {
                    id: textSubsriptionUrl
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: https://url/to/subscription")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Button {
                    id: buttonSubscriptionAddServer
                    text: qsTr("Add Servers")
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                    }
                    background: Rectangle {
                        color: parent.enabled ? (parent.down ? "#2980b9" : "#3498db") : "#bdc3c7"
                        radius: 4
                    }
                    onClicked: function() {
                        buttonSubscriptionAddServer.enabled = false
                        AppProxy.addSubscriptionUrl(textSubsriptionUrl.text)
                    }
                }
            }

            GridLayout {
                id: layoutServerJsonFiles
                columns: 3
                flow: GridLayout.LeftToRight
                rowSpacing: 20
                columnSpacing: 20
                visible: false

                Label {
                    text: qsTr("Config File Path")
                    color: "white"
                    rightPadding: 12
                }

                TextField {
                    id: textConfigFilePath
                    color: "white"
                    Layout.fillWidth: true
                    placeholderText: qsTr("Example: /path/to/config.json")
                    background: Rectangle {
                        color: Qt.rgba(255, 255, 255, .1)
                        border.color: Qt.rgba(120, 130, 140, .2)
                    }
                }

                Button {
                    id: buttonSelectConfigFile
                    text: qsTr("Choose File")
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                    }
                    background: Rectangle {
                        color: parent.enabled ? (parent.down ? "#2980b9" : "#3498db") : "#bdc3c7"
                        radius: 4
                    }
                    onClicked: function() {
                    }
                }

                Button {
                    id: buttonConfigAddServer
                    text: qsTr("Add Servers")
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                    }
                    background: Rectangle {
                        color: parent.enabled ? (parent.down ? "#2980b9" : "#3498db") : "#bdc3c7"
                        radius: 4
                    }
                    onClicked: function() {
                    }
                }
            }

            Item {      // spacer item
                Layout.fillWidth: true
                Layout.fillHeight: true
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                }
            }
        }
    }

    Connections {
        target: AppProxy

        function getServerPrettyInformation(server) {
            var serverAddress, serverPort, serverName, status, latency
            if (server["protocol"] === "vmess") {
                serverAddress = server["settings"]["vnext"][0]["address"]
                serverPort = server["settings"]["vnext"][0]["port"]
                serverName = server["serverName"] || serverAddress
                status = server["connected"] ? qsTr("Connected") : qsTr("Disconnected")
                latency = "latency" in server ?
                            (server["latency"] === -1 ?
                                 qsTr("Timeout") : server["latency"].toString() + " ms") : qsTr("N/a")

                return [
                    {value: serverName},
                    {value: serverAddress + ":" + serverPort},
                    {value: "V2Ray"},
                    {value: status},
                    {value: latency}
                ]
            } else if (server["protocol"] === "shadowsocks") {
                serverAddress = server["settings"]["servers"][0]["address"]
                serverPort = server["settings"]["servers"][0]["port"]
                serverName = server["serverName"] || serverAddress
                status = server["connected"] ? qsTr("Connected") : qsTr("Disconnected")
                latency = "latency" in server ?
                            (server["latency"] === -1 ?
                                 qsTr("Timeout") : server["latency"].toString() + " ms") : qsTr("N/a")
                return [
                    {value: serverName},
                    {value: serverAddress + ":" + serverPort},
                    {value: "Shadowsocks"},
                    {value: status},
                    {value: latency}
                ]
            }
        }

        onServersReady: function(servers) {
            servers = JSON.parse(servers)
            listModelServers.clear()
            for (var i = 0; i < servers.length; ++ i) {
                listModelServers.append({values: getServerPrettyInformation(servers[i])})
            }
        }

        onServerLatencyReady: function(serverLatency) {
            serverLatency = JSON.parse(serverLatency)
            // Refresh latency in server list
            for (var i = 0; i < listModelServers.count; ++ i) {
                var server = listModelServers.get(i),
                    serverName = server.values.get(0).value

                if (serverName in serverLatency) {
                    var latency = serverLatency[serverName]
                    latency = latency === -1 ? qsTr("Timeout") : latency.toString() + " ms"
                    server.values.set(4, {value: latency})
                }
            }
            menuItemTestLatency.enabled = true
            menuItemTestAllLatency.enabled = true
        }

        onAddServerError: function(errorMessage) {
            console.log(errorMessage)
        }

        onServersChanged: function() {
            AppProxy.getServers()
            popUpServer.close()
        }

        onServerDInfoReady: function(server) {
            server = JSON.parse(server)
            layoutServer.resetPopUpServerFields("serverName" in server ? "edit" : "add")

            // Set correct form in pop up window
            var protocol = server["protocol"]
            if (protocol === "vmess") {
                comboAddServerMethod.currentIndex = 0
                textV2RayServerName.text = server["serverName"] || ""
                textV2RayServerAddr.text = server["settings"]["vnext"][0]["address"]
                textV2RayServerPort.text = server["settings"]["vnext"][0]["port"]
                checkboxV2RayAutoConnect.checked = server["autoConnect"]
                textV2RayId.text = server["settings"]["vnext"][0]["users"][0]["id"]
                textV2RayAlterId.text = server["settings"]["vnext"][0]["users"][0]["alterId"]
                comboV2RaySecurity.currentIndex = comboV2RaySecurity.indexOfValue(
                        server["settings"]["vnext"][0]["users"][0]["security"])
                textMux.text = server["mux"]["enabled"] ? server["mux"]["concurrency"] : -1
                comboV2RayNetwork.currentIndex = comboV2RayNetwork.indexOfValue(
                        server["streamSettings"]["network"])
                comboV2RayNetworkSecurity.currentIndex =
                    comboV2RayNetworkSecurity.indexOfValue(
                        server["streamSettings"]["security"])
                checkboxV2RayAllowInsecure.checked = server["streamSettings"]["tlsSettings"]["allowInsecure"]

                if (server["streamSettings"]["network"] === "tcp") {
                    comboV2RayTcpHeaderType.currentIndex =
                        comboV2RayTcpHeaderType.indexOfValue(
                            server["streamSettings"]["tcpSettings"]["type"])
                } else if (server["streamSettings"]["network"] === "kcp") {
                    textV2RayKcpMtu.text = server["streamSettings"]["kcpSettings"]["mtu"]
                    textV2RayKcpTti.text = server["streamSettings"]["kcpSettings"]["tti"]
                    textV2RayKcpUplinkCapcity.text = server["streamSettings"]["kcpSettings"]["uplinkCapacity"]
                    textV2RayKcpDownlinkCapcity.text = server["streamSettings"]["kcpSettings"]["downlinkCapacity"]
                    textV2RayKcpReadBufferSize.text = server["streamSettings"]["kcpSettings"]["readBufferSize"]
                    textV2RayKcpWriteBufferSize.text = server["streamSettings"]["kcpSettings"]["writeBufferSize"]
                    checkboxV2RayKcpCongestion.checked = server["streamSettings"]["kcpSettings"]["congestion"]
                    comboV2RayPacketHeader.currentIndex = comboV2RayPacketHeader.indexOfValue(
                        server["streamSettings"]["kcpSettings"]["header"]["type"])
                } else if (server["streamSettings"]["network"] === "ws") {
                    textV2RayNetworktHost.text =
                        server["streamSettings"]["wsSettings"]["headers"]["host"]
                    textV2RayNetworkPath.text = server["streamSettings"]["wsSettings"]["path"]
                } else if (server["streamSettings"]["network"] === "http") {
                    textV2RayNetworktHost.text =
                        server["streamSettings"]["wsSettings"]["headers"]["host"][0]
                    textV2RayNetworkPath.text = server["streamSettings"]["wsSettings"]["path"]
                } else if (server["streamSettings"]["network"] === "domainsocket") {
                    textV2RayQuicKey.text = server["streamSettings"]["dsSettings"]["path"]
                } else if (server["streamSettings"]["network"] === "quic") {
                    comboV2RayQuicSecurity.currentIndex = comboV2RayQuicSecurity.indexOfValue(
                        server["streamSettings"]["quicSettings"]["security"])
                    comboV2RayPacketHeader.currentIndex = comboV2RayPacketHeader.indexOfValue(
                        server["streamSettings"]["quicSettings"]["header"])
                    textV2RayQuicKey.text = server["streamSettings"]["quicSettings"]["key"]
                }
            } else if (protocol === "shadowsocks") {
                comboAddServerMethod.currentIndex = 1
                textShadowsocksServerName.text = server["serverName"] || ""
                textShadowsocksServerAddr.text = server["settings"]["servers"][0]["address"]
                textShadowsocksServerPort.text = server["settings"]["servers"][0]["port"]
                checkboxShadowsocksAutoConnect.checked = server["autoConnect"]
                comboShadowsocksEncryptionMethod.currentIndex =
                    comboShadowsocksEncryptionMethod.find(
                        server["settings"]["servers"][0]["method"].toUpperCase())
                textShadowsocksPassword.text = server["settings"]["servers"][0]["password"]
            }
            popUpServer.editServerName = server["serverName"] || ""
            popUpServer.open()
        }
    }

    Component.onCompleted: function() {
        AppProxy.getServers()
    }

    function resetPopUpServerFields(propose) {
        // Clear text fields for V2Ray
        textV2RayServerName.text = ""
        textV2RayServerAddr.text = ""
        textV2RayServerPort.text = ""
        checkboxV2RayAutoConnect.checked = false
        textV2RayId.text = ""
        textV2RayAlterId.text = ""
        comboV2RaySecurity.currentIndex = 0
        comboV2RayNetwork.currentIndex = 0
        comboV2RayNetworkSecurity.currentIndex = 0
        checkboxV2RayAllowInsecure.checked = false
        comboV2RayTcpHeaderType.currentIndex = 0
        textV2RayKcpMtu.text = ""
        textV2RayKcpTti.text = ""
        textV2RayKcpUplinkCapcity.text = ""
        textV2RayKcpDownlinkCapcity.text = ""
        textV2RayKcpReadBufferSize.text = ""
        textV2RayKcpWriteBufferSize.text = ""
        checkboxV2RayKcpCongestion.checked = false
        textV2RayNetworktHost.text = ""
        textV2RayNetworkPath.text = ""
        textV2RayDomainSocketFilePath.text = ""
        comboV2RayQuicSecurity.currentIndex = 0
        comboV2RayPacketHeader.currentIndex = 0
        textV2RayQuicKey.text = ""
        // Clear text fields for Shadowsocks
        textShadowsocksServerName.text = ""
        textShadowsocksServerAddr.text = ""
        textShadowsocksServerPort.text = ""
        checkboxShadowsocksAutoConnect.checked = false
        comboShadowsocksEncryptionMethod.currentIndex = 0
        textShadowsocksPassword.text = ""
        // Clear text fields for subscrption
        textSubsriptionUrl.text = ""
        // Clear text fields for config files
        textConfigFilePath.text = ""
        // Initialize controls for editing or creating
        var i = 0,
            popUpButtons = [
                buttonV2RayAddServer, buttonShadowsocksAddServer,
                buttonSubscriptionAddServer, buttonConfigAddServer
            ]
        for (i = 0; i < popUpButtons.length; ++ i) {
            popUpButtons[i].enabled = true
        }
        if (propose === "edit") {
            labelServerInformation.visible = true
            labelAddServerMethod.visible = false
            comboAddServerMethod.visible = false
            for (i = 0; i < popUpButtons.length; ++ i) {
                popUpButtons[i].text = "Edit Server"
            }
        } else {
            labelServerInformation.visible = false
            labelAddServerMethod.visible = true
            comboAddServerMethod.visible = true
            for (i = 0; i < popUpButtons.length; ++ i) {
                popUpButtons[i].text = "Add Server"
            }
        }
    }
}
