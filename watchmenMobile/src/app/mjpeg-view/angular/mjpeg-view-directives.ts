import { Directive } from "@angular/core"; // TODO: check require .Directive without hacks

@Directive({
    selector: "MjpegView"
})
export class MjpegViewDirective { }

export const DIRECTIVES = [MjpegViewDirective]