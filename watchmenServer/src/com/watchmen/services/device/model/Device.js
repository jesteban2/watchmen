const mongoose = require('mongoose')
const uuid = require('node-uuid')

const deviceSchema = mongoose.Schema({
    devid: {
        type: String,
        required: false,
        unique: true,
        trim: true
    },
    address: {
        type: String,
        required: true,
        trim: true
    },
    zone: {
        type: String,
        required: true,
        trim: true
    },
    city: {
        type: String,
        required: true,
        trim: true
    },
    url: {
        type: String,
        required: true,
        trim: true
    },
    kafkaTopic:{
        type:String,
        require: true,
        trim: true
    }
})

deviceSchema.pre('save', async function (next) {
    //Define uuid 
    const device = this
    if (device.isModified('devid')) {
        device.devid = uuid.v4()
    }
    next()
})

deviceSchema.statics.findDevice = async (devid) => {
    const device = await Device.findOne({devid})
    if (!device) {
        throw new Error({ error: 'Device not found' })
    }
    return device
}

const Device = mongoose.model('Device', deviceSchema)

module.exports = Device