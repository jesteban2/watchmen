const { Transform, Readable } = require("stream")
//var ffmpeg = require('fluent-ffmpeg');
const { spawn } = require('child_process')
//const fs = require('fs')
//const streamBuffers = require('stream-buffers');

const Mp4Segmenter = new require('./Mp4Segmenter')
const mp4segmenter = new Mp4Segmenter()

const videoffmpeg = {

    play: async function(req,res,next){
        
        
        console.log("tiene ranges: "+req.headers.range)
       /* const range = req.headers.range
        if(range){
            const parts = range.replace(/bytes=/, "").split("-")
            const start = parseInt(parts[0], 10)
            const framesize = 100000000000000
            const end = 98303
            const chunksize = (end-start)+1
            const head = {
                'Content-Range': `bytes ${start}-${end}/${framesize}`,
                'Accept-Ranges': 'bytes',
                'Content-Length': chunksize,
                'Content-Type': 'video/mp4',
                }
            res.writeHead(206, head)

        }else{
            */
           const head = {
            'Content-Type': 'video/mp4'
            }
            res.writeHead(200, head)
  //      }

       const trans = new Transform({
            objectMode:true,
            decodeStrings:true,
            transform(message,encoding,callback){
                console.log("Frame length: "+message.byteLength)
                callback(null,message)
            }
        })

        let ff = spawn("ffmpeg",[
 //           '-loglevel', 'debug',
            '-f', 'mjpeg',
            '-i', 'http://192.168.1.63:3000/stream/video',
            '-c:v', 'libx264',
            '-profile:v', 'baseline', //'-level', '3.0',
//            '-maxrate', '600k', '-bufsize', '1000k',
//            '-preset', 'ultrafast',
            '-crf', '23',
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

        ff.stdout.on('error',()=>{
            console.log("**********************ERROR**** ")          
        })

        /*ff.stderr.on('data',(data)=>{
            console.log("Error "+data)
          //  return
        })*/

        ff.stdio[1].pipe(mp4segmenter);

        if (!mp4segmenter.initSegment) {
            console.log("*********************NO INIT SEGMENT")
            res.status(503);
            res.end('service not available');
            return;
        }
        
        res.status(200);
        res.write(mp4segmenter.initSegment);
        ff.stdio[1].pipe(trans).pipe(res);
        res.on('close', () => {
            ff.stdio[1].unpipe(res);
        });

        req.on('close',function(){
            console.log("FFMPEG closed\n")
            ff.kill()
        })

    }
}

module.exports = videoffmpeg