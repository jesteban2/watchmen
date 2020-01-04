package com.watchmen.video

import akka.NotUsed
import akka.actor.ActorSystem
import akka.stream.scaladsl.Source
import akka.stream.stage.{GraphStage, GraphStageLogic, OutHandler}
import akka.stream.{Attributes, Graph, Outlet, SourceShape}
import org.bytedeco.javacv.FrameGrabber.ImageMode
import org.bytedeco.javacv.{FFmpegFrameGrabber, Frame, FrameGrabber}


object VideoReader {

  def source(
              deviceId: String,
              dimensions: Dimensions,
              pixelFormat: Int = -1,
              imageMode: ImageMode = ImageMode.COLOR,
              frameRate: Double = 30,
              options: Map[String, String] = Map.empty
            )(implicit system: ActorSystem): Source[Frame, NotUsed] = {
    val sourceGraph: Graph[SourceShape[Frame], NotUsed] = new WebcamFrameSource(
      deviceId,
      dimensions.width,
      dimensions.height,
      pixelFormat,
      imageMode,
      frameRate,
      options
    )
    Source.fromGraph(sourceGraph)
  }

  // Building a started grabber seems finicky if not synchronised; there may be some freaky stuff happening somewhere.
  private def buildGrabber(
                            deviceId: String,
                            imageWidth: Int,
                            imageHeight: Int,
                            pixelFormat: Int,
                            imageMode: ImageMode,
                            frameRate: Double,
                            options: Map[String, String]
                          ): FrameGrabber = synchronized {
    val g = new FFmpegFrameGrabber(deviceId)
    g.setImageWidth(imageWidth)
    g.setImageHeight(imageHeight)
    g.setPixelFormat(pixelFormat)
    g.setImageMode(imageMode)
    g.setFrameRate(frameRate)
    options.foreach{ case (k,v) => g.setOption(k, v) }
    g.start()
    g
  }

  /**
   * Actor that backs the Akka Stream source
   */
  private class WebcamFrameSource(
                                      deviceId: String,
                                      imageWidth: Int,
                                      imageHeight: Int,
                                      pixelFormat: Int,
                                      imageMode: ImageMode,
                                      frameRate: Double,
                                      options: Map[String, String]
                                    ) extends GraphStage[SourceShape[Frame]] {

    val out: Outlet[Frame] = Outlet("WebcamFrameSource")

    override val shape: SourceShape[Frame] = SourceShape(out)


    override def createLogic(inheritedAttributes: Attributes): GraphStageLogic =
      new GraphStageLogic(shape) {
        private lazy val grabber = buildGrabber(
          deviceId = deviceId,
          imageWidth = imageWidth,
          imageHeight = imageHeight,
          pixelFormat = pixelFormat,
          imageMode = imageMode,
          frameRate = frameRate,
          options = options
        )

        setHandler(out, new OutHandler {
          override def onPull(): Unit = {
            grabFrame().foreach(push(out, _))
          }
        })
        private def grabFrame(): Option[Frame] = {
          Option(grabber.grab())
        }
      }

  }

}
