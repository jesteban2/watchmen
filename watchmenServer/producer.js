// producer
//const { load } = require('dotenv')

//load()

const { KafkaClient, Producer, KeyedMessage } = require('kafka-node');

const kafkaHost = 'localhost:9092';
const topic = 'textopic';
const client = new KafkaClient({ kafkaHost })
const producer = new Producer(client)
const messages = [ new KeyedMessage('key', 'foobar') ]

producer.on('ready', () => {
  setInterval(() => {
    producer.send([{ topic, messages }], (error, data) => {
      if (error) {
        console.error(data)
      } else {
        console.log(data)
      }
    })
  }, 5000)
})

producer.on('error', (error) => {
  console.error(error)
})