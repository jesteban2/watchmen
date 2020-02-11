import { Component, OnInit } from "@angular/core";
import { User } from "./../shared/user/user.model";
import { UserService } from "./../shared/user/user.service";
import { Router } from "@angular/router";
import { Page } from "tns-core-modules/ui/page";


@Component({
    selector: "ns-login",
    providers: [UserService],
    templateUrl: "./login.component.html",
    styleUrls: ["./login.component.css"]
})
export class LoginComponent implements OnInit{
  user:User;
  constructor(private router: Router,private userService: UserService, private page:Page) {
    this.user = new User();
    this.user.id="8104624";
    this.user.password="watchmen1234*";
  }
  ngOnInit() {
    this.page.actionBarHidden = true;
  }
  submit() {
    this.login();
  }
  
  login() {
   // this.router.navigate(["/monitor",'8104624','abcde']);
    this.userService.login(this.user)
      .subscribe(
        (data) => {
          console.log("Retorno ws: "+(<any>data).user.groups[0])
          this.user.groups = (<any>data).user.groups
          this.router.navigate(["/monitor",this.user.id,this.user.groups.join(",")])
        },
        (exception) => {
            if(exception.error && exception.error.description) {
                alert(exception.error.description);
            } else {
                alert(exception)
            }
        }
      );
  }
}

