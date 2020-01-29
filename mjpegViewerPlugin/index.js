var application = require("application");
var context = application.android.context;
 
module.exports = {
    showToast:function() {
        var toaster =new com.watchmen.mjpegviewer.MjpegView();
        toaster.show(context);
    }
};