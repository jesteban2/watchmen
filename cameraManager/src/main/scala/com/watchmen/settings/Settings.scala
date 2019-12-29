package com.watchmen.settings

import akka.actor.{ExtendedActorSystem, Extension, ExtensionId, ExtensionIdProvider}
import com.typesafe.config.{Config, ConfigBeanFactory}
import com.watchmen.settings.Settings.Device

import scala.beans.BeanProperty


class Settings(config: Config) extends Extension {
  import scala.jdk.CollectionConverters._
  val prefix = "cameraManager."

  val devices = config.getConfigList(prefix + "devices").asScala.map(ConfigBeanFactory.create(_ , classOf[Device]))
  val kafka = config.getString(prefix + "kafka")
}

object Settings extends ExtensionId[Settings] with ExtensionIdProvider{
  override def createExtension(system: ExtendedActorSystem): Settings =
    new Settings(system.settings.config)

  override def lookup(): ExtensionId[_ <: Extension] = Settings

  case class Device(@BeanProperty var name: String, @BeanProperty var url: String) {
    def this() = this("", "")
  }
}
