/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Makelainen <raine.makelainen@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.2
import QtWebKit 3.0
import Sailfish.Silica 1.0

Page {
    id: cloudAuthorisationPage

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: false
        size: BusyIndicatorSize.Large
    }

    SilicaWebView {
        id: webView
        anchors.fill: parent

        opacity: 0
        onLoadingChanged: {
            switch (loadRequest.status)
            {
            case WebView.LoadSucceededStatus:
                opacity = 1;
                busyIndicator.running = false;
                var curentUrl = loadRequest.url.toString();
                if (curentUrl === "https://www.dropbox.com/1/oauth/authorize_submit") {
                    mainWindow.startSyncing();
                    ioInterface.setConnectionStatus(true);
                    ioInterface.getAccess();
                    mainWindow.pageStack.navigateBack(PageStackAction.Immediate);
                } /*else if (curentUrl === "https://www.dropbox.com/home") {
                    mainWindow.pageStack.navigateBack();
                }*/
                break;
            case WebView.LoadFailedStatus:
                opacity = 0;
                busyIndicator.running = false;
                viewPlaceHolder.errorString = loadRequest.errorString;
                break;
            default:
                busyIndicator.running = true;
                opacity = 0.2;
                break;
            }
        }

        url: ioInterface.getAuthorizeLink()

        FadeAnimation on opacity {}
        PullDownMenu {
            MenuItem {
                text: qsTr("Reload")
                onClicked: webView.reload()
            }
        }
    }

    ViewPlaceholder {
        id: viewPlaceHolder
        property string errorString

        enabled: webView.opacity === 0 && !webView.loading
        text: qsTr("Something wrong =(")
        hintText: qsTr("Check network connectivity and pull down to reload")
    }
}
