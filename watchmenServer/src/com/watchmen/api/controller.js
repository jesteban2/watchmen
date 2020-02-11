'use strict'

const video = require('../services/video/service/video')
const videoStream = require('../services/video/service/videoStream')
const videoffmpeg = require('../services/video/service/videoffmpeg')
const user = require('../services/user/service/user') 
const device = require('../services/device/service/device')
const group = require('../services/group/service/group')
const userDevice = require('../services/userDevice/service/userDevice')
const message = require('../services/message/service/message')

const controllers = {

    playVideo: function(req,res){
        video.play(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    playVideoStream: function(req,res){
        videoStream.play(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    playVideoffmpeg: function(req,res){
        videoffmpeg.play(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    userCreate: function(req,res){
        user.create(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    userLogin: function(req,res){
        user.login(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    userLogged: function(req,res){
        user.logged(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    userLogout: function(req,res){
        user.logout(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    userLogoutAll: function(req,res){
        user.logoutAll(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    deviceCreate: function(req,res){
        device.create(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    deviceSearch: function(req,res){
        device.search(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    groupCreate: function(req,res){
        group.create(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    groupSearch: function(req,res){
        group.search(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    userDeviceCreate: function(req,res){
        userDevice.create(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    userDeviceSearch: function(req,res){
        userDevice.search(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    messagePost: function(req,res){
        message.post(req,res, function(err,stream){
            if(err){
                console.log("Este fue el error")
                res.send(err)}
        })
    },

    messageGet: function(req,res){
        message.get(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    }

}

module.exports = controllers