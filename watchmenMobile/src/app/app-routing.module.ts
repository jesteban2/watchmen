import { NgModule } from "@angular/core";
import { NativeScriptRouterModule } from "nativescript-angular/router";
import { Routes } from "@angular/router";

import { LoginComponent } from "./login/login.Component";
import { MonitorComponent } from "./monitor/monitor.Component";
import { DetailComponent } from "./detail/detail.component";
import { MiddlewareComponent } from "./middleware/middleware.component";

const routes: Routes = [
   // { path: "", redirectTo: "/login", pathMatch: "full" },
   // { path: "login", component: LoginComponent }
   {path: "", component: LoginComponent},
   {path: "middleware/:usrid", component: MiddlewareComponent},
   {path: "monitor/:usrid/:devids", component: MonitorComponent},
   {path: "detail", component: DetailComponent }
];



@NgModule({
    imports: [NativeScriptRouterModule.forRoot(routes)],
    exports: [NativeScriptRouterModule]
})
export class AppRoutingModule { }
