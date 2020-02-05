const kafka = require("kafka-node")
const { Transform } = require("stream")

const videoStream = {

    play: async function(req,res,next){
        const topic = req.params.topic
        const usrid = req.params.usrid
       // res.write(`<meta name='viewport' content='width=device-width, initial-scale=1.0'>`)
       console.log(res.locals)
        const head = {
            'Content-Type': 'multipart/x-mixed-replace; boundary=myframe'
        }
        res.writeHead(206, head)
        

        const options = {
            // connect directly to kafka broker (instantiates a KafkaClient)
            kafkaHost: 'localhost:9092',
            groupId: 'group-otro',
            //enable_auto_commit: false,
            autoCommit: false,
            //autoCommitIntervalMs: 500,
            sessionTimeout: 15000,
            protocol: ['roundrobin'],
            encoding: 'binary',
            fromOffset: 'latest',
            commitOffsetsOnFirstJoin: false
            };
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

        const consumerClient = new kafka.KafkaClient('localhost:9092');

        /* Print latest offset. */
        var offset = new kafka.Offset(consumerClient);
        //var topic='movieTestBytes'

        offset.fetch([{ topic: 'movieTestBytes', partition: 0, time: -1 }], function (err, data) {
                var latestOffset = data['movieTestBytes']['0'][0];
                console.log("Consumer current offset: " + latestOffset);
        });

        

        const consumerGroupStream = new kafka.ConsumerGroupStream(Object.assign({ id: 'cons-otro' }, options),'movieTestBytes')
        consumerGroupStream.on('message',function onMessage(message){})
        .pipe(trans).pipe(res)

        consumerGroupStream.on('error', function onError(error) {
            console.error("no se que fue"+error);
            res.send(error);
        })

        req.on('close',function(){
            consumerGroupStream.close(function(err,result){console.log("consumer closed")})
        })
        
    }
}

module.exports = videoStream