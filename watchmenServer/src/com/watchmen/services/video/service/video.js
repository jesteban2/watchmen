const kafka = require("kafka-node")

const video = {

    play: function(req,res,next){
        const topic = req.params.topic
        const usrid = req.params.usrid
    
        const head = {
            'Content-Type': 'multipart/x-mixed-replace; boundary=myframe'
        }
        res.writeHead(206, head)

        const options = {
            // connect directly to kafka broker (instantiates a KafkaClient)
            kafkaHost: process.env.KAFKA_HOST,
            groupId: 'group-'+usrid,
            autoCommitIntervalMs: 500,
            sessionTimeout: 15000,
            protocol: ['roundrobin'],
            encoding: 'binary',
            fromOffset: 'earliest'
            };
        
        const consumerGroup = new kafka.ConsumerGroup(Object.assign({ id: 'cons-'+usrid }, options),topic)
        consumerGroup.on('message',function onMessage(message){
            res.write('--myframe\r\n Content-Type: image/jpg\r\n\r\n')
            res.write(message.value,'binary')
            res.write('\r\n\r\n');
        })

        consumerGroup.on('error', function onError(error) {
            console.error(error);
            res.send(error);
        })
    }
}

//router.get('/:devid'+'/:usrid', auth, async(req, res) => {

module.exports = video