package com.watchmen.video

import akka.Done
import akka.actor.ActorSystem
import akka.kafka.ProducerSettings
import com.typesafe.config.ConfigFactory
import org.apache.kafka.clients.producer.ProducerRecord
import org.apache.kafka.common.serialization._
import akka.kafka.scaladsl.Producer
import akka.stream.ActorMaterializer
import scala.concurrent.Future
import com.watchmen.utils._

object VideoStreamer extends App {
  implicit val actorSystem: ActorSystem = ActorSystem()
  implicit val actorMaterializer: ActorMaterializer = ActorMaterializer()
  val config = ConfigFactory.load.getConfig("akka.kafka.producer")

  val imageDimensions = Dimensions(width = 640, height = 480)
  val webcamSource = VideoReader.source(deviceId = "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4", dimensions = imageDimensions, frameRate = 20)

  val producerSettings =
    ProducerSettings(config, new StringSerializer, new ByteArraySerializer)
      .withBootstrapServers("http://localhost:9092")

  val producerSink: Future[Done] =
    webcamSource
      .map(MediaConversion.toBytes2)
      //      .map(_.toJson)
      //      .map(_.compactPrint)
      .map(value => new ProducerRecord[String,Array[Byte]]("mtest01", value))
      .runWith(Producer.plainSink(producerSettings))
  println("************ Message produced ************")


}
