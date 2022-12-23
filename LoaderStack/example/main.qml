/*! WARNING!
  Before run this example, need run test server!
  Run test server:
  1. Open terminal, go to $PROJECT_PATH/LoaderStack/example/test-server
  2. Start command: python2 ./server.py
*/
import QtQuick 2.5
import QtQuick.Window 2.5

import "../LoaderStack"

//Item { // when use QQmlEngine
Window{ // when use QQmlApplicationEngine
    id: root
    //anchors.fill: parent
    width: 1024
    height: 768

    visible: true

    property string appUrl: "http://localhost:8000/loadedComponent.qml"
    property string errUrl: "http://localhost:8000/errorComponent.qml"
    property string tmpUrl: "http://localhost:8000/tempoComponent.qml"

    Loader {
        id: loader
        width: parent.width/2
        height: parent.height
        onStatusChanged: {
            if (loader.status == Loader.Ready){ console.log('Loader loaded component'); }
        }
        Component.onCompleted: {
            if(loader.hasOwnProperty('asynchronous')){ asynchronous = true; }
        }
        onLoaded: {
            console.log("loader onLoaded handler");
        }
        signal input(variant data) // Data from page i.e. user input
        onInput: {
            console.log("loader onInput handler "+JSON.stringify(data));
        }
        signal error(string error_string) //
        onError: {
            console.log("loader onError handler "+JSON.stringify(data));
        }
        signal unLoaded(variant data) //
        onUnLoaded: {
            console.log("loader unLoaded handler "+JSON.stringify(data));
        }
    }

    LoaderStack {
        id: loaderstack
        anchors.right: parent.right
        width: parent.width/2
        height: parent.height
    }

    Component.onCompleted: {
        var start, page;

        // Loader
        console.log("test sync loader.source=...");
        start = new Date().getTime();
        loader.source = tmpUrl;
        console.log('Loader execution time = ' + (new Date().getTime() - start));
/*
        console.log("test async: loader.setSource...");
        start = new Date().getTime();
        page = loader.setSource(appUrl, { "color": "blue", "objectName":"Loader_second" });
        console.log('Loader execution time = ' + (new Date().getTime() - start) + " page="+page);


        // LoaderStack
        console.log("test loaderstack.setSource...");
        start = new Date().getTime();
        page = loaderstack.setSource(appUrl, { "color": "blue", "objectName":"zero" });
        console.log('LoaderStack execution time = ' + (new Date().getTime() - start));
        page.loaded.connect( (function(){
            var thispage = page;
            return function(data){
                console.log("loaded handler zero thispage="+thispage+" loaderstack.item="+loaderstack.item);
            };
        })());
        page.input.connect( (function(){
            var thispage = page;
            return function(data){
                console.log("input handler zero "+JSON.stringify(data));
                thispage.unLoad();
            };
        })());
        page.unLoaded.connect( (function(){
            var thispage = page;
            return function(data){
                console.log("unloaded handler zero thispage="+thispage+" loaderstack.item="+loaderstack.item);
            };
        })());

        start = new Date().getTime();
        page = loaderstack.setSource(appUrl, { "color": "red", "objectName":"first" });
        console.log('LoaderStack execution time = ' + (new Date().getTime() - start));
        page.loaded.connect( (function(){
            var thispage = page;
            return function(data){
                console.log("loaded handler first thispage="+thispage+" loaderstack.item="+loaderstack.item);
            };
        })());
        page.input.connect( (function(){
            var thispage = page;
            return function(data){
            console.log("input handler first "+JSON.stringify(data));
            thispage.unLoad();
        }; })());
        page.unLoaded.connect( (function(){
            var thispage = page;
            return function(data){
                console.log("unloaded handler first thispage="+thispage+" loaderstack.item="+loaderstack.item);
            };
        })());


        start = new Date().getTime();
        page = loaderstack.setSource(tmpUrl, { "objectName":"three_Tempo" });
        console.log('LoaderStack execution time = ' + (new Date().getTime() - start));
        page.loaded.connect(function(){
            console.log("loaded handler three_Tempo "+page);
        });
        page.input.connect(function(data){
            console.log("input handler three_Tempo "+JSON.stringify(data));
        });
        page.unLoaded.connect(function(){
            console.log("unLoaded handler three_Tempo "+page);
            start = new Date().getTime();
            page = loaderstack.setSource(appUrl, { "color": "red", "objectName":"three" });
            console.log('LoaderStack execution time = ' + (new Date().getTime() - start));
            page.loaded.connect(function(){
                console.log("loaded handler three "+page);
            });
            page.input.connect(function(data){
                console.log("input handler three "+JSON.stringify(data));
                page.unLoad();
            });
            page.unLoaded.connect(function(){
                console.log("unLoaded handler three "+page);
                start = new Date().getTime();
                page = loaderstack.setSource(appUrl, { "color": "green", "notexist": "property", "objectName":"three_notexistproperty" });
                console.log('LoaderStack execution time = ' + (new Date().getTime() - start));
                page.loaded.connect(function(){
                    console.log("loaded handler three_notexistproperty "+page);
                });
                page.input.connect(function(data){
                    console.log("input handler three_notexistproperty "+JSON.stringify(data));
                    page.unLoad();
                });
                page.unLoaded.connect(function(){
                    console.log("unLoaded handler three_notexistproperty "+page);
                    start = new Date().getTime();
                    page = loaderstack.setSource(errUrl, { "color": "brown", "objectName":"three_synaxis_error" });
                    console.log('LoaderStack execution time = ' + (new Date().getTime() - start));
                    page.loaded.connect(function(){
                        console.log("loaded handler four_synaxis_error "+page);
                    });
                    page.input.connect(function(data){
                        console.log("input handler four_synaxis_erro r"+JSON.stringify(data));
                        page.unLoad();
                    });
                    page.unLoaded.connect(function(){
                        console.log("unLoaded handler four_synaxis_error "+page);
                    });
                    page.error.connect(function(){
                        console.log("error handler four_synaxis_error "+page);
                        start = new Date().getTime();
                        page = loaderstack.setSource("notexist.qml", { "color": "brown", "objectName":"three_notexist_file" });
                        console.log('LoaderStack execution time = ' + (new Date().getTime() - start));
                        page.error.connect(function(){
                            console.log("error handler "+page);
                        });
                        page.unLoaded.connect(function(){
                            console.log("unLoaded handler notexist_file "+page);
                            start = new Date().getTime();
                            try{
                                page = loaderstack.setSource(null, { "color": "brown", "objectName":"three_null_source" });
                            }catch(e){
                                console.log("exception handler "+e);
                                start = new Date().getTime();
                                page = loaderstack.setSource(appUrl, { "color": "orange", "objectName":"three" });
                                console.log('LoaderStack execution time = ' + (new Date().getTime() - start));
                                page.loaded.connect(function(){
                                    console.log("loaded handler "+page);
                                });
                                page.input.connect(function(data){
                                    console.log("input handler "+JSON.stringify(data));
                                    page.unLoad();
                                });
                                page.unLoaded.connect(function(){
                                    console.log("unLoaded handler "+page);
                                });
                            }
                        });
                    });
                });
            });
        });
*/
    } // Component.onCompleted
}
