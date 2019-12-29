const express = require('express')
const dotenv = require('dotenv').config()
const port = process.env.PORT || 3000
const routes = require('./src/com/watchmen/api/routes')
require('./src/com/watchmen/db/db')


const app = express()
app.use(express.json())
app.use(routes)
app.listen(port, () => {
    console.log(`Server running on port ${port}`)
})