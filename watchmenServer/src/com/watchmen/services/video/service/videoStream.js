const kafka = require("kafka-node")
const { Transform } = require("stream")

const videoStream = {

    play: async function(req,res,next){
        const topic = req.params.topic
        const usrid = req.params.usrid
    
        const head = {
            'Content-Type': 'multipart/x-mixed-replace; boundary=myframe'
        }
        res.writeHead(206, head)

        const options = {
            // connect directly to kafka broker (instantiates a KafkaClient)
            kafkaHost: 'localhost:9092',
            groupId: 'group-prueba',
            autoCommitIntervalMs: 500,
            sessionTimeout: 15000,
            protocol: ['roundrobin'],
            encoding: 'binary',
            fromOffset: 'earliest'
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

        const consumerGroupStream = new kafka.ConsumerGroupStream(Object.assign({ id: 'cons-prueba' }, options),'movieTestBytes')
        consumerGroupStream.on('message',function onMessage(message){})
        .pipe(trans).pipe(res)

        consumerGroupStream.on('error', function onError(error) {
            console.error(error);
            res.send(error);
        })

        
    }
}

//router.get('/:devid'+'/:usrid', auth, async(req, res) => {

module.exports = videoStream