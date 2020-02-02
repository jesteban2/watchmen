function __export(m) {
    for (var p in m) if (!exports.hasOwnProperty(p)) exports[p] = m[p];
}
Object.defineProperty(exports, "__esModule", { value: true });
var mjpeg_view_common_1 = require("./mjpeg-view-common");
__export(require("./mjpeg-view-common"));

var MjpegView = (function (_super) {
    __extends(MjpegView, _super);
    function MjpegView() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    MjpegView.prototype.createNativeView = function () {
        var nativeView = new com.watchmen.mjpegviewer.MjpegView(this._context);
        nativeView.setUrl("https://bma-itic1.iticfoundation.org/mjpeg2.php?camid=61.91.182.114:1112");
        return nativeView;
    };
    MjpegView.prototype.initNativeView = function () {
        _super.prototype.initNativeView.call(this);
        var nativeView = this.nativeViewProtected;
        nativeView.owner = this;
    };
    MjpegView.prototype.disposeNativeView = function () {
        var nativeView = this.nativeViewProtected;
        if (nativeView) {
            nativeView.destroy();
        }
        nativeView.owner = null;
        _super.prototype.disposeNativeView.call(this);
    };
    return MjpegView;
}(mjpeg_view_common_1.MjpegViewBase));
exports.MjpegView = MjpegView;