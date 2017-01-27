package jvmsnippets.xrecords.xtend.csv

import au.com.bytecode.opencsv.CSVWriter
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * The base class for both `CSVSource` and `CSVDestination`.
 * This class captures the properties common to both CSV components:
 *
 * - `separator`: the separator character to be used in splitting CSV records into fields.
 *   Defaults to comma (`,`)
 * - `headerRecord`: an indication of whether the first cored in the file contains headers rather
 *   than data
 * - `quote`: the character used to enclose occurrences of the separator character that would
 *   otherwise be interpreted as a field delimiter. Defaults to double quote (`"`). Be aware that
  *   this choice implies header field names will need to be enclosed in double quotes.
*/
abstract class CSVBase {
  /**
   * The separator character used to split lines into field arrays. While the separator defaults
   * to comma, any suitable character will do (tab, pipe, semi-colon, etc.)
  */
  @Accessors char separator = ','

  /**
   * The header record indicator. When set, the first record will be deemed to contain field
   * names and will be subsequently ignored (not interpreted as data)
  */
  @Accessors boolean headerRecord = false

  /**
   * The quote character used to escape occurrences of the separator character inside field data.
   * This causes the quoted data not to be interpreted as a separator bur rather as part of the
   * current field's data.
   *
   * Default to double quote (`"`)
  */
  @Accessors char quote = CSVWriter.DEFAULT_QUOTE_CHARACTER
}