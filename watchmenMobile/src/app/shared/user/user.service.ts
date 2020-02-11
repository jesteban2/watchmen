import { Injectable } from "@angular/core";
import { HttpClient, HttpHeaders, HttpResponse } from "@angular/common/http";
import { Observable, throwError } from "rxjs";
import { catchError, map, tap } from "rxjs/operators";

import { User } from "./user.model";
import { Config } from "../config";

@Injectable()
export class UserService {
    constructor(private http: HttpClient) { }

    getLoginHeaders() {
        return {
            "Content-Type": "application/json"
        }
    }

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

    login(user: User) {
        return this.http.post(
            Config.loginApiUrl,
            JSON.stringify({
                usrid: user.id,
                password: user.password
            }),
            { headers: this.getLoginHeaders() }
        ).pipe(
            map(response => response),
            tap(data => {
                Config.token = (<any>data).user.tokens[0].token
                Config.usrid = (<any>data).user.usrid
                Config.usrnam = (<any>data).user.name
                Config.groups = (<any>data).user.groups
            }),
            catchError(this.handleErrors)
        );
    }

    logOut(){
        return this.http.post(
            Config.logoutApiUrl,
            '',
            { headers: this.getCommonHeaders() }
        ).pipe(
            map(response => response),
            tap(data => {}),
            catchError(this.handleErrors)
        );
    }

    checkLogged(){
        return this.http.get(
            Config.checkLoggedApiUrl,
            { headers: this.getCommonHeaders() }
        ).pipe(
            map(response => response),
            tap(data => {}),
            catchError(this.handleErrors)
        );
    }


}