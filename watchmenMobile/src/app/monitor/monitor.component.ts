import {Component, OnInit, OnDestroy, ViewChild, ElementRef} from "@angular/core"
import { Router,ActivatedRoute, NavigationExtras } from "@angular/router";
import { Page } from "ui/page";

import {Camera} from "../shared/camera/camera.model"
import {CameraService} from "../shared/camera/camera.service"
import { Config } from "../shared/config"

import { registerElement } from "nativescript-angular/element-registry";
registerElement("VideoPlayer", () => require("../videoplayer").Video);



@Component({
    selector: "ns-monitor",
    moduleId: module.id,
    providers:[CameraService],
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
       /* this.item = new Camera()
        this.item._id="1"
        this.item.url='https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4'
        this.items.push(this.item)

        this.item._id="2"
        this.item.url='https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4'
        this.items.push(this.item)

        this.item._id="3"
        this.item.url='https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4'
        this.items.push(this.item)

        this.item._id="4"
        this.item.url='https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4'
        this.items.push(this.item)

        this.item._id="5"
        this.item.url='https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4'
        this.items.push(this.item)*/

    }

    ngOnInit(){
        this.page.actionBarHidden = true;
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

    showItem(itemId) {
        let selItem:Camera = this.items.filter(item=>item._id==itemId)[0]
        console.log("El seleccionado"+selItem.url)
        let navigationExtras: NavigationExtras = {
            queryParams: {
                "url": selItem.url,
                "address": selItem.address,
                "zone": selItem.zone
            }}
        this.router.navigate(["detail/"],navigationExtras)
    }

    ngAfterViewInit() {
        this.videoPlayer = this.page.getViewById('nativeVideoPlayer');
    }

    play() {
        this.videoPlayer.play();
    }

    pause() {
        this.videoPlayer.pause();
    }

    seekToTime() {
        this.videoPlayer.seekToTime(30);
    }
    
}