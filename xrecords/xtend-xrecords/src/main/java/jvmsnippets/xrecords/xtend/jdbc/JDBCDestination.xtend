package jvmsnippets.xrecords.xtend.jdbc

import java.sql.PreparedStatement
import java.sql.SQLException
import java.util.List
import java.util.concurrent.atomic.AtomicInteger
import jvmsnippets.xrecords.xtend.AbstractDestination
import jvmsnippets.xrecords.xtend.Destination
import jvmsnippets.xrecords.xtend.Record
import jvmsnippets.xrecords.xtend.jdbc.JDBCDestination.JDBCDestinationState
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Delegate
import org.slf4j.Logger
import org.slf4j.LoggerFactory

// TODO Allow for field names to be set from first record
class JDBCDestination extends JDBCBase implements Destination {
  @Accessors String tableName
  @Accessors List<String> fieldNames

  @Accessors int batchSize = 1
  @Accessors boolean commitOnBatch = false

  private static Logger logger = LoggerFactory.getLogger(JDBCDestination)

  static class JDBCDestinationState {
    var index = 0
    protected val PreparedStatement statement

    new(PreparedStatement statement) {
      this.statement = statement
    }

    def nextIndex() {
      index += 1
      index
    }
  }

  @Delegate Destination delegate = new AbstractDestination<JDBCDestinationState>() {

    val AtomicInteger recordsRead = new AtomicInteger(0);

    override doOpen() {
      val connection = dataSource.connection
      new JDBCDestinationState(connection.prepareStatement(preparedInsert))
    }

    override doPut(JDBCDestinationState state, Record record) {
      val metaData = state.statement.metaData
      try {
        for(i: 0 ..< fieldNames.length) {
          val fieldValue = record.getField(fieldNames.get(i))

          if(fieldValue != null) {
            state.statement.setObject(i + 1, fieldValue)
          } else {
            if(metaData != null) {
              state.statement.setNull(i + 1, metaData.getColumnType(i + 1))
            } else {
              state.statement.setObject(i + 1, null)
            }
          }
        }

        state.statement.addBatch()

        val index = state.nextIndex()
        if(index % batchSize == 0) {
          if(batchSize > 1 && logger.debugEnabled)
            logger.debug('''Batch execution point reached: «index»''')

          state.statement.executeBatch()

          if(commitOnBatch) {
            state.statement.connection.commit()
          }
        }
      } catch(SQLException e) {
        val exception = e?.getNextException ?: e
        logger.warn('''Error inserting batch: «exception.getMessage»''', exception)
        throw e
      }
    }

    override doClose(JDBCDestinationState state) {
      val statement = state.statement
      val connection = state.statement.connection

      if(recordsRead.incrementAndGet % batchSize != 0) {
        statement.executeBatch()
      }

      connection.commit()

      statement.close()
      connection.close()
    }
  }

  private var String _preparedInsert
  private def getPreparedInsert() {
    if(_preparedInsert == null) {
      _preparedInsert = buildPreparedInsert(tableName, fieldNames)
    }
    _preparedInsert
  }

  static def String buildPreparedInsert(String tableName, List<String> fieldNames) {
    '''
        INSERT INTO "«tableName»"(«fieldNames.map['''"«it»"'''].join(', ')»)
        VALUES(«(0 ..< fieldNames.size).map['?'].join(', ')»)
    '''
  }
}