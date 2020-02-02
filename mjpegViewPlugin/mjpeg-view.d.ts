import { View, Property, EventData } from "tns-core-modules/ui/core/view";

/**
 * Represents the observable property backing the Url property of each WebView instance.
 */
//export const urlProperty: Property<MjpegView, string>;

/**
 * Represents a standard WebView widget.
 */
export class MjpegView extends View {
    /**
     * Gets the native [android widget](http://developer.android.com/reference/android/webkit/WebView.html) that represents the user interface for this component. Valid only when running on Android OS.
     */
    android: any /* android.webkit.WebView */;

    /**
     * Gets the native [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview/) that represents the user interface for this component. Valid only when running on iOS.
     */
    ios: any /* WKWebView */;

    /**
     * Gets or sets the url, local file path or HTML string.
     */
    src: string;
}