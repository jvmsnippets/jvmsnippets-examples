package jvmsnippets.xrecords.xtend.jdbc

import java.sql.ResultSet
import jvmsnippets.xrecords.xtend.AbstractSource
import jvmsnippets.xrecords.xtend.Record
import jvmsnippets.xrecords.xtend.Source
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Delegate

class JDBCSource extends JDBCBase implements Source {
  @Accessors String sqlText

  @Delegate Source delegate = new AbstractSource<ResultSet, ResultSet>() {
    override doOpen() {
      val connection = dataSource.connection
      val statement = connection.createStatement()
      statement.executeQuery(sqlText)
    }

    override next(ResultSet resultSet) {
      if(resultSet.next()) resultSet else null
    }

    override def buildRecord(ResultSet resultSet) {
      val metaData = resultSet.metaData
      val columnCount = metaData.columnCount

      val record = new Record()

      (1.. columnCount).forEach[ i |
        record.setField(metaData.getColumnLabel(i), resultSet.getObject(i))
      ]

      record
    }

    override doClose(ResultSet resultSet) {
      val statement = resultSet.statement
      val connection = statement.connection
      resultSet.close()
      statement.close()
      connection.close()
    }
  }

  override remove() {
    throw new UnsupportedOperationException('Unimplemented: remove JDBCRecordSource')
  }
}
