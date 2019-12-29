package com.watchmen.utils

import java.util.function.Supplier
import org.bytedeco.javacpp.BytePointer
import org.bytedeco.javacv.{Frame, OpenCVFrameConverter}
import org.bytedeco.opencv.opencv_core._
import org.bytedeco.opencv.global.opencv_imgcodecs

object MediaConversion {
    // Each thread gets its own greyMat for safety
    private val frameToMatConverter = ThreadLocal.withInitial(new Supplier[OpenCVFrameConverter.ToMat] {
      def get(): OpenCVFrameConverter.ToMat = new OpenCVFrameConverter.ToMat
    })

    /**
     * Returns an OpenCV Mat for a given JavaCV frame
     */
    def toMat(frame: Frame): Mat = frameToMatConverter.get().convert(frame)

    /**
     * Returns a JavaCV Frame for a given OpenCV Mat
     */
    def toFrame(mat: Mat): Frame = frameToMatConverter.get().convert(mat)


    def toBytes(frame:Frame):Array[Byte] = {
      val obj=frameToMatConverter.get().convert(frame)
      val outputPointer:BytePointer = new BytePointer()
      opencv_imgcodecs.imencode(".jpg",obj,outputPointer)
      val arByte: Array[Byte]= new Array[Byte](outputPointer.capacity().toInt)
      outputPointer.get(arByte)
      arByte
    }

    def toBase64(frame:Frame):Array[Byte] = {
      val obj=frameToMatConverter.get().convert(frame)
      val outputPointer:BytePointer = new BytePointer()
      opencv_imgcodecs.imencode(".jpg",obj,outputPointer)
      val arByte: Array[Byte]= new Array[Byte](outputPointer.capacity().toInt)
      outputPointer.get(arByte)
      val b64 = java.util.Base64.getEncoder.encode(arByte)
      b64
    }

}
