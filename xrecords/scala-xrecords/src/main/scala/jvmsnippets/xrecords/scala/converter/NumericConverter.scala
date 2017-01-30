package jvmsnippets.xrecords.scala.converter

import java.text.DecimalFormat

abstract class NumericConverter[A](pattern: String, multiplier: Int = 1)
  extends Converter[A] {

  protected[converter] def fromNumber(number: Number): A

  protected[converter] def configureFormat(format: DecimalFormat): Unit

  protected[converter] lazy val format: DecimalFormat = {
    val decimalFormat = new DecimalFormat(pattern)
    decimalFormat.setMultiplier(multiplier)
    configureFormat(decimalFormat)
    decimalFormat
  }

  def parse(string: String): A = fromNumber(format.parse(string))

  def format(value: A): String = format.format(value)
}

class DoubleConverter(pattern: String, multiplier: Int = 1)
  extends NumericConverter[Double](pattern, multiplier) {

  protected[converter] def fromNumber(number: Number): Double = number.doubleValue

  protected[converter] def configureFormat(format: DecimalFormat): Unit = {
    format.setParseIntegerOnly(false)
    format.setParseBigDecimal(false)
  }
}

class IntConverter(pattern: String, multiplier: Int = 1)
  extends NumericConverter[Int](pattern, multiplier) {

  protected[converter] def fromNumber(number: Number): Int = number.intValue

  protected[converter] def configureFormat(format: DecimalFormat): Unit = {
    format.setParseIntegerOnly(true)
    format.setParseBigDecimal(false)
  }
}

class BigDecimalConverter(pattern: String, multiplier: Int = 1)
  extends NumericConverter[BigDecimal](pattern, multiplier) {

  protected[converter] def fromNumber(number: Number): BigDecimal =
    new BigDecimal(new java.math.BigDecimal(number.toString))

  override def configureFormat(format: DecimalFormat): Unit = {
    format.setParseIntegerOnly(false)
    format.setParseBigDecimal(true)
  }
}

class BigIntConverter(pattern: String, multiplier: Int = 1)
  extends NumericConverter[BigInt](pattern, multiplier) {

  protected[converter] def fromNumber(number: Number): BigInt =
    new BigInt(new java.math.BigInteger(number.toString))

  override def configureFormat(format: DecimalFormat): Unit = {
    format.setParseIntegerOnly(true)
    format.setParseBigDecimal(false)
  }

}
