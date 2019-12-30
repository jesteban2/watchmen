classpathTypes += "maven-plugin"

libraryDependencies += "org.bytedeco" % "javacpp" % "1.5.2"

resolvers += "Typesafe repository" at "http://repo.typesafe.com/typesafe/releases/"

addSbtPlugin("com.typesafe.sbt" % "sbt-native-packager" % "1.5.2")