package jvmsnippets.xrecords.scala.util

/**
  * Assorted validation checks.
  */
object Checks {
  def checkEqual[A](left: A, right: A,
                    message: String = "Values must be equal and non-null"): Unit = {
    if (left == null || right == null) {
      throw new NullPointerException("Neither argument can be null")
    }

    if (left != right) {
      throw new IllegalArgumentException(message)
    }
  }

  def checkNonNull(value: Any, message: String = "Value cannot be null or blank"): Unit =
    if (value == null) {
      throw new IllegalArgumentException(message)
    }

  def checkNonEmpty(string: String, message: String = "Value cannot be null or blank"): Unit =
    if (string == null || string.trim.length == 0) {
      throw new IllegalArgumentException(message)
    }
}
