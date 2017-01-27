package jvmsnippets.xrecords.xtend.field

import java.util.List
import jvmsnippets.xrecords.xtend.Record
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * The simplest field metadata exposing a field's name only/
*/
class Field {
  /**
   * The field name as it will appear in a `Record` or in the different types of `Source` and
   * `Destination`.
  */
  @Accessors String name
}
/**
 * `Field` specialization that adds a `Parser` to the field name so that the field's typed
 * representation can be stored in and retrieved from `Record`s
*/
class FormattedField<T> extends Field {
  /**
   * The `Parser` instance to use in extracting a fields value from a `String` (method `parse`)
   * as well as to convert to a formatted `String` representation (method `format`).
   * @param T The field's type
  */
  @Accessors Parser<T> parser

  /**
   * Return an object representation of a `String`. Example: build a `java.util.Date`
   * representation from a properly formatted `String`.
   * @param s The string to be parsed
   * @return the object representation of the string as per the given parser
  */
  def Object fromString(String s) {
    parser.parse(s)
  }

  /**
   * Return a `String` representation from an object such that the object can be reconstructed by
    * means of `parse`.
    *
    * @param t The object to be represented as a `String`
    * @return The object represented as a `String`
  */
  def String toString(T t) {
    parser.format(t)
  }

  /**
   * Retrieve a formatted `String` representation of a field in a `Record`. If no such field
   * exists in the `Record` return an empty `String`.
   * @param record The record containing the desired field
   * @return The string representation of the field or the empty string if not present
  */
  def formatValueFrom(Record record) {
    val value = record.getField(name) as T
    if(value == null) ''
    else toString(value)
  }
}

/**
 * Specialization of `FormattedField` that adds the notion of field _position_ within its output
 * record.
 * @param T The field's type
*/
class IndexedField<T> extends FormattedField<T> {
  /**
   * The index of the field in the physical record (e.g. in a `CSVSource` or a `JDBCDestination`).
  */
  @Accessors int index

  /**
   * Given a list of field `String`s return the indexed field's object value.
   * @param list The ordered list of fields strings
   * @return the object field value extracted from the `list` at the given `index`
  */
  def Object getValueFrom(List<String> list) {
    fromString(list.get(index))
  }
}

/**
 * A specialization of `FormattedField` used for fixed-length records such as those produced by
 * mainframe and "mini" systems.
 * @param T The field's type
*/
class FixedField<T> extends FormattedField<T> {
  /**
   * The field's initial position in the record
  */
  @Accessors int offset

  /**
   * The field's length after the field's initial position.
  */
  @Accessors int length

  /**
   * Return an object from the array of characters contained in the fixed record, starting at
   * its `offset` and  extending for `length` positions.
   * @param char The `char` array containing the fixed record
   * @return The Object representation of the field as given by its associated `parser`
  */
  def Object get(char[] chars) {
    fromString(new String(chars, offset, length))
  }

  /**
   * Put a field object value at the proper position of a fixed-length record given the `char`
   * array associated with the fixed record.
   * @param t The field's object value
   * @param chars The `char` array containing the fixed-length record
  */
  def void put(T t, char[] chars) {
    val parsedChars = toString(t).toCharArray
    if(parsedChars.length > length) {
      throw new IllegalArgumentException(
            '''Formatted length («parsedChars.length» exceeds configured field length («length»)''')
    }
    System.arraycopy(parsedChars, 0, chars, offset, Math.min(length, parsedChars.length))
  }
}
