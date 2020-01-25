import {Component, OnInit, OnDestroy} from "@angular/core"
import { Router,ActivatedRoute, NavigationExtras } from "@angular/router";
import { Page } from "ui/page";

import {Camera} from "../shared/camera/camera.model"
import {CameraService} from "../shared/camera/camera.service"
import { Config } from "../shared/config"

import { registerElement } from "nativescript-angular/element-registry";
registerElement("VideoPlayer", () => require("../videoplayer").Video);

import { isAndroid, isIOS } from "tns-core-modules/platform";

import * as dialogs from "tns-core-modules/ui/dialogs";

import { Cscreenshot } from 'nativescript-cscreenshot';
import { ImageSource } from "tns-core-modules/image-source";
import * as fs from "tns-core-modules/file-system";

import * as permissions from 'nativescript-permissions'
import { UserService } from "./../shared/user/user.service";


declare var android: any;


@Component({
    selector: "ns-monitor",
    moduleId: module.id,
    providers:[CameraService, UserService],
    templateUrl: "./monitor.component.html",
    styleUrls: ["./monitor.component.css"]
})
export class MonitorComponent implements OnInit, OnDestroy{
    private _paramSubscription: any
    usrid:String
    devids:String
    items: Array<Camera>
    item:Camera
    videoPlayer: any
    constructor(private router: Router,
                private cameraService:CameraService,
                private activatedRoute:ActivatedRoute,
                private userService:UserService,
                private page:Page){
            
        this.items=[]
        this._paramSubscription=this.activatedRoute.params.subscribe(params=>{
            this.usrid=params['usrid']
            this.devids=params['devids']
        })
        this.devids.split(",").forEach(devid=>{
            console.log(devid)
            this.getCameraDetail(devid)
        })
    }

    ngOnInit(){

        this.checkAuth()

       // this.page.actionBarHidden = true;;
       permissions.requestPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE, "Permiso requerido para almacenar las fotos que se tomen")
        .then( () => {
            console.log("Woo Hoo, I have the power!! TO WRITE");
        })
        .catch( () => {
            console.log("Uh oh, no permissions - plan B time! ");
        });
    }

    ngOnDestroy(){
        if (this._paramSubscription) {
            this._paramSubscription.unsubscribe();
        };
      }

    getCameraDetail(devid:String){
        this.cameraService.getCameraDetail(devid)
        .subscribe(
            (data) => {
                this.item = <Camera>data
                this.item.url = Config.videoApiUrl+"/"+this.item.kafkaTopic+"/"+this.usrid
                this.items.push(<Camera>data)
            },
            (exception) => {
                if(exception.error && exception.error.description) {
                    alert(exception.error.description);
                } else {
                    alert(exception)
                }
            }
        )
    }

    showItem(webargs,itemId) {
        const webview = webargs.object
        webview.src = "<!DOCTYPE html><html><head><meta charset='utf-8' /></head><body></body></html>"
        const selItem:Camera = this.items.filter(item=>item._id==itemId)[0]
        console.log("El seleccionado"+selItem.url)
        const navigationExtras: NavigationExtras = {
            queryParams: {
                "url": selItem.url,
                "address": selItem.address,
                "zone": selItem.zone,
                "id":selItem._id
            }}
        this.router.navigate(["detail/"],navigationExtras)
    }

    
    ngAfterViewInit() {
       // this.videoPlayer = this.page.getViewById('nativeVideoPlayer');
        console.log("View init")
    }

    

    onWebViewLoaded(webargs,itemId) {
        console.log("load finished viewport")
        const selItem:Camera = this.items.filter(item=>item._id==itemId)[0]
        const webview = webargs.object
        webview.src = selItem.url
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
                this.userService.logOut()
                .subscribe(
                    ()=>{
                        this.router.navigate([""])
                    },
                    (exception)=>{
                        if(exception.error && exception.error.description) {
                            alert(exception.error.description);
                        } else {
                            alert(exception)
                        }
                    }
                )
            }
            
        });
    }

    checkAuth(){
        this.userService.checkLogged()
        .subscribe(
            ()=>{},
            (exception)=>{
                this.router.navigate([""])
            }
        )
    }

    takePicture(itemId){
        if(!permissions.hasPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)){
            dialogs.alert("La App no tiene permisos para guardar instantaneas. Brinde los permisos a la App en la configuración del dispositivo e intente de nuevo.").then(()=> {
                console.log("Dialog closed!")
            })
            
        }
        console.log("Take Picture")
        let view = this.page.getViewById(itemId)
        let screen = new Cscreenshot()
        screen.take(view, (image: ImageSource)=>{
            const folderDest = android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_PICTURES).toString();
            const pathDest = fs.path.join(folderDest, "image_"+new Date().toUTCString()+".png");
            if(!fs.File.exists(folderDest)){
                console.log("folder no exist")
                fs.Folder.fromPath(folderDest)
            }
            console.log(pathDest);
            const saved: boolean = image.saveToFile(pathDest, "png")
            if (saved) {
                console.log("Image saved successfully!")
            }
        })
    }

    categoryIcon(iconCategory) {
        switch (iconCategory) {
            case "Picture":
                return String.fromCharCode(0xf030) //f030"fa-camera f0f5
                break
            
            default:
                return String.fromCharCode(0xf06d) //"fa-fire"
                break
        }
    }

    closeWebviews(){
     //   const webview = webargs.object
     //   webview.src = "<!DOCTYPE html><html><head><meta charset='utf-8' /></head><body></body></html>"
    }
    
}