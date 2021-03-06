const express = require('express')
const https = require('https')
const fs = require('fs')
const routes = require('./src/com/watchmen/api/routes')


const args = process.argv.slice(2)
let envDir = './config/dev/.env'
if(args[0]=='prd'){
    envDir = './config/prd/.env'
}

const dotenv = require('dotenv').config({path: envDir })
const port = process.env.PORT || 3000
require('./src/com/watchmen/db/db')

const app = express()
app.use(express.json())
app.use(routes)

/*https.createServer({
    key: fs.readFileSync('./server.key'),
    cert: fs.readFileSync('./server.crt')
},app).listen(port, () => {
    console.log(`Server running on port ${port} enviroment ${process.env.SERVER_ENV}`)
})*/

app.listen(port, () => {
    console.log(`Server running on port ${port} enviroment ${process.env.SERVER_ENV}`)
})