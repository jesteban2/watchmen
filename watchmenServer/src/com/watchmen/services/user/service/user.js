const User = require('../model/User')

const user = {

    create: async function(req,res,next){
        try {
            const user = new User(req.body)
            await user.save()
            const token = await user.generateAuthToken()
            res.status(201).send({ user, token })
        } catch (error) {
            res.status(400).send(error)
        }
    },

    login: async function(req,res,next){
        try {
            const { usrid, password } = req.body
            const user = await User.findByCredentials(usrid, password)
            if (!user) {
                return res.status(401).send({error: 'Login failed! Check authentication credentials'})
            }
            const token = await user.generateAuthToken()
            res.send({ user, token })
        } catch (error) {
           // res.status(400).send(error)
           return res.status(401).send({error: 'Login failed! Check authentication credentials'})
        }
    },

    logged: function(req,res,next){
        res.send(req.user)
    },

    logout: async function(req,res,next){
        try {
            req.user.tokens = req.user.tokens.filter((token) => {
                return token.token != req.token
            })
            await req.user.save()
            res.send()
        } catch (error) {
            res.status(500).send(error)
        }
    },

    logoutAll: async function(req,res,next){
        try {
            req.user.tokens.splice(0, req.user.tokens.length)
            await req.user.save()
            res.send()
        } catch (error) {
            res.status(500).send(error)
        }
    }
}
module.exports = user