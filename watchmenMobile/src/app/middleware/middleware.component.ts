import { Component, OnInit, OnDestroy } from "@angular/core";
import { Router, ActivatedRoute } from "@angular/router";
import { Page } from "tns-core-modules/ui/page";
import { alert } from "tns-core-modules/ui/dialogs";

import { UserCamera } from "../shared/camera/userCamera.model";
import { UserCameraService } from "./../shared/camera/userCamera.service";

@Component({
    selector: "ns-middleware",
    providers: [UserCameraService],
    templateUrl: "./middleware.component.html",
    styleUrls: ["./middleware.component.css"]
})
export class MiddlewareComponent implements OnInit, OnDestroy{
    private _paramSubscription: any
    usrid:String
    userCamera:UserCamera
  constructor(private router: Router,
              private userCameraService: UserCameraService, 
              private page:Page,
              private activatedRoute:ActivatedRoute) {}

  ngOnInit() {
    this.page.actionBarHidden = true;
    this._paramSubscription=this.activatedRoute.params.subscribe(params=>this.usrid=params['usrid'])
   // console.log("Usuario "+this.usrid)
    this.checkCameraEnabled()
  }

  onLoadFinished(){
    let options = {
        title: "Sin Autorización",
        message: "Aún no ha sido autorizado para acceder a las cámaras. Comuníquese con el administrador.",
        okButtonText: "OK"
    };
    
    alert(options).then(() => {
        console.log("Comuníquese con el administrador")
    });
  }
  
  
  checkCameraEnabled() {
    this.userCameraService.getCameras(this.usrid)
      .subscribe(
        (data) => {
            this.userCamera = <UserCamera>data
            this.router.navigate(["/monitor",this.usrid,this.userCamera.devices.join(",")])
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

  ngOnDestroy(){
    if (this._paramSubscription) {
        this._paramSubscription.unsubscribe();
    };
  }
}

