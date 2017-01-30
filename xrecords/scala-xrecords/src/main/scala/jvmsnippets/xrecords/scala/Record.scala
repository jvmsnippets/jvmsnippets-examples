package jvmsnippets.xrecords.scala

import scala.collection.Map
import scala.collection.mutable.{Map => MMap}


trait RecordCopier extends Copier[Record, Record] {
  def transform: Record => Record = identity
}

/**
  *
  * Format-independent representation of a tabular destination.
  *
  * A ''tabular destination'' is a collection of named fields each holding a scalar
  * fieldValue.
  *
  * A *scalar fieldValue* can be:
  *
  * - A `String` fieldValue containing either a free-form string or the string
  * representation of a ''fieldValue type'' such as a `java.util.Date` or a
  * `java.math.BigDecimal`.
  * - Values of primitive types such as numeric type wrappers (`Integer`,
  * `Double`, etc.) or `Boolean` values (`true`, `false`)
  *
  * `Record` field values are all "flat": they must be representable as a
  * `String` and cannot nest. Thus, a `Record` cannot contain another `Record`
  * nor can it contain a complex object for which there's no appropriate `Parser`.
  *
  * A [[field/Parser.html `Parser`]] is an object capable of parsing a `String`
  * to yield a scalar fieldValue and formatting a scalar fieldValue to yield its `String`
  * representation. Xrecords comes equipped with parsers for `String`, `Integer`,
  * `Double`, `Boolean`, `BigDecimal` and `Date`. You can easily add your own.
  *
  * `Record` has methods to:
  *
  * - List all field names
  * - Get a field fieldValue given its fieldName (fails for non-existent fieldName)
  * - Set a field given its fieldName and fieldValue
  * - Remove a field given its fieldName (fails for non-existent fieldName)
  *
  * `Record` also provides methods to copy from/to another destination as well as
  * utility static methods to fromNumber to/from
  * [[https://docs.oracle.com/javase/8/docs/api/java/util/Map.html `Map`]]().
  *
  * @param map The underlying `Map` containing field names and values.
  */
case class Record(map: Map[String, Any] = Map.empty) {

  /**
    * The underlying `Map` containing field names and values.
    */
  private[scala] val fields: MMap[String, Any] =
    MMap[String, Any](map.toSeq: _*)

  /**
    * Return the `value` associated with the given `name`.
    *
    * `Name` must exist already in this `Record`.
    *
    * @param fieldName T%he name of the field to retrieve
    *
    * @return The field value asssociated with the given `name`
    */
  def apply[A](fieldName: String): Option[A] =
    fields.get(fieldName).asInstanceOf[Option[A]]

  /**
    * Set the field associated with `name` to the given `value`.
    * @param fieldName The field name
    * @param fieldValue The field value
    */
  def update(fieldName: String, fieldValue: Any): Unit =
    fields(fieldName) = fieldValue

  /**
   * Determine whether this `Record` contains a value with the given `name`.
   *
   * @param fieldName The field name whose occurence is to be ascertained
   *
   * @return Whether the given `name` corresponds to a field in this `Record`
  */
  def hasField(fieldName: String): Boolean =
    fields.contains(fieldName)

  /**
    * Removes a field given its `name`.
    *
    * @param fieldName The name of the field to be removed
    * @return An `Option[Any]` correspoding to the value associated with the
    *         removed key (if any)
    */
  def -=(fieldName: String): Option[Any] =
    fields.remove(fieldName)

  /**
    * Return the number of fields currently held in this `Record`.
    * @return The number of fields in this record
    */
  def size: Int =
    fields.size

  /**
    * Remove all fields in this `Record` at once.
    */
  def clear(): Unit =
    fields.clear()

  /**
    * Return all field names in this `Record` (in no particular order).
    *
    * @return The set of this `Record`'s field names.
    */
  def fieldNames: Set[String] =
    fields.keySet.toSet

  /**
    * Copy all fields in this `Record` onto the `destination` one, possibly overwriting
    * existing fields as well as adding new ones.
    *
    * @param destination The other `Record` to put fields onto
    *
    */
  def copyTo(destination: Record): Unit =
    fields.foreach { case (name, value) =>
      destination.fields.put(name, value)
    }

  /**
    * Copy all fields in the other `Record` onto this `Record`, possibly
    * overwriting equally named fields as well as adding new ones.
    *
    * @param source The other `Record` to draw fields from
    *
    */
  def copyFrom(source: Record): Unit =
    source.copyTo(this)

  /**
   * Return an mutable copy of the underlying `Map`
   *
   * @return The mutable copy of the underlying `Map`
  */
  def toMap: Map[String, Any] =
    fields.clone()
}
