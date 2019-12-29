const Device = require('../model/Device')

const device = {

    create: async function(req,res,next){
        try {
            const device = new Device(req.body)
            await device.save()
            res.status(201).send({ device })
        } catch (error) {
            res.status(400).send(error)
        }
    },

    search: async function(req,res,next){
        try {
            const devid = req.params.devid
            const device = await Device.findDevice(devid)
            if (!device) {
                throw new Error()
            }
            req.device = device
        } catch (error) {
            res.status(401).send({ error: 'Devices not found' })
        }
        res.send(req.device)
    }
}

module.exports = device