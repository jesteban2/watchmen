import { Injectable } from "@angular/core";
import { HttpClient, HttpHeaders, HttpResponse } from "@angular/common/http";
import { Observable, throwError } from "rxjs";
import { catchError, map, tap } from "rxjs/operators";

import { Config } from "../config";

@Injectable()
export class UserCameraService {
    constructor(private http: HttpClient) { }

    getCommonHeaders() {
        return {
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Config.token
        }
    }

    handleErrors(error: Response) {
        console.log(JSON.stringify(error));
        return throwError(error);
    }

    getCameras(usrid:String){
        return this.http.get(
            Config.usrCamApiUrl+"/"+usrid,
            { headers: this.getCommonHeaders() }
        ).pipe(
            map(response => response),
            tap(data => {}),
            catchError(this.handleErrors)
        );
    }
}