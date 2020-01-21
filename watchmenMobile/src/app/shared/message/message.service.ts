import { Injectable, NgZone } from "@angular/core";
import { HttpClient, HttpHeaders, HttpResponse } from "@angular/common/http";
import { throwError, BehaviorSubject } from "rxjs";
import { catchError, map, tap } from "rxjs/operators";


import { Config } from "../config";
import { Message } from "./message.model";

@Injectable()
export class MessageService {
    constructor(private http: HttpClient, private ngZone:NgZone) { }

    chats: BehaviorSubject<Array<Message>> = new BehaviorSubject([]);
    private _allChats: Array<Message> = [];


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

    sendMessage(usrid:String,msg: Message) {
        return this.http.post(
            Config.messageApiUrl+"/"+usrid,
            JSON.stringify({
                type: msg.type,
                date: msg.date,
                sender_id: msg.sender_id,
                sender_name: msg.sender_name,
                value: msg.value
            }),
            { headers: this.getCommonHeaders() }
        ).pipe(
            map(response => response),
            tap(data => {}),
            catchError(this.handleErrors)
        );
    }

    getMessages(usrid:String){
        return this.http.get(
            Config.messageApiUrl+"/"+usrid,
            { headers: this.getCommonHeaders() }
        ).pipe(
            map(response => response),
            tap(data => {}),
            catchError(this.handleErrors)
        );
    }
}