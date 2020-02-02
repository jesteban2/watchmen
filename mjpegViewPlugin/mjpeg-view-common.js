function __export(m) {
    for (var p in m) if (!exports.hasOwnProperty(p)) exports[p] = m[p];
}
Object.defineProperty(exports, "__esModule", { value: true });
var view_1 = require("tns-core-modules/ui/core/view");
__export(require("tns-core-modules/ui/core/view"));
exports.srcProperty = new view_1.Property({ name: "src" });
var MjpegViewBase = (function (_super) {
    __extends(MjpegViewBase, _super);
    function MjpegViewBase() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    MjpegViewBase_1 = MjpegViewBase;
    MjpegViewBase.prototype.recycleNativeView = false; 
    return MjpegViewBase;
}(view_1.ContainerView));
exports.MjpegViewBase = MjpegViewBase;
exports.srcProperty.register(MjpegViewBase);
