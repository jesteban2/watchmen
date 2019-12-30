const express = require('express')
const https = require('https')
const fs = require('fs')
const dotenv = require('dotenv').config()
const port = process.env.PORT || 3000
const routes = require('./src/com/watchmen/api/routes')
require('./src/com/watchmen/db/db')


const app = express()
app.use(express.json())
app.use(routes)

https.createServer({
    key: fs.readFileSync('./server_dev.key'),
    cert: fs.readFileSync('./server_dev.crt')
},app).listen(port, () => {
    console.log(`Server running on port ${port}`)
})