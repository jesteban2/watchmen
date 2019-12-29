import { Injectable } from "@angular/core";
import { HttpClient, HttpHeaders, HttpResponse } from "@angular/common/http";
import { Observable, throwError, from } from "rxjs";
import { catchError, map, tap } from "rxjs/operators";

import { User } from "../user/user.model";
import { Camera } from "./camera.model";
import { Config } from "../config";
import { UserCameraService} from "./userCamera.service"

@Injectable()
export class ResourceManager {
    constructor(private http: HttpClient) { }

    getCameras(user:User, camService:UserCameraService){
       
    }

    getCameraDetail(camera:Camera){

    }

}