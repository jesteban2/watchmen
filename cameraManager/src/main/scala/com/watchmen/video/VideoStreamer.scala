package com.watchmen.video

import akka.Done
import akka.actor.ActorSystem
import akka.kafka.ProducerSettings
import akka.kafka.scaladsl.Producer
import akka.stream.scaladsl.{Merge, Source}
import akka.stream.{ActorMaterializer, ActorMaterializerSettings, Supervision}
import com.watchmen.settings.Settings
import com.watchmen.utils._
import org.apache.kafka.clients.producer.ProducerRecord
import org.apache.kafka.common.serialization._

import scala.concurrent.Future

object VideoStreamer extends App {
  implicit val actorSystem: ActorSystem = ActorSystem()
  val decider: Supervision.Decider ={
    case e: Exception =>
      Supervision.Resume
  }

  implicit val actorMaterializer: ActorMaterializer = ActorMaterializer(
    ActorMaterializerSettings(actorSystem).withSupervisionStrategy(decider)
  )

  val config = actorSystem.settings.config.getConfig("akka.kafka.producer")
  val devices = Settings(actorSystem).devices
  val imageDimensions = Dimensions(width = 576, height = 324)
  val webcamSource = devices.map( device => VideoReader.source(deviceId = device.url, dimensions = imageDimensions, options = Map("rtsp_transport" -> "tcp"))
    .map(MediaConversion.toBytes)
    .map(s => new ProducerRecord[String,Array[Byte]](device.name, s))
  ).reduce((s1, s2) => Source.combine(s1, s2)(Merge(_)))


  val producerSettings =
    ProducerSettings(config, new StringSerializer, new ByteArraySerializer)
      .withBootstrapServers(Settings(actorSystem).kafka)

  val producerSink: Future[Done] =
    webcamSource
      .runWith(Producer.plainSink(producerSettings))
  println("************ Message produced ************")


}
