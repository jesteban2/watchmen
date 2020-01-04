const { Transform, Readable } = require("stream")
//var ffmpeg = require('fluent-ffmpeg');
const { spawn } = require('child_process')
//const fs = require('fs')
//const streamBuffers = require('stream-buffers');

const Mp4Segmenter = new require('./Mp4Segmenter')
const mp4segmenter = new Mp4Segmenter()

const videoffmpeg = {

    play: async function(req,res,next){
        
        
        
        var range = req.headers.range
        if (range) {
            console.log("tiene range "+range)
            var positions = range.replace(/bytes=/, "").split("-")
            var start = parseInt(positions[0], 10)
            var total = 10
            var end = positions[1] ? parseInt(positions[1], 10) : total - 1
            var chunksize = (end - start) + 1

            res.writeHead(206, {
                "Content-Range": "bytes " + start + "-" + end + "/" + total,
                "Accept-Ranges": "bytes",
                "Content-Length": chunksize,
                "Content-Type": "video/mp4"
            })
        }else{
            console.log("sin range ")
            res.writeHead(200, {
                "Content-Type": "video/mp4"
            })
        }

 /*       const trans = new Transform({
            objectMode:true,
            decodeStrings:true,
            transform(message,encoding,callback){
                //console.log(message)
                callback(null,Buffer.from(message,'binary'))
            }
        })*/

        let ff = spawn("ffmpeg",[
 //           '-loglevel', 'debug',
            '-f', 'mjpeg',
            '-i', 'http://192.168.1.63:3000/stream/video',
            '-c:v', 'libx264',
            '-preset', 'ultrafast',
            '-pix_fmt', 'yuv420p',
            '-tune', 'zerolatency',
            '-movflags', 'frag_keyframe+empty_moov+default_base_moof+faststart',
            '-f', 'mp4',
            'pipe:1'
        ], 
        {stdio : ['ignore', 'pipe', 'inherit']}
        )

        ff.stdout.on('data',(data)=>{
           // console.log("Si hay data")
           // res.write(Buffer.from(data,'binary'))
        })

        ff.stdout.on('end',()=>{
            console.log("**********************END**** ")          
        })

       /* ff.stderr.on('data',(data)=>{
            console.log("Error "+data)
          //  return
        })*/

        //ff.stdio[1].pipe(mp4segmenter);

       /* if (!mp4segmenter.initSegment) {
            res.status(503);
            res.end('service not available');
            return;
        }*/
        
        res.status(200);
        //res.write(mp4segmenter.initSegment);
        ff.stdio[1].pipe(res);
        res.on('close', () => {
            ff.stdio[1].unpipe(res);
        });
    }
}

module.exports = videoffmpeg