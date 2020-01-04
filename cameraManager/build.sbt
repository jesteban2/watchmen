import BuildEnvPlugin.autoImport.{BuildEnv, buildEnv}


name := "cameraManager"

version := "0.1"

scalaVersion := "2.13.1"

enablePlugins(JavaAppPackaging)

libraryDependencies += "com.typesafe.akka" %% "akka-stream-kafka" % "1.1.0"

libraryDependencies += "com.typesafe.akka" %% "akka-http-spray-json" % "10.1.11"

libraryDependencies += "com.lightbend.akka" %% "akka-stream-alpakka-json-streaming" % "1.1.2"

libraryDependencies += "org.slf4j" % "slf4j-simple" % "1.6.4"

resolvers += "Sonatype OSS Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots"

javaCppPresetLibs ++= Seq("opencv" -> "4.1.2", "ffmpeg" -> "4.2.1", "openblas" -> "0.3.7")

libraryDependencies += "org.bytedeco" % "javacv" % javaCppVersion.value

javaOptions in Universal ++= Seq(
  "-Dconfig.resource=/" + ( buildEnv.value match {
    case BuildEnv.Developement => "dev.conf"
    case BuildEnv.Test => "test.conf"
    case BuildEnv.Stage => "stage.conf"
    case BuildEnv.Production => "prd.conf"
  } )
)




