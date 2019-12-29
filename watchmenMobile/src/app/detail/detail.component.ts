import {Component, OnInit, OnDestroy,ViewChild, ElementRef} from "@angular/core"
import { switchMap } from "rxjs/operators";

import { Page } from "ui/page";
import { Router,ActivatedRoute } from "@angular/router";

require('nativescript-orientation')

@Component({
    selector: "ns-detail",
    moduleId: module.id,
    providers:[],
    templateUrl: "./detail.components.html",
    styleUrls: ["./detail.component.css"]
})

export class DetailComponent implements OnInit, OnDestroy{
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
        })

    }
    ngOnInit(): void{
        this.page.actionBarHidden=true
    }

    ngOnDestroy(){
        if (this._paramSubscription) {
            this._paramSubscription.unsubscribe();
        };
      }

}
