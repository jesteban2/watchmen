package com.watchmen.video

import akka.NotUsed
import akka.actor.{ActorLogging, ActorSystem, DeadLetterSuppression, Props}
import akka.stream.actor.ActorPublisher
import akka.stream.actor.ActorPublisherMessage.{Cancel, Request}
import akka.stream.scaladsl.Source
import org.bytedeco.javacv.FrameGrabber.ImageMode
import org.bytedeco.javacv.{Frame, FrameGrabber}
import org.bytedeco.opencv.global.opencv_core._
import org.bytedeco.javacv.FFmpegFrameGrabber


object VideoReader {
  /**
   * Builds a Frame [[Source]]
   *
   * @param deviceId device ID for the webcam
   * @param dimensions
   * @param bitsPerPixel
   * @param imageMode
   * @param system ActorSystem
   * @return a Source of [[Frame]]s
   */
  def source(
              deviceId: String,
              dimensions: Dimensions,
              bitsPerPixel: Int = CV_8U,
              imageMode: ImageMode = ImageMode.COLOR,
              frameRate: Double
            )(implicit system: ActorSystem): Source[Frame,NotUsed] = {
    val props = Props(
      new WebcamFramePublisher(
        deviceId = deviceId,
        imageWidth = dimensions.width,
        imageHeight = dimensions.height,
        bitsPerPixel = bitsPerPixel,
        imageMode = imageMode,
        frameRate = frameRate
      )
    )
    val webcamActorRef = system.actorOf(props)
    val webcamActorPublisher = ActorPublisher[Frame](webcamActorRef)

    Source.fromPublisher(webcamActorPublisher)
  }

  // Building a started grabber seems finicky if not synchronised; there may be some freaky stuff happening somewhere.
  private def buildGrabber(
                            deviceId: String,
                            imageWidth: Int,
                            imageHeight: Int,
                            bitsPerPixel: Int,
                            imageMode: ImageMode,
                            frameRate: Double
                          ): FFmpegFrameGrabber = synchronized {
    val g = new FFmpegFrameGrabber(deviceId)
    g.setImageWidth(imageWidth)
    g.setImageHeight(imageHeight)
    g.setBitsPerPixel(bitsPerPixel)
    g.setImageMode(imageMode)
    g.setFrameRate(frameRate)
    g.start()
    g
  }

  /**
   * Actor that backs the Akka Stream source
   */
  private class WebcamFramePublisher(
                                      deviceId: String,
                                      imageWidth: Int,
                                      imageHeight: Int,
                                      bitsPerPixel: Int,
                                      imageMode: ImageMode,
                                      frameRate: Double
                                    ) extends ActorPublisher[Frame] with ActorLogging {

    private implicit val ec = context.dispatcher

    // Lazy so that nothing happens until the flow begins
    private lazy val grabber = buildGrabber(
      deviceId = deviceId,
      imageWidth = imageWidth,
      imageHeight = imageHeight,
      bitsPerPixel = bitsPerPixel,
      imageMode = imageMode,
      frameRate = frameRate
    )

    def receive: Receive = {
      case _: Request => emitFrames()
      case Continue => emitFrames()
      case Cancel => onCompleteThenStop()
      case unexpectedMsg => log.warning(s"Unexpected message: $unexpectedMsg")
    }

    private def emitFrames(): Unit = {
      if (isActive && totalDemand > 0) {
        /*
          Grabbing a frame is a blocking I/O operation, so we don't send too many at once.
         */
        grabFrame().foreach(onNext)
        if (totalDemand > 0) {
          self ! Continue
        }
      }
    }

    private def grabFrame(): Option[Frame] = {
      Option(grabber.grab())
    }
  }

  private case object Continue extends DeadLetterSuppression
}
