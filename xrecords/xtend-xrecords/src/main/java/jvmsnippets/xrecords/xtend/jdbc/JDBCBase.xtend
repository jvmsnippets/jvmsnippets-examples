package jvmsnippets.xrecords.xtend.jdbc

import javax.sql.DataSource
import org.eclipse.xtend.lib.annotations.Accessors

// Add suport for array fields jdbc
abstract class JDBCBase {
  @Accessors DataSource dataSource
}
