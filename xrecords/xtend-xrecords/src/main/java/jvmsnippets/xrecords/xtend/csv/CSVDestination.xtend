package jvmsnippets.xrecords.xtend.csv

import au.com.bytecode.opencsv.CSVWriter
import java.io.Writer
import java.util.List
import jvmsnippets.xrecords.xtend.AbstractDestination
import jvmsnippets.xrecords.xtend.Destination
import jvmsnippets.xrecords.xtend.Record
import jvmsnippets.xrecords.xtend.field.FormattedField
import jvmsnippets.xrecords.xtend.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Delegate


/**
 * An implementation of `Destination` that writes incoming records to a comma-separated (CSV) file.
 *
 * Note that output files can be delimited by characters other than comma as dictated by the
 * `separator` property defined by the `CSVBase` superclass.
*/
class CSVDestination extends CSVBase implements Destination {
  /**
   * The provider of `java.io.Writer` that will return a fresh writer on each invocation. This
   * provider points to a specific output file.
  */
  @Accessors Provider<Writer> output

  /**
   * The list of indexed fields contained in each output CSV record. Indexed fields specify a
   * position witin the output records as well as their data type-constrained parsers/formatters.
  */
  @Accessors List<FormattedField<?extends Object>> fields

  /**
   * The abstract destination on which to delegate the lifecycle of a file (`doOpen`, `doPut` and
   * `doClose`).
   *
   * This delegate is defined by the `@Delegate` active annotation so that `CSVDestination`
   * implements `Destination` by supplying the methods named above.
  */
  @Delegate Destination delegate = new AbstractDestination<CSVWriter> {

    /**
      * Open the `Writer` and return it.
      * @return The reader backing this `Destination`
    */
    override CSVWriter doOpen() {
      val writer = new CSVWriter(output.provide, separator, quote)

      if(headerRecord) {
        val String[] headers = newArrayOfSize(fields.size)
        (0 ..< fields.size).forEach [ i |
          headers.set(i, fields.get(i).name)
        ]
        writer.writeNext(headers);
      }

      writer
    }

    /**
     * Put a `Record` onto the backing `CSVWriter` in accordance with the field configuration
     *
     * @param writer The underlying `CSVWriter` instance
     * @param record The record from which to draw the field names and values from
    */
    override void doPut(CSVWriter writer, Record record) {
      val String[] recordValues = newArrayOfSize(fields.size)

      (0 ..< fields.size).forEach [ i |
        recordValues.set(i, fields.get(i).formatValueFrom(record))
      ]

      writer.writeNext(recordValues)
    }

    /**
     * Dispose of the backing `CSVWriter` once all `Records` have been output.
     * @param writer The `CSVWriter` backing this `CSVDestination`.
    */
    override void doClose(CSVWriter writer) {
      writer.close()
    }
  }
}