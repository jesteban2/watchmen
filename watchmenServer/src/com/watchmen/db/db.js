const mongoose = require('mongoose')

mongoose.connect(process.env.MONGODB_URL_OLD, {
    useNewUrlParser: true,
    useCreateIndex: true,
    useUnifiedTopology: true
})