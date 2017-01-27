package jvmsnippets.xrecords.xtend.csv

import au.com.bytecode.opencsv.CSVReader
import java.io.Reader
import java.util.List
import jvmsnippets.xrecords.xtend.AbstractSource
import jvmsnippets.xrecords.xtend.Record
import jvmsnippets.xrecords.xtend.Source
import jvmsnippets.xrecords.xtend.field.IndexedField
import jvmsnippets.xrecords.xtend.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Delegate

/**
 * An implementation of `Source` that returns records drawn from a comma-separated (CSV) file.
 * Note that files can be delimited by characters other than comma as dictated by the `separator`
 * property defined by the `CSVBase` superclass.
*/
class CSVSource extends CSVBase implements Source {
  /**
   * A provider of `java.io.Reader` that returns a fresh reader on each invocation. This provider
    * points to a specific CSV file.
  */
  @Accessors Provider<Reader> input

  /**
   * The list of indexed fields contained in each CSV record. Indexed fields specify a position
   * witin their containing records as well as their data type-constrained parsers/formatters
  */
  @Accessors List<IndexedField<?extends Object>> fields

  /**
   * The abstract source on which to delegate the lifecycle of a file (`doOpen`, `next`,
   * `buildRecord` and `doClose`).
   *
   * This delegate is defined by the `@Delegate` active annotation so that `CSVSource` implements
    * `Source` by supplying the methods named above.
  */
  @Delegate Source delegate = new AbstractSource<CSVReader, String[]>() {
    /**
     * Open the `Reader` and return it.
     * @return The reader backing this `Source`
    */
    override CSVReader doOpen() {
      val lineCount = if(headerRecord) 1 else 0
      new CSVReader(input.provide, separator, quote, lineCount)
    }

    /**
     * Return the next input line returned by the `Reader`.
     *
     * @param reader The reader backing this `CSVSource`
     *
     * @return The fields extracted from the last line returned by the `Reader`.
    */
    override String[] next(CSVReader reader) {
      reader.readNext()
    }

    /**
     * Convert the current string array to a `Record` representation.
     *
     * @param fieldValues The current array of string to be made into a record
     *
     * @return The resulting `Record`
    */
    override Record buildRecord(String[] fieldValues) {
      val record = new Record

      fields.forEach [ field |
        val value = field.getValueFrom(fieldValues)
        record.setField(field.name, value)
      ]

      record
    }

    /**
     * Close the backing `Reader` on EOF.
    */
    override void doClose(CSVReader reader) {
      reader.close()
    }
  }
}