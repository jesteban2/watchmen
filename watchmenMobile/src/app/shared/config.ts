import * as app from 'application'

//const API = app.android ? 'https://10.0.2.2:8443' : 'https://localhost:8443'////
//const API = 'http://192.168.1.128:3000'
const API = 'http://ec2-18-234-227-124.compute-1.amazonaws.com:3000'

export class Config {
  static loginApiUrl = API+"/user/login";
  static logoutApiUrl = API+"/user/logoutAll";
  static checkLoggedApiUrl = API+"/user/logged";
  static usrCamApiUrl = API+"/user-device/search";
  static cameraApiUrl = API+"/device/search";
  static groupApiUrl = API+"/group/search";
  static videoApiUrl = API+"/stream";
  static messageApiUrl = API+"/message";
  static usrid = "";
  static usrnam = "";
  static token = "";
  static groups = "";
  static group = "";
}