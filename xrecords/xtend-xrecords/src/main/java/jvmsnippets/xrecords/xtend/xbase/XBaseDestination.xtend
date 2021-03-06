package jvmsnippets.xrecords.xtend.xbase

import com.linuxense.javadbf.DBFField
import com.linuxense.javadbf.DBFWriter
import java.io.OutputStream
import jvmsnippets.xrecords.xtend.AbstractDestination
import jvmsnippets.xrecords.xtend.Destination
import jvmsnippets.xrecords.xtend.Record
import jvmsnippets.xrecords.xtend.util.Provider
import jvmsnippets.xrecords.xtend.xbase.XBaseDestination.DBFWriterState
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Delegate

// This XBase impl only supports double
// TODO Add file support to XBaseDestination
class XBaseDestination extends XBase implements Destination {
  @Accessors Provider<OutputStream> output
  @Accessors DBFField[] dbfFields

  @Data static class DBFWriterState {
    protected val OutputStream os
    protected val DBFWriter writer

    def addRecord(Object[] fieldValues) {
      writer.addRecord(fieldValues)
    }

    def close() {
      writer.write(os)
      os.flush()
      os.close()
    }
  }

  @Delegate Destination delegate = new AbstractDestination<DBFWriterState>() {
    override doOpen() {
      val os = output.provide
      val writer = new DBFWriter => [
        fields = dbfFields
      ]

      new DBFWriterState(os, writer)
    }

    override doPut(DBFWriterState writer, Record record) {
      val Object[] fieldValues = newArrayOfSize(dbfFields.length)

      for(i : 0 ..< dbfFields.length) {
        val fieldName = dbfFields.get(i).name
        if(record.hasField(fieldName)) {
          fieldValues.set(i, record.getField(fieldName))
        }
      }

      writer.addRecord(fieldValues)
    }

    override doClose(DBFWriterState writer) {
      writer.close()
    }
  }
}
