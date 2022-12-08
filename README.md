# my QML component

## LoaderStack
Extention of native QML component: Loader
### Changed behavior (diff to native Loader): ##
* Can load multiple QML components, each component live cycle driven by component self or JavaScript handler
* property 'asynchronous' always is true
### Added features: ##
* method 'setSource()' immediate return interface of component object.
* Addition events to 'loaded': error, input, unLoaded

### Example:
How to use see in LoaderStack/example/main.qml

### Run Demo:
1. Start server for loading components:

    $cd LoaderStack/example/test-server && python2 ./server.py
2. Build project & run example