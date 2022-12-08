

## LoaderStack ##
Alternative of native QML component: Loader

### Changed behavior (diff to native Loader): ###
* Can load multiple QML components, each component live cycle driven by component self or JavaScript handler
* property 'asynchronous' always is true

### Added features:#####
* method 'setSource()' immediate return interface of component object.
* Addition events to 'loaded': error, input, unLoaded

### Short example: ###
```
LoaderStack {
    id: loaderstack
    anchors.fill: parent
    Component.onCompleted: {
        var screen = loaderstack.setSource("http://localhost:8000/someScreen.qml", { "someScreenProperty": "someScreenPropertyValue" });
        screen.loaded.connect( function(){
            console.log("handle screen loaded!");
        });
        screen.error.connect( function(stringError){
            console.log("handle screen error="+stringError);
        });
        screen.input.connect( function(data){
            console.log("handle screen input data="+JSON.stringify(data));
            screen.unLoad(); // unload screen
        });
        screen.unLoaded.connect( function(){
            console.log("handle screen unloded");
        });
    }
}
```

### dev branch 'LoaderStack': ###
`git clone https://github.com/reeshkov/qml.git && git switch LoaderStack`