package scratchpad

import ch.qos.logback.classic.{Level, Logger, LoggerContext}
import ch.qos.logback.classic.encoder.PatternLayoutEncoder
import ch.qos.logback.classic.spi.ILoggingEvent
import ch.qos.logback.core.FileAppender
import org.slf4j.LoggerFactory

case class Worksheet(name: String) {

  private val logger = {
    val lc = LoggerFactory.getILoggerFactory.asInstanceOf[LoggerContext]
    lc.reset()

    val encoder = new PatternLayoutEncoder
    encoder.setPattern(">>> [%d][%logger][%thread]%n%msg%n")
    encoder.setContext(lc)
    encoder.start()

    val appender = new FileAppender[ILoggingEvent]
    appender.setFile("/tmp/worksheet.log")
    appender.setEncoder(encoder)
    appender.setAppend(true)
    appender.setContext(lc)
    appender.start()

    val logger = LoggerFactory.getLogger(name).asInstanceOf[Logger]
    logger.addAppender(appender)
    logger.setLevel(Level.INFO)
    logger.setAdditive(false)

    logger
  }

  def log(msg: String): Unit = logger.info(msg)
  def log(msg: String, t: Throwable): Unit = logger.info(msg, t)
}
