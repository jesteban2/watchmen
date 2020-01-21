import{Component, OnInit, OnDestroy} from "@angular/core";
import { ListView } from 'ui/list-view';
import { TextField } from 'ui/text-field';
import { ScrollView } from 'ui/scroll-view';
import { Message } from "./../shared/message/message.model";
import { MessageService } from "./../shared/message/message.service";
import { Router } from "@angular/router";
import { Page } from "tns-core-modules/ui/page";
import { Config } from "../shared/config";


import { Observable, of, interval, from } from "rxjs";
import { take, takeWhile } from "rxjs/operators"

var inter = interval(3000)


@Component({
    moduleId: module.id,
    selector: "ns-chat",
    providers:[MessageService],
    templateUrl: "chat.component.html",
    styleUrls: ["chat.component.css"]
})
export class ChatComponent implements OnInit, OnDestroy{
    private _pollSubscription: any
    message:Message
    list: ListView
    textfield: TextField
    chats:Array<Message>
    poll: Boolean

    constructor(private router: Router,private messageService: MessageService, private page:Page) {
        this.chats=[]
    }

    ngOnInit(){
    }

    ngOnDestroy(){
        console.log("Se limpia el intervalo")
        if(this._pollSubscription){
            this._pollSubscription.unsubscribe()
        }
    }

    ngAfterViewInit(){
        this.list = this.page.getViewById("list")
        this.textfield = this.page.getViewById("textfield")
        this.getChats()
        
    }

    scroll(count:number){
        console.log("scrolling to ", count)
        this.list.scrollToIndex(count-1);
        this.list.refresh();
     }

     chat(msgtxt: string) {
        const message = new Message()
        message.type = "text"
        message.date = new Date()
        message.sender_id = Config.usrid
        message.sender_name = Config.usrnam
        message.value = msgtxt 
        this.messageService.sendMessage(Config.usrid,message)
        .subscribe(
            () => {
//                this.getChats()
            },
            (exception) => {
                if(exception.error && exception.error.description) {
                    alert(exception.error.description)
                } else {
                    alert(exception)
                }
            }
          )
        this.textfield.text = ''
    }

    getChats(){
        this._pollSubscription = inter.pipe(take(31536000))
        .subscribe((x)=>{
            console.log("****CONSULTA KAFKA NUMERO: "+x)
            let messages:Array<Message>
            this.messageService.getMessages(Config.usrid)
            .subscribe(
                (data) => {
                    console.log("data: "+data)
                    messages = <any>data
                    messages.forEach(element => {
                        
                        this.pushChat(<Message>(JSON.parse(<any>element)))
                        
                    })
                    let count = this.list.items.length
                    this.scroll(count)
                },
                (exception) => {
                    if(exception.error && exception.error.description) {
                        alert(exception.error.description)
                    } else {
                        alert(exception)
                    }
                }
            )
        })    
          
    }

    pushChat(msg: Message){
        console.log("Mensaje: "+msg)
        this.chats.push(msg)
    }

    filter(sender) {
        if (sender == Config.usrid) {
            return "me"
        }
        else {
            return "them"
        }
    }

    align(sender) {
        if (sender == Config.usrid) {
            return "right"
        }
        else {
            return "left"
        }
    }
    showImage(sender) {
        if (sender == Config.usrid) {
            return "collapsed"
        }
        else {
            return "visible"
        }
    }
}