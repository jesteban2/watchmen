const mongoose = require('mongoose')

const messageSchema = mongoose.Schema({
    type: {
        type: String,
        required: true,
        trim: true
    },
    date: {
        type: Date,
        required: true
    },
    sender_id: {
        type: String,
        required: true,
        trim: true
    },
    sender_name: {
        type: String,
        required: true,
        trim: true
    },
    value: {
        type: String,
        required: true
    }
    
})

const Message = mongoose.model('Message', messageSchema)

module.exports = Message