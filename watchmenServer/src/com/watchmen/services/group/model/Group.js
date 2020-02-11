const mongoose = require('mongoose')
const uuid = require('node-uuid')

const groupSchema = mongoose.Schema({
    groupid: {
        type: String,
        required: false,
        unique: true,
        trim: true
    },
    description: {
        type: String,
        required: true,
        trim: true
    },
    devices: [{
        type: String,
        required: true,
        trim: true
    }]
})

groupSchema.statics.findGroup = async (groupid) => {
    const group = await Group.findOne({groupid})
    if (!group) {
        throw new Error({ error: 'Group not found' })
    }
    return group
}

const Group = mongoose.model('Group', groupSchema)

module.exports = Group