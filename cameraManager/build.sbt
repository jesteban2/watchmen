name := "cameraManager"

version := "0.1"

scalaVersion := "2.13.1"


val javacppVersion = "1.5.2"

libraryDependencies += "org.bytedeco" % "javacpp" % "1.5.2"

libraryDependencies += "com.typesafe.akka" %% "akka-stream-kafka" % "1.1.0"

libraryDependencies += "com.typesafe.akka" %% "akka-http-spray-json" % "10.1.11"

libraryDependencies += "com.lightbend.akka" %% "akka-stream-alpakka-json-streaming" % "1.1.2"

libraryDependencies += "org.slf4j" % "slf4j-simple" % "1.6.4"

resolvers += "Sonatype OSS Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots"
resolvers += Resolver.mavenLocal

autoCompilerPlugins := true

// Platform classifier for native library dependencies
val platform = org.bytedeco.javacpp.Loader.getPlatform
// Libraries with native dependencies
val bytedecoPresetLibs = Seq(
  "opencv" -> s"4.1.2-$javacppVersion",
  "ffmpeg" -> s"4.2.1-$javacppVersion",
  "openblas" -> s"0.3.7-$javacppVersion"
).flatMap {
  case (lib, ver) => Seq(
    // Add both: dependency and its native binaries for the current `platform`
    "org.bytedeco" % lib % ver withSources() withJavadoc(),
    "org.bytedeco" % lib % ver classifier platform
  )
}

libraryDependencies ++= Seq(
  "org.bytedeco"            % "javacpp"         % javacppVersion withSources() withJavadoc(),
  "org.bytedeco"            % "javacv"          % javacppVersion withSources() withJavadoc(),
  "org.scala-lang.modules" %% "scala-swing"     % "2.1.1"
) ++ bytedecoPresetLibs

mainClass in (Compile, run) := Some("com.watchmen.video.VideoStreamer")
mainClass in (Compile, packageBin) := Some("com.watchmen.video.VideoStreamer")


