/*global Qt, WorkerScript */
/*jslint browser: true, white: true, bitwise: true, evil: true, devel: true, plusplus: true, continue: true */
WorkerScript.onMessage = function(data) {
    WorkerScript.sendMessage(data);
};
function include(path) {
    Qt.include(path, function(data){
        console.debug("include script: "+path+" status="+data.status);
    });
}
