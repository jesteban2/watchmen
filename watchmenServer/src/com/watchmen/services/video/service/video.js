const kafka = require("kafka-node")
const { Transform } = require("stream")

const video = {

    play: function(req,res,next){
        const topic = req.params.topic
        const usrid = req.params.usrid
    
        const head = {
            'Content-Type': 'multipart/x-mixed-replace; boundary=myframe'

        }
        res.writeHead(206, head)
        //res.send(`<meta name='viewport' content='width=device-width, initial-scale=1'>`)

        const options = {
            // connect directly to kafka broker (instantiates a KafkaClient)
            kafkaHost: process.env.KAFKA_HOST,
            groupId: 'group-'+usrid+'-'+topic,
            //autoCommitIntervalMs: 500,
            sessionTimeout: 15000,
            protocol: ['roundrobin'],
            encoding: 'binary',
            fromOffset: process.env.KAFKA_FROMOFFSET,
            auto_offset_reset: process.env.KAFKA_FROMOFFSET, 
            enable_auto_commit: false
        }

        const trans = new Transform({
            objectMode:true,
            decodeStrings:true,
            transform(message,encoding,callback){
                let msg = '--myframe\r\n Content-Type: image/jpg\r\n\r\n'
                msg = msg + message.value
                msg = msg + '\r\n\r\n'
                callback(null,Buffer.from(msg,'binary'))
            }
        })
        
        const consumerGroupStream = new kafka.ConsumerGroupStream(Object.assign({ id: 'cons-'+usrid+'-'+topic }, options)
                                                                    ,topic)
        consumerGroupStream.on('message',function onMessage(message){})
        .pipe(trans).pipe(res)

        consumerGroupStream.on('error', function onError(error) {
            console.error(error);
            res.send(error);
        })

        req.on('close',function(){
            consumerGroupStream.close(function(err,result){console.log("consumer closed")})
        })
    }
}

module.exports = video