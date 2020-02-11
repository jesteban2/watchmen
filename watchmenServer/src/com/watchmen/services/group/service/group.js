const Group = require('../model/Group')

const group = {

    create: async function(req,res,next){
        try {
            const group = new Group(req.body)
            await group.save()
            res.status(201).send({ group })
        } catch (error) {
            res.status(400).send(error)
        }
    },

    search: async function(req,res,next){
        try {
            const groupid = req.params.groupid
            const group = await Group.findGroup(groupid)
            if (!group) {
                throw new Error()
            }
            req.group = group
        } catch (error) {
            res.status(401).send({ error: 'Group not found' })
        }
        res.send(req.group)
    }
}

module.exports = group