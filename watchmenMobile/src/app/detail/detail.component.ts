import {Component, OnInit, OnDestroy,ViewChild, ElementRef} from "@angular/core"
import { switchMap } from "rxjs/operators";

import { Page } from "ui/page";
import { Router,ActivatedRoute } from "@angular/router";

import { isAndroid, isIOS } from "tns-core-modules/platform";
import * as dialogs from "tns-core-modules/ui/dialogs";

import { Cscreenshot } from 'nativescript-cscreenshot';
import { ImageSource } from "tns-core-modules/image-source";
import * as fs from "tns-core-modules/file-system";

import * as permissions from 'nativescript-permissions'

declare var android: any;

require('nativescript-orientation')

@Component({
    selector: "ns-detail",
    moduleId: module.id,
    providers:[],
    templateUrl: "./detail.components.html",
    styleUrls: ["./detail.component.css"]
})

export class DetailComponent implements OnInit, OnDestroy{
    videoId: String
    videoUrl: String
    address: String
    zone: String
    private _paramSubscription:any

    constructor(private page: Page, 
                private router: Router,
                private activatedRoute:ActivatedRoute){
        
        this.activatedRoute.queryParams.subscribe(params=>{
            this.videoUrl=params['url']
            this.address=params['address']
            this.zone=params['zone']
            this.videoId=params['id']
        })

    }
    ngOnInit(): void{
        //this.page.actionBarHidden=true
    }

    ngOnDestroy(){
        if (this._paramSubscription) {
            this._paramSubscription.unsubscribe();
        };
      }
    
      onNavBtnTap(){
          console.log("nav atras")
          this.page.frame.goBack()
      }

        onMjpegViewLoaded(webargs) {
            console.log("Hombre hubo loaded")
            const mjpegview = webargs.object
            mjpegview.startStream()
        }

        onMjpegViewUnloaded(webargs) {
            console.log("Hombre hubo unloaded")
            const mjpegview = webargs.object
            mjpegview.stopStream()
        }

      onLoadFinished(webargs) {
        console.log("load finished viewport")
        const webview = webargs.object
        if(isAndroid){
            webview.android.getSettings().setUseWideViewPort(true)
            webview.android.getSettings().setLoadWithOverviewMode(true)
            webview.android.getSettings().setDisplayZoomControls(false)
        }else if(isIOS){
            webview.ios.scrollView.minimumZoomScale = 1.0;
            webview.ios.scrollView.maximumZoomScale = 1.0;
            webview.ios.scalesPageToFit = true;
        }
    }

    logOut(){
        dialogs.confirm({
            title: "Cerrar sessión",
            message: "Está seguro de cerrar sesión",
            okButtonText: "Cerrar sesión",
            cancelButtonText: "Cancelar"
        }).then(result => {
            if(result){
                //cerrar sesión
            }
            console.log("Dialog result: " + result);
        });
    }

    takePicture(video_id){
        if(!permissions.hasPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)){
            dialogs.alert("La App no tiene permisos para guardar instantaneas. Brinde los permisos a la App en la configuración del dispositivo e intente de nuevo.").then(()=> {
                console.log("Dialog closed!")
            })
            
        }
        console.log("Take Picture")
        let view = this.page.getViewById(video_id)
        let screen = new Cscreenshot()
        screen.take(view, (image: ImageSource)=>{
            const folderDest = android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_PICTURES).toString();
            const pathDest = fs.path.join(folderDest, "image_"+new Date().toUTCString()+".png")
            if(!fs.File.exists(folderDest)){
                console.log("folder no exist")
                fs.Folder.fromPath(folderDest);
            }
            console.log(pathDest);
            const saved: boolean = image.saveToFile(pathDest, "png")
            if (saved) {
                dialogs.alert("Instantánea almacenada en galeria de fotos").then(()=> {
                    console.log("Image saved successfully!")
                })
            }
        });
    }

    categoryIcon(iconCategory) {
        switch (iconCategory) {
            case "Picture":
                console.log("icon camera")
                return String.fromCharCode(0xf030) //f030"fa-camera f0f5
                break
            
            default:
                return String.fromCharCode(0xf06d) //"fa-fire";
                break
        }
    }

}
