const UserDevice = require('../model/UserDevice')

const userDevice = {

    create: async function(req,res,next){
        try {
            const userDevice = new UserDevice(req.body)
            await userDevice.save()
            res.status(201).send({ userDevice })
        } catch (error) {
            res.status(400).send(error)
        }
    },

    search: async function(req,res,next){
        try {
            const usrid = req.params.usrid
            const userDevice = await UserDevice.findUserDevice(usrid)
            if (!userDevice) {
                throw new Error()
            }
            req.userDevice = userDevice
        } catch (error) {
            res.status(401).send({ error: 'Devices not found for user' })
        }
        res.send(req.userDevice)
    }
}

module.exports = userDevice