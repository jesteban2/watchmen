package com.watchmen.video

import akka.NotUsed
import akka.actor.ActorSystem
import akka.stream.scaladsl.Source
import akka.stream.stage.{GraphStage, GraphStageLogic, OutHandler}
import akka.stream.{Attributes, Graph, Outlet, SourceShape}
import org.bytedeco.javacv.FrameGrabber.ImageMode
import org.bytedeco.javacv.{FFmpegFrameGrabber, Frame, FrameGrabber}
import org.bytedeco.opencv.global.opencv_core._


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
              frameRate: Double = 30
            )(implicit system: ActorSystem): Source[Frame, NotUsed] = {
    val sourceGraph: Graph[SourceShape[Frame], NotUsed] = new WebcamFrameSource(
      deviceId,
      dimensions.width,
      dimensions.height,
      bitsPerPixel,
      imageMode,
      frameRate
    )
    Source.fromGraph(sourceGraph)
  }

  // Building a started grabber seems finicky if not synchronised; there may be some freaky stuff happening somewhere.
  private def buildGrabber(
                            deviceId: String,
                            imageWidth: Int,
                            imageHeight: Int,
                            bitsPerPixel: Int,
                            imageMode: ImageMode,
                            frameRate: Double
                          ): FrameGrabber = synchronized {
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
  private class WebcamFrameSource(
                                      deviceId: String,
                                      imageWidth: Int,
                                      imageHeight: Int,
                                      bitsPerPixel: Int,
                                      imageMode: ImageMode,
                                      frameRate: Double
                                    ) extends GraphStage[SourceShape[Frame]] {

    val out: Outlet[Frame] = Outlet("WebcamFrameSource")

    override val shape: SourceShape[Frame] = SourceShape(out)


    override def createLogic(inheritedAttributes: Attributes): GraphStageLogic =
      new GraphStageLogic(shape) {
        private lazy val grabber = buildGrabber(
          deviceId = deviceId,
          imageWidth = imageWidth,
          imageHeight = imageHeight,
          bitsPerPixel = bitsPerPixel,
          imageMode = imageMode,
          frameRate = frameRate
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
