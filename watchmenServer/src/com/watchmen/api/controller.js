'use strict'

const video = require('../services/video/service/video')
const user = require('../services/user/service/user') 
const device = require('../services/device/service/device')
const userDevice = require('../services/userDevice/service/userDevice')

const controllers = {

    playVideo: function(req,res){
        video.play(req,res, function(err,stream){
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

    userDeviceCreate: function(req,res){
        userDevice.create(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    },

    userDeviceSearch: function(req,res){
        userDevice.search(req,res, function(err,stream){
            if(err){res.send(err)}
        })
    }

}

module.exports = controllers