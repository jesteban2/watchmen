import { View, Property, EventData } from "tns-core-modules/ui/core/view";

/**
 * Represents the observable property backing the Url property of each WebView instance.
 */
//export const urlProperty: Property<MjpegView, string>;

/**
 * Represents a standard WebView widget.
 */

 
export class MjpegView extends View {

    android: any 

    ios: any 
    
    src: string;

    setUrl(url:string):void;

    startStream(): void;

    stopStream(): void;

    isStreaming(): boolean;

    isShown(): boolean;

     
}
