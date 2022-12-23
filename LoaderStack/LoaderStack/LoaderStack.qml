//! Extention of native QML component: Loader
/*!
  # Changed behavior: #
  \li Can load multiple QML components, each component live cycle driven by user code
  \li asynchronous always is true
  # Added features: #
   \li setSource() Immediate return interface of component object.
   \li Events of QML component object: loaded, error, input, unloaded
*/
//import QtQuick 1.1
import QtQuick 2.5

Item{
    id: loader
    /*!
    This property is true if the Loader is currently active. The default value for this property is true.
    If the Loader is inactive, changing the source or sourceComponent will not cause the item to be instantiated until the Loader is made active.
    Setting the value to inactive will cause any item loaded by the loader to be released, but will not affect the source or sourceComponent.
    The status of an inactive loader is always Null.
     */
    property bool active: true
    onActiveChanged: {
        if(!active){
            unLoadAll();
        }
    }

    /*!
    This property holds whether the component will be instantiated asynchronously. By default it is true.
    When used in conjunction with the source property, loading and compilation will also be performed in a background thread.
    Loading asynchronously creates the objects declared by the component across multiple frames, and reduces the likelihood of glitches in animation. When loading asynchronously the status will change to Loader.Loading. Once the entire component has been created, the item will be available and the status will change to Loader.Ready.
    Changing the value of this property to false while an asynchronous load is in progress will force immediate, synchronous completion. This allows beginning an asynchronous load and then forcing completion if the Loader content must be accessed before the asynchronous load has completed.
    To avoid seeing the items loading progressively set visible appropriately, e.g.
    */
    property bool asynchronous: true // TODO
    onAsynchronousChanged: asynchronous = true; // FIXME
    /*!
    This property holds the top-level object that is currently loaded.
    */
    property var item: null

    /*!
    This property holds the progress of loading QML data from the network, from 0.0 (nothing loaded) to 1.0 (finished). Most QML files are quite small, so this value will rapidly change from 0 to 1.
    */
    property real progress: 0.0 // TODO

    /*!
    This property holds the top-level object`s source that is currently loaded.
    Since QtQuick 2.0, Loader is able to load any type of object; it is not restricted to Item types.
    */
    property string source: ""

    /*!
    This property holds the Component to instantiate.
    To unload the currently loaded object, set this property to undefined.
    */
    property var sourceComponent: null // TODO

    /*!
    This property holds the status of QML loading. It can be one of:
        Loader.Null - the loader is inactive or no QML source has been set
        Loader.Ready - the QML source has been loaded
        Loader.Loading - the QML source is currently being loaded
        Loader.Error - an error occurred while loading the QML source
    */
    property int status: Loader.Null

    /*!
    This signal is emitted when the status becomes Loader.Ready, or on successful initial load.
    Note: The corresponding handler is onLoaded.
    */
    signal loaded()


    /*!
    This property holds length of stack
    0 - unlimited
    more than 1 - next overflow loading destroy oldest item in the stack
    */
    property int maximumStackLength: 0

    onChildrenChanged: {
        var items = Array.prototype.filter.call(loader.children, function(o){ return o.hasOwnProperty("unLoad") && 'function' === typeof o.unLoad; }),
        len = items.length,
        overflow = 0 < loader.maximumStackLength && loader.maximumStackLength < len;
        //console.log("loader onChildrenChanged overflow="+overflow+" loader.maximumStackLength="+loader.maximumStackLength+" loader.children.length="+loader.children.length);
        if(overflow){
            items[0].unLoad();
            return;
        }
        if(0 < len){
            loader.item = items[len-1];
        }else{
            loader.item = null;
            loader.status = Loader.Null;
            loader.source = "";
        }
    }

    Component {
        id: component
        Item{
//        QtObject{
            id: componentInterface
            width: loader.width
            height: loader.height

            property string source: ""
            property variant properties: ({})
            // extended interface:
            signal loaded(variant item)  // Page loaded
            signal error(string error_string) // Page error or not loaded
            signal unLoaded() // Page unloaded
            signal input(variant data) // Data from page i.e. user input

            onLoaded: {
                loader.loaded();
            }
            onError: {
                componentInterface.unLoad(); // unload object if error
            }

            function load(){
                var source = componentInterface.source, properties = componentInterface.properties,
                    pageFabric = Qt.createComponent(componentInterface.source), // QtQuick 1.1 Qt4
                    //pageFabric = Qt.createComponent(componentInterface.source,Component.Asynchronous, component), // QtQuick 2.x Qt5
                    finishCreation = function () {
                        loader.status = pageFabric.status;
                        var object;
                        if (Component.Ready === pageFabric.status ) {
                            try{
                                object = pageFabric.createObject(componentInterface, properties);
                                //console.log("componentInterface loaded "+object.width+"x"+object.height/*+obj2str(object, "object")*/);
                                loader.source = source;
                                componentInterface.loaded(object);
                            }catch(e){
                                console.log("componentInterface error "+e);
                                componentInterface.error("Error page.createObject: "+e);
                            }
                        } else if (Component.Error === pageFabric.status) {
                            console.log("componentInterface error "+pageFabric.errorString());
                            componentInterface.error("Qt.createComponent: "+pageFabric.errorString());
                        }else if (Component.Null === pageFabric.status) {
                            console.log("componentInterface error "+pageFabric.errorString());
                            componentInterface.error("no data is available for the component");
                        }else{
                            return;
                        }
                        if(finishCreation.connectFlag){
                            pageFabric.statusChanged.disconnect(finishCreation);
                            delete finishCreation.connectFlag;
                        }
                    };
                if (pageFabric.status === Component.Loading){
                    finishCreation.connectFlag = true;
                    pageFabric.statusChanged.connect(finishCreation);
                }else{
                    finishCreation();
                }
            }
            function unLoad(handler){
                if("function"===typeof handler){
                    var handlerWrapper = function(){
                        componentInterface.unLoaded.disconnect(handlerWrapper);
                        handler();
                    };
                    componentInterface.unLoaded.connect(handlerWrapper);
                }
                componentInterface.destroy();
            }
            WorkerScript {
                id: loadAsync
                source: "LoaderStack.qml.js"
                onMessage: {
                    load();
                }
            }
            Component.onCompleted: {
                loadAsync.sendMessage();
            }
            Component.onDestruction: {
                componentInterface.unLoaded();
            }
            onChildrenChanged: {
                //console.log("componentInterface onChildrenChanged "+componentInterface.children.length);
                if(0 >= componentInterface.children.length){ // handle self destroyed component
                    componentInterface.unLoad();
                }
            }
        }
    }

    /*! Creates an object instance of the given source component that will have the given properties. The properties argument is optional. The instance will be accessible via the item property once loading and instantiation is complete.
    If the active property is false at the time when this function is called, the given source component will not be loaded but the source and initial properties will be cached. When the loader is made active, an instance of the source component will be created with the initial properties set.
    Setting the initial property values of an instance of a component in this manner will not trigger any associated Behaviors.
    Note that the cached properties will be cleared if the source or sourceComponent is changed after calling this function but prior to setting the loader active.
    @param source the URL of the QML component to instantiate.
    @param properties argument is specified as a map of property-value items which will be set on the created object during its construction.
    @return load interface
    */
    function setSource(source, properties){
        if(active){
            if("string"===typeof source && ""!=source){
                var page = {}, object;
                if(properties) { page.properties = properties; }
                else { page.properties = {"width": loader.width, "height": loader.height}; }
                page.source = source;
                console.log("LoaderStack.qml component.createObject: "+JSON.stringify(page));
                return component.createObject(loader, page);
            }else{
                //throw new TypeError("wrong argument: source", "LoaderStack.qml", 168);
                console.log("LoaderStack.qml setSource wrong argument: source. "+JSON.stringify(Array.prototype.slice.call(arguments)));
                return null;
            }
        }
    }

    WorkerScript {
        id: unLoadAsync
        source: "LoaderStack.qml.js"
        onMessage: {
            console.log("LoaderStack.qml unLoadAll()" );
            var handler = function(){};
            Array.prototype.filter.call(loader.children, function(o){
                if( o.hasOwnProperty("unLoad") && 'function' === typeof o.unLoad ){
                    console.log("LoaderStack.qml unLoad: "+o);
                    o.unLoad();
                }
                return false;
            });
            if("function"===typeof unLoadAll.handler){
                handler = unLoadAll.handler;
                delete unLoadAll.handler;
                handler();
            }
            //qml.clearCache();
        }
    }
    function unLoadAll(handler){
        if("function"===typeof handler){
            unLoadAll.handler = handler;
        }
        unLoadAsync.sendMessage({});
    }


// VVVVVVVVVV debug VVVVVVVVVV
//    Component.onCompleted: {
//    }
    function obj2str(obj, name) {
        var result = "",
            i;
        if (undefined === name) {
            name = typeof obj;
        }

        if (!(obj2str.hasOwnProperty('maxcount'))) {
            obj2str.maxcount = 0;
        } else {
            if (100 < obj2str.maxcount) {
                return name + "\n";
            }
            obj2str.maxcount++;
        }
        switch (typeof obj) {
        case "object":
            result += name + " is " + (typeof obj) + (obj.hasOwnProperty('length')?" length="+obj.length:"") +"\n";
            for (i in obj) {
                try {
                    if (obj !== obj[i] && name.slice(-1 * i.length) !== i && 2 > name.split('.').length) {
                        result += obj2str(obj[i], name + "." + i);
                    } else {
                        result += name + "." + i + " is " + (typeof obj[i]) + " = " + String(obj[i]) + "\n";
                    }
                } catch (e) {
                    result += name + "." + i + " (" + e + ")\n";
                }
            }
            break;
        case "function":
            if (null !== obj) {
                result += name + " is " + (typeof obj) + "\n";
                Object.getOwnPropertyNames(obj).forEach(function (i, idx, array) {
                    try {
                        if (obj !== obj[i] && name.slice(-1 * i.length) !== i && 2 > name.split('.').length) {
                            result += obj2str(obj[i], name + "." + i);
                        } else {
                            result += name + "." + i + " is " + (typeof obj[i]) + " = " + String(obj[i]) + "\n";
                        }
                    } catch (e) {
                        result += name + "." + i + " (" + e + ")\n";
                    }
                });
            } else {
                result += "null";
            }
            break;
        default:
            result += name + " is " + (typeof obj) + " = " + String(obj) + "\n";
            break;
        }

        //obj2str.maxcount--;
        return result;
    }
}
