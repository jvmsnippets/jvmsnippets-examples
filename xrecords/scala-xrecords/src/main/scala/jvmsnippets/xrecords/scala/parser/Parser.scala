package jvmsnippets.xrecords.scala.parser

trait Parser[A] {
  def parse(string: String): A

  def format(item: A): String
}
