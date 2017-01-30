package jvmsnippets.xrecords.scala.parser

import java.text.DecimalFormat
import scala.language.implicitConversions

abstract class DecimalFormatNumericParser[A](pattern: String, multiplier: Int = 1)
  extends Parser[A] {

  protected[parser] def configureFormat(format: DecimalFormat): Unit

  protected[parser] lazy val decimalFormat: DecimalFormat = {
    val decimalFormat = new DecimalFormat(pattern)
    decimalFormat.setMultiplier(multiplier)
    configureFormat(decimalFormat)
    decimalFormat
  }

  protected[parser] def fromNumber(number: Number): A

  def parse(string: String): A =
    fromNumber(decimalFormat.parse(string))

  def format(value: A): String =
    decimalFormat.format(value)
}

class DoubleParser(pattern: String, multiplier: Int = 1)
  extends DecimalFormatNumericParser[Double](pattern, multiplier) {

  protected[parser] def fromNumber(number: Number): Double =
    number.doubleValue

  protected[parser] def configureFormat(format: DecimalFormat): Unit = {
    format.setParseIntegerOnly(false)
    format.setParseBigDecimal(false)
  }
}

class IntParser(pattern: String, multiplier: Int = 1)
  extends DecimalFormatNumericParser[Int](pattern, multiplier) {

  protected[parser] def fromNumber(number: Number): Int =
    number.intValue

  protected[parser] def configureFormat(format: DecimalFormat): Unit = {
    format.setParseIntegerOnly(true)
    format.setParseBigDecimal(false)
  }
}

class BigDecimalParser(pattern: String, multiplier: Int = 1)
  extends DecimalFormatNumericParser[BigDecimal](pattern, multiplier) {

  protected[parser] def fromNumber(number: Number): BigDecimal =
    new BigDecimal(new java.math.BigDecimal(number.toString))

  override def configureFormat(format: DecimalFormat): Unit = {
    format.setParseIntegerOnly(false)
    format.setParseBigDecimal(true)
  }
}

class BigIntParser(pattern: String, multiplier: Int = 1)
  extends DecimalFormatNumericParser[BigInt](pattern, multiplier) {

  protected[parser] def fromNumber(number: Number): BigInt =
    new BigInt(new java.math.BigInteger(number.toString))

  override def configureFormat(format: DecimalFormat): Unit = {
    format.setParseIntegerOnly(true)
    format.setParseBigDecimal(false)
  }

}
