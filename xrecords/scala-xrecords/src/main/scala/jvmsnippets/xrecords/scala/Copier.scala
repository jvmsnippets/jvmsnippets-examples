package jvmsnippets.xrecords.scala

trait Channel[A] {
  def open(): A

  def close(a: A): Unit
}

trait Source[A] extends Channel[Iterator[A]]

trait Destination[A] extends Channel[A => Unit]

trait Copier[A, B] {

  def source: Source[A]

  def include: A => Boolean = _ => true

  def transform: A => B

  def destination: Destination[B]

  def copy(): (Int, Int) = {

    val input = source.open()

    val (inputCount, outputCount) =
      if (input.isEmpty) {
        (0, 0)
      } else {

        val output = destination.open()

        val (inputCount, outputCount) =
          input.foldLeft(0, 0) { (counts, element) =>
            val (inputCount, outputCount) = counts
            if (include(element)) {
              output(transform(element))
              (inputCount + 1, outputCount + 1)
            } else {
              (inputCount + 1, outputCount)
            }
          }

        destination.close(output)

        (inputCount, outputCount)
      }

    source.close(input)

    (inputCount, outputCount)
  }
}
