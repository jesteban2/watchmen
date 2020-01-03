import * as app from 'application'

const API = app.android ? 'https://10.0.2.2:8443' : 'https://localhost:8443'

export class Config {
  


  static loginApiUrl = API+"/user/login";
  static token = "";
  static usrCamApiUrl = API+"/user-device/search";
  static cameraApiUrl = API+"/device/search";
  static videoApiUrl = API+"/stream";
}