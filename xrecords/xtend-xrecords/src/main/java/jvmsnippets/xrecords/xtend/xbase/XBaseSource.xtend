package jvmsnippets.xrecords.xtend.xbase

import com.linuxense.javadbf.DBFReader
import java.io.InputStream
import jvmsnippets.xrecords.xtend.AbstractSource
import jvmsnippets.xrecords.xtend.Record
import jvmsnippets.xrecords.xtend.Source
import jvmsnippets.xrecords.xtend.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Delegate

@Data class XBaseSourceState {
  InputStream is
  DBFReader reader

  def nextRecord() { reader.nextRecord() }
  def fieldName(int i) { reader.getField(i).name }
  def close() { is.close() }
}

// Test XBaseRecordSource
class XBaseSource extends XBase implements Source {
  @Accessors Provider<InputStream> input

  @Delegate Source delegate = new AbstractSource<XBaseSourceState, Object[]>() {
    override doOpen() {
      val is = input.provide
      new XBaseSourceState(is, new DBFReader(is))
    }

    override next(XBaseSourceState reader) {
      reader.nextRecord()
    }

    override buildRecord(Object[] fields) {
      val record = new Record

      for(i: 0 ..< fields.length) {
        val fieldName = state.fieldName(i)
        // TODO Add trimming option to XBaseSource
        val fieldValue = {
          val value = fields.get(i)
          if(value instanceof String) value.toString.trim
          else value
        }
        record.setField(fieldName, fieldValue)
      }

      record
    }

    override doClose(XBaseSourceState reader) {
      reader.close()
    }
  }
}