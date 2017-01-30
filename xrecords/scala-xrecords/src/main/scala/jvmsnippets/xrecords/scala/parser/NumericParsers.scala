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

  protected[parser] implicit def conv: Number => A

  def parse(string: String): A =
    conv(decimalFormat.parse(string))

  def format(value: A): String = decimalFormat.format(value)
}

class DoubleParser(pattern: String, multiplier: Int = 1)
  extends DecimalFormatNumericParser[Double](pattern, multiplier) {

  protected[parser] implicit val conv = _.doubleValue

  protected[parser] def configureFormat(format: DecimalFormat): Unit = {
    format.setParseIntegerOnly(false)
    format.setParseBigDecimal(false)
  }
}

class IntParser(pattern: String, multiplier: Int = 1)
  extends DecimalFormatNumericParser[Int](pattern, multiplier) {

  protected[parser] implicit val conv  = _.intValue

  protected[parser] def configureFormat(format: DecimalFormat): Unit = {
    format.setParseIntegerOnly(true)
    format.setParseBigDecimal(false)
  }
}

class BigDecimalParser(pattern: String, multiplier: Int = 1)
  extends DecimalFormatNumericParser[BigDecimal](pattern, multiplier) {

  protected[parser] implicit val conv: Number => BigDecimal =
    number => new BigDecimal(new java.math.BigDecimal(number.toString))

  override def configureFormat(format: DecimalFormat): Unit = {
    format.setParseIntegerOnly(false)
    format.setParseBigDecimal(true)
  }
}

class BigIntParser(pattern: String, multiplier: Int = 1)
  extends DecimalFormatNumericParser[BigInt](pattern, multiplier) {

  protected[parser] implicit def conv: Number => BigInt =
    number => new BigInt(new java.math.BigInteger(number.toString))

  override def configureFormat(format: DecimalFormat): Unit = {
    format.setParseIntegerOnly(true)
    format.setParseBigDecimal(false)
  }

}
