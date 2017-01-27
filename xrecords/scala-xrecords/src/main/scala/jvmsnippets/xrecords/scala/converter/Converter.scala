package jvmsnippets.xrecords.scala.converter

trait Converter[A] {
  def parse(string: String): A

  def format(item: A): String
}
