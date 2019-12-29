const http = require('http');
var htmlEscape = require('sanitizer/sanitizer').escape;
var kafka = require("kafka-node");
const { Transform } = require('stream');
const { Readable } = require('stream');

var videoStream;

var options = {
    // connect directly to kafka broker (instantiates a KafkaClient)
    kafkaHost: 'localhost:9092',
    groupId: 'avReader',
    //autoCommit: true,
    autoCommitIntervalMs: 500,
    sessionTimeout: 15000,
    //fetchMaxBytes: 10 * 1024 * 1024, // 10 MB
    // An array of partition assignment protocols ordered by preference. 'roundrobin' or 'range' string for
    // built ins (see below to pass in custom assignment protocol)
    protocol: ['roundrobin'],
    encoding: 'binary',
    // Offsets to use for new groups other options could be 'earliest' or 'none'
    // (none will emit an error if no offsets were saved) equivalent to Java client's auto.offset.reset
    fromOffset: 'earliest',
    // how to recover from OutOfRangeOffset error (where save offset is past server retention)
    // accepts same value as fromOffset
    //outOfRangeOffset: 'earliest'
  };

  var consumerGroup = new kafka.ConsumerGroup(Object.assign({ id: 'consumer1' }, options), 'movieTestBytes');

    var serv = http.createServer(function(req, res) {
    res.setHeader("Access-Control-Allow-Headers", "*");
    res.setHeader("Access-Control-Allow-Origin","*");
    
    console.log(req.url);
    if(req.url=="/"){
        res.write("Jelouuuuuu");
        res.statusCode=200;
        res.end("success");
    }

    if(req.url=="/video"){
        const head = {
           // 'Content-Range': `bytes ${start}-${end}/${fileSize}`,
           // 'Accept-Ranges': 'bytes',
          //  'Content-Length': chunksize,
            'Content-Type': 'multipart/x-mixed-replace; boundary=myframe',
          }
          res.writeHead(206, head);
        
        consumerGroup.on('message',function onMessage(message){
            //console.log("Message topic "+message.topic);
           // let buff = Buffer.from(message.value);
            /*var aux;
            console.log("como vamos vamos bien");
            //aux = "data:image/jpg;base64,"+buff;
            aux = '--myframe\r\n Content-Type: image/jpg\r\n\r\n'+buff.toString('hex')+'\r\n\r\n';
            console.log(aux);*/
            console.log("como vamos vamos bien");
            res.write('--myframe\r\n Content-Type: image/jpg\r\n\r\n')
            res.write(message.value,'binary')
            res.write('\r\n\r\n');
            //console.log(message.value);

            const messageTransform = new Transform({
                objectMode: true,
                decodeStrings: true,
                transform (mmsg, encoding, done) {
                    console.log("como vamos vamos bien");
                    var mens;
                    mens = '--myframe\r\n Content-Type: image/jpg\r\n\r\n'+mmsg.toString('hex')+'\r\n\r\n';
                  //mmsg = mens;
                  //console.log(mens);
                  done(null,mens);
                }
              });


            const stream = new Readable();
            //stream.push(buff);
            //stream.push(null);

            //stream.pipe(messageTransform).pipe(res);

        });

        consumerGroup.on('error', function onError(error) {
            console.error(error);
            res.end();
            });



          // connection closed - finish the response
            res.on('close', () => res.end());
        }

    });
serv.listen(3000);
