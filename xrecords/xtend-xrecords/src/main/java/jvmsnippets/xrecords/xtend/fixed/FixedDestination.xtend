package jvmsnippets.xrecords.xtend.fixed

import java.io.Writer
import java.util.Arrays
import jvmsnippets.xrecords.xtend.AbstractDestination
import jvmsnippets.xrecords.xtend.Destination
import jvmsnippets.xrecords.xtend.Record
import jvmsnippets.xrecords.xtend.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Delegate

/**
 * A `Writer`/buffer pair containing an active `java.io.Writer` and the character array (`buffer`) last
 * written by the writer.
*/
@Data class WriterBuffer {
  /*
   * The writer used to write fixed-length records onto the output file. Note this doesn't
   * necessarily append a newline to each record.
  */
  Writer out
  /**
   * The buffer onto which each fixed-length record is writen. This `char` array is dimensioned as
   * the record length.
  */
  char[] buffer

  /**
   * Write the next fixed-length record stored in the `buffer`.
   * After writing the buffer it is blanked out so as to ensure each new record doesn't carry any
    * bagagge from the previous one.
  */
  def write() {
    out.write(buffer)
    Arrays.fill(buffer, ' ')
  }

  /**
   * Close the `writer` after having written out all fixed-length record.
  */
  def close() {
    out.close()
  }
}

/**
 * The fixed-length record `Destination` that writes incoming `Record`s to a fixed-length file.
 *. This class extends `FixedBase` to add the behavior defined by `Destination`, which is
 * implemented via the @Delegate macro.
*/
class FixedDestination extends FixedBase implements Destination {
  /**
   * The provider of the `Writer` used to write fixed-length records.
  */
  @Accessors Provider<Writer> output

  /**
   * Implements the `Destination` interface via delegation. Becaue delegation is based on an
   * abstract class, tis class must provide implementation for its missing methods (`doOpen()`,
   * `doPut()` and `doClose()`)
  */
  @Delegate Destination delegate = new AbstractDestination<WriterBuffer> {
    /**
     * Create and return a new instance of `WriterBuffer`.
     * @return the `WriteBuffer` to be subsequently used in writing `Records`s onto a
     * fixed-length file.
    */
    override doOpen() {
      val buffer = newCharArrayOfSize(length)
      Arrays.fill(buffer, ' ')
      new WriterBuffer(output.provide, buffer)
    }

    /**
     * Actually put a `Record` onto the output stream.
    */
    override doPut(WriterBuffer writer, Record record) {
      fields.forEach [ field |
        val fieldValue = record.getField(field.name)
        field.put(fieldValue, writer.buffer)
      ]
      writer.write()
    }

    /**
     * Close the `WriterBuffer` after all `Record`s have been written onto the fixed-length file.
    */
    override doClose(WriterBuffer writer) {
      writer.close()
    }
  }
}