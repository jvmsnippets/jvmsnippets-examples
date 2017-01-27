package jvmsnippets.xrecords.scala

trait ScalarType[A] {

  def parse(representation: String): A

  def format(value: A): String

  import scala.reflect._

  def isClassCompatible(any: Any)(implicit ctag: ClassTag[A]) =
    ctag.runtimeClass.isAssignableFrom(any.getClass)
}

case class TypedRecord(types: Map[String, ScalarType[Any]]) {

  import collection.mutable.{Map => MMap}

  val fields: MMap[String, Any] = MMap[String, Any]()

  def apply(fieldName: String): Any = {
    assert(fields.contains(fieldName), s"Unset field $fieldName")
    fields(fieldName)
  }

  def get(fieldName: String): Option[Any] =
    fields.get(fieldName)

  def asString(fieldName: String): String = {
    val fieldValue = apply(fieldName)
    types(fieldName).format(fieldValue)
  }

  def getAsString(fieldName: String): Option[String] = {
    assert(types.contains(fieldName), s"Invalid field name $fieldName")
    fields.get(fieldName).map(types(fieldName).format)
  }

  def update(fieldName: String, fieldValue: => Any): Unit = {
    assert(types.contains(fieldName), s"Invalid field name $fieldName")
    assert(types(fieldName).isClassCompatible(fieldValue),
      s"Invalid class ${fieldValue.getClass.getSimpleName} for $fieldName")
    fields(fieldName) = fieldValue
  }

  def update(fieldName: String, representation: String): Unit =
    update(fieldName, types(fieldName).parse(representation))
}
