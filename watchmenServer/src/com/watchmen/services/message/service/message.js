const Message = require('../model/Message')
const kafka = require("kafka-node")
const { Transform } = require("stream")

const message = {

    post: function(req,res,next){
        try {
            const Producer = kafka.Producer
            //var Client = kafka.KafkaClient
            //const client = new Client(process.env.KAFKA_HOST)
            const client = new kafka.KafkaClient({kafkaHost: process.env.KAFKA_HOST});
            const producer = new Producer(client)
            const message = new Message(req.body)
            const topic = "msgroup_1"

            console.log("Connecting to kafka server: "+process.env.KAFKA_HOST)
            console.log("sending message: \n"+JSON.stringify(message))
            

            producer.send([{ topic: topic, messages: JSON.stringify(message)}], function (err,result) {
                if(err){
                    console.log("Error sending message \n"+err)
                    res.status(400).send(err)
                }else{
                    res.status(200).send({message})
                }
              })
            
            
            producer.on('error', function (err) {
              console.log('producer error \n', err);
             // res.status(400).send(err)
            });
            
        } catch (error) {
            console.log("general post message error: \n"+error)
         //   res.status(400).send(error)
        }
    },

    get: function(req,res,next){
        const usrid = req.params.usrid
        const topic = "msgroup_1"
        const options = {
            // connect directly to kafka broker (instantiates a KafkaClient)
            kafkaHost: process.env.KAFKA_HOST,
            groupId: 'msgroup-'+usrid,
            autoCommitIntervalMs: 500,
            sessionTimeout: 15000,
            protocol: ['roundrobin'],
            encoding: 'utf8',
            fromOffset: process.env.KAFKA_MS_FROMOFFSET
            //auto_offset_reset =process.env.KAFKA_MS_FROMOFFSET, 
            //enable_auto_commit=False
        }

        const trans = new Transform({
            objectMode:true,
            decodeStrings:true,
            transform(message,encoding,callback){
                console.log(JSON.stringify(message.value))
                callback(null,JSON.stringify(message.value))
            }
        })
        let messages=[]
        const consumerGroup = new kafka.ConsumerGroup(Object.assign({ id: 'mscons-'+usrid }, options)
                                                                    ,topic)
        consumerGroup.on('message',function onMessage(message){
            //const aux = message.value.replace(/(\r\n|\n|\r)/gm,"")
            messages.push(message.value)
            if(message.offset==(message.highWaterOffset-1)){
                consumerGroup.commit(function(err,data){console.log("consumer commit")})
                consumerGroup.close(function(err,result){console.log("consumer closed")})
                res.status(200).send(messages)
            }
        })

        consumerGroup.on('error', function onError(error) {
            console.error(error);
            res.status(400).send(error);
        })

        req.on('close',function(){
            consumerGroup.close(function(err,result){console.log("consumer closed")})
        })
    }
}

module.exports = message