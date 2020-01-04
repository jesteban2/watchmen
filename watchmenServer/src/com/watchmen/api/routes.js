'use strict'

const controller = require('./controller')
const auth = require('../services/user/service/auth')
const express = require('express')

const router = express.Router()

router.get('/',(req,res)=>{res.send("Hello")})

router.get('/stream'+'/:topic'+'/:usrid',controller.playVideo)

router.get('/stream/video',controller.playVideoStream)

router.get('/stream/ffmpeg',controller.playVideoffmpeg)

router.post('/user/create',controller.userCreate)

router.post('/user/login',controller.userLogin)

router.get('/user/logged',auth,controller.userLogged)

router.post('/user/logout',auth,controller.userLogout)

router.post('/user/logoutAll',auth,controller.userLogoutAll)

router.post('/device/create',auth,controller.deviceCreate)

router.get('/device/search'+'/:devid',auth,controller.deviceSearch)

router.post('/user-device/create',auth,controller.userDeviceCreate)

router.get('/user-device/search'+'/:usrid',auth,controller.userDeviceSearch)

module.exports = router