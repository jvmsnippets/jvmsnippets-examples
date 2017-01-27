package jvmsnippets.xrecords.xtend.field

import java.math.BigDecimal
import java.text.DecimalFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * A component capable of converting an object into a `String` (formatting) representation such that
 * the original object can be reconstructed from the `String` representation (parsing)
 * @param T The parser's target data type
*/
interface Parser<T> {
  /**
   * Read a `String` value so as to build an object from it (parsing)
   * @param string The `String` to be converted into a `T`
   * @return An instance fo the parser's target data type
  */
  def T parse(String string)

  /**
   * Read a `T` instance so as to build an equivalent `String` representation that can be
   * subsequently parsed to rebuild the same `T` instance.
   * @param item The `T` instance to be converted to `String`
   * @return The `String` representation of the `T` instance
  */
  def String format(T item)
}

/**
 * A `Parser` that converts between `String` and `Boolean`. This implementation supports the most
  * commonly used forms of representing a `Boolean` value as a `String` (true/false, yes/no, on/off)
*/
class BooleanParser implements Parser<Boolean> {
  /**
   * Configurable default representation of the `true` boolean value
  */
  @Accessors String trueRepresentation = 'true'

  /**
   * Configurable default representation of the `false` boolean value
  */
  @Accessors String falseRepresentation = 'false'

  /**
   * Configurable mapping of `String` to Boolean`
  */
  @Accessors Map<String, Boolean> representations = # {
    'true'  -> true,
    'false' -> false,
    'yes'   -> true,
    'no'    -> false,
    'on'    -> true,
    'off'   -> false
  }

  /**
   * Convert a `String` into it correspoding `Boolean` value.
   * @param string The string to be made into a `Boolean`
   * @return The `Boolean` value associated with the given `string`
  */
  override Boolean parse(String string) {
    try {
      representations.get(string.toLowerCase).booleanValue
    } catch(NullPointerException npe) {
      throw new IllegalArgumentException('''Invalid boolean value: «string»''')
    }
  }

  /**
   * Convert a `Boolean` value into the default `String` representation.
   * @param item The `Boolean` to be converted to `String`
   * @return The `String` corresponding to the given `Boolean` item
  */
  override String format(Boolean item) {
    if (item) trueRepresentation
    else falseRepresentation
  }
}

/**
 * Base class for all numeric parsers.
 * @param N The primitive wrapper type extending `Number`. This can be `Byte`, `Char`, `Int`,
 * `Short`, `Long`, `Float` and`Double`.
*/
abstract class NumericParser<N extends Number> {
  /**
   * The instance of `java.text.DecimalFormat` to be used in actual conversions from/to `Number`
   * and `String`.
  */
  protected val DecimalFormat format

  /**
   * Method to be implemented by subclasses to set the `DecimalFormat`'s instance in accordance
   * with the subclasses' concrete `Number` types.
   * @param format The `DecimalFormat` to be configured
  */
  abstract def void configureFormat(DecimalFormat format)

  /**
   * Constructor providing a valid _pattern_ as specified by `DecimalFormat`
   * @param pattern The string containing the `DecimalFormat` symbols required by this parser
  */
  new(String pattern) {
    this(pattern, 1)
  }

  /**
   * Constructor variant where -in addition to the symbol pattern- the `DecimalFormat` also has a
    * multiplier.
    * @param pattern The `DecimalFormat` pattern
    * @multiplier The decimal factor used to rewrite values
  */
  new(String pattern, int multiplier) {
    format = new DecimalFormat(pattern)
    format.multiplier = multiplier
    configureFormat(format)
  }

  /**
   * Parse a string returning this parser's' `Number` subclasses.
   * @param string The string to be converted to `N`
   * @return the `N` value parsed from the given `string`
  */
  def N parse(String string) {
    cast(format.parse(string))
  }

  /**
   * Format an instance of `N` from a string value.
   * @param The string value to be converted to a `Number` concrete class
   * @return The valuue of the `N` instance constructed from the given string `value`
  */
  def String format(N value) {
    format.format(value)
  }

  /**
   * Utility method to cast from `Number` to one of its concrete subclasses.
   * @param value the input `Number`
   * @return The same input `Number` cast to the `N` `Number` subclass
  */
  def N cast(Number value) {
    value as N
  }
}

/**
 * Specialization of `NumericParser` for `Integer` values.
*/
class IntegerParser extends NumericParser<Integer> implements Parser<Integer> {
  /**
   * Empty constructor uses 12 integer digits
  */
  new() { super('##########') }

  /**
   * Pattern-based constructor (delegates to parent class)
  */
  new(String pattern) { super(pattern) }

  /**
   * Pattern and multiplier constructor (delegates to parent class)
  */
  new(String pattern, int multiplier) { super(pattern, multiplier) }

  /**
   * Configure the `DecimalFormat` instance so it conforms to `Integer` parsing/formatting. This
   * involves:
   *
   * - Setting the parseIntegerOnly to true
   * - Setting the parseBigDecimal to false
   *
   * @param format The `DecimalFormat` mask
  */
  override void configureFormat(DecimalFormat format) {
    format => [
      parseIntegerOnly = true
      parseBigDecimal = false
    ]
  }

  /**
   * Utility cast method that converts any `Number` to its `Integer` form via the `intValue` method.
   * @param value the `Number` value
   * @return The `Integer` value
  */
  override cast(Number value) { value.intValue }
}

/**
 *  Specialization of `NumericParser` for `Double` values.
*/
class DoubleParser extends NumericParser<Double> implements Parser<Double> {

  /**
   * Empty constructor uses 14 integer digits and 2 decimal digits
  */
  new() { super('############.##') }

  /**
   * Pattern-based constructor (delegates to parent class)
  */
  new(String pattern) { super(pattern) }

  /**
   * Pattern and multiplier constructor (delegates to parent class)
  */
  new(String pattern, int multiplier) { super(pattern, multiplier) }

  /**
   * Configure the `DecimalFormat` instance so it conforms to `Double` parsing/formatting. This
   * involves:
   *
   * - Setting the parseIntegerOnly to false
   * - Setting the parseBigDecimal to false
   *
   * @param format The `DecimalFormat` mask
  */
  override configureFormat(DecimalFormat format) {
    format => [
      parseIntegerOnly = false
      parseBigDecimal = false
    ]
  }

  /**
   * Utility cast method that converts any `Number` to its double form via the `doubleValue` method.
   * @param value the `Number` value
   * @return The `Double` value
  */
  override cast(Number value) { value.doubleValue }
}

/**
 *  Specialization of `NumericParser` for `BigDecimal` values.
*/
class BigDecimalParser extends NumericParser<BigDecimal> implements Parser<BigDecimal> {

  /**
   * Empty constructor uses 12 integer digits and 2 decimal digits
  */
  new() { super('############.##') }

  /**
   * Pattern-based constructor (delegates to parent class)
  */
  new(String pattern) { super(pattern) }

  /**
   * Pattern and multiplier constructor (delegates to parent class)
  */
  new(String pattern, int multiplier) { super(pattern, multiplier) }

  /**
   * Configure the `DecimalFormat` instance so it conforms to `BigDecimal` parsing/formatting. This
   * involves:
   *
   * - Setting the parseIntegerOnly to false
   * - Setting the parseBigDecimal to true
   *
   * @param format The `DecimalFormat` mask
  */
  override configureFormat(DecimalFormat format) {
    format => [
      parseIntegerOnly = false
      parseBigDecimal = true
    ]
  }
}

/**
 *  Specialization of `Parser` for `java.util.Date` values.
*/
class DateParser implements Parser<Date> {
  /**
   * The `SimpleDateFormat` instance to be used in actual parsing/formatting
  */
  val SimpleDateFormat format

  /**
   * Default constructor: uses `dd/MM/yyyy`
  */
  new() {
    this('dd/MM/yyyy')
  }

  /**
   * Pattern constructor: builds an instance of `SimpleDateFormat` with the given symbol pattern.
   * @ pattern The date pattern to be used by this parser
  */
  new(String pattern) {
    format = new SimpleDateFormat(pattern)
  }

  /**
   * Parse a `String` and return its `Date` representation in accordance to this parser's pattern
   * @param string the `String` containing the date to be parsed
   * @return The parsed `Date`
  */
  override Date parse(String string) {
    format.parse(string)
  }

  /**
   * Format a `Date` value as a `String` in accordance to this parser's pattern
   * @param value The date to be represented as a `String`
   * @return the String representation of the given `Date` value
  */
  override String format(Date value) {
    format.format(value)
  }
}

/**
 * Specialization of `Parser` for `String` values. Since both `format` and `parse` consume and
 * yield `String`a this class exists mostly as a placeholder to specify `String` field types in
 * `Record`, `Source` and `Destination` definitions.
*/
class StringParser implements Parser<String> {
  /**
   * The empty constructor
  */
  new() {
  }

  /**
   * A constructor specifying a pattern that is actually ignored
  */
  new(String pattern) {
  }

  /**
   * Parse a string: returns the same, unchanged string
   * @param string The input `String`
   * @return The same input `String`
  */
  override String parse(String string) {
    string
  }

  /**
   * Format a string: returns the same, unchanged string
   * @param string The input `String`
   * @return The same input `String`
  */
  override String format(String string) {
    string
  }
}
