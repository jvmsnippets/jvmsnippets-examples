package jvmsnippets.xrecords.xtend.fixed

import java.io.IOException
import java.io.Reader
import jvmsnippets.xrecords.xtend.AbstractSource
import jvmsnippets.xrecords.xtend.Record
import jvmsnippets.xrecords.xtend.Source
import jvmsnippets.xrecords.xtend.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Delegate

/**
 * A `Reader`/buffer pair containing an active `java.io.Reader` and the character array (`buffer`) last
 * read by the reader.
*/
@Data class ReaderBuffer {
  /**
   * The `Reader` used to read each fixed-length record
  */
  Reader in

  /**
   * The buffer from which each fixed-length record is read. This `char` array is dimensioned as
   * the record length.
  */
  char[] buffer

  /**
   * Read the next fixed-length record and store in the `buffer`.
   * @return The number of bytes actually read. In a well-formed fixed-length file this count
   * should coincide withe the record length.
  */
  def read() { in.read(buffer) }

  /**
   * Close the `reader` after all records have been read from the fixed-legth file.
  */
  def close() { in.close() }
}

// Test FixedRecordSource
/**
 * The fixed-length record `Source`. This class extends `FixedBase` to add the behavior defined
 * by `Source`, which is implemented via the @Delegate macro.
*/
class FixedSource extends FixedBase implements Source {
  /**
   * The provider of the `Reader` used to consume records from the fixed-length file.
  */
  @Accessors Provider<Reader> input

  /**
   * Implements the `Source` interface via delegation. Because delegation is based on an abstract
   * class, tis class must provide implementation for its missing methods (`doOpen()`, `next()`,
   * `buildRecord()` and `doClose()`)
  */
  @Delegate Source delegate = new AbstractSource<ReaderBuffer, char[]>() {
    /**
     * Open the reader using the `providder`. Note that ths state kept for this class is not just
      * the `Reader` but also its read buffer (class `ReaderBuffer`).
    */
    override doOpen() {
      new ReaderBuffer(input.provide, newCharArrayOfSize(length))
    }

    /**
     * Actually read the next element using the `ReaderBuffer` instance. This implementation
     * checks that _all_ reads (including the last one) return as many characters as the stated
     * file's lengh
    */
    override next(ReaderBuffer reader) {
      val count = reader.read()

      switch count {
        case count <= 0: null
        case length: reader.buffer
        default:
          throw new IOException('''Premature end of file. Expected «length» chars, got «count»''')
      }
    }

    /**
     * Build a canonical `Record` representation from the fixed-length string just read from the
     * fixed-length file.
     * @return The newly created `Record`
    */
    override Record buildRecord(char[] buffer) {
      val record = new Record

      fields.forEach [ field |
        val fieldString = new String(buffer, field.offset, field.length)
        val fieldValue = field.fromString(fieldString.trim)
        record.setField(field.name, fieldValue)
      ]

      record
    }

    /**
     * Close the unerlying `Reader` after all fixed-length record have been read and processed.
    */
    override doClose(ReaderBuffer reader) {
      reader.close()
    }
  }
}