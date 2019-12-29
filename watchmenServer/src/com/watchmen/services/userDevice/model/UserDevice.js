const mongoose = require('mongoose')

const usrDevSchema = mongoose.Schema({
    usrid: {
        type: String,
        required: true,
        unique: true,
        trim: true
    },
    devices: [{
        type: String,
        required: true,
        trim: true
    }]
})


usrDevSchema.statics.findUserDevice = async (usrid) => {
    // Search for devices by user
    const userDevice = await UserDevice.findOne({usrid})
    if (!userDevice) {
        throw new Error({ error: 'Devices for user not found' })
    }
    return userDevice
}

const UserDevice = mongoose.model('UserDevice', usrDevSchema)

module.exports = UserDevice