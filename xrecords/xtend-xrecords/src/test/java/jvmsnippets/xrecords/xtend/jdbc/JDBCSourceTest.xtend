package jvmsnippets.xrecords.xtend.jdbc

import org.junit.Test

import static org.junit.Assert.assertEquals

class JDBCSourceTest extends JDBCRecordTest {

  @Test
  def void retrievesAllRecords() {
    val people = #[
      new Person(1, 'John', 'Alexander', 'Doe', 'M'),
      new Person(2, 'Janet', 'Ellen', 'Doe', 'F'),
      new Person(3, 'Diego', 'Ivan', 'Stein', 'M')
    ]

    val statement = connection.prepareStatement('INSERT INTO person VALUES(?, ?, ?, ?, ?)')
    people.forEach[person |
      statement.clearParameters()
      statement.setInt(1, person.id)
      statement.setString(2, person.firstName)
      statement.setString(3, person.middleName)
      statement.setString(4, person.lastName)
      statement.setString(5, person.gender)
      statement.addBatch()
    ]
    statement.executeBatch()
    statement.close()

    val source = new JDBCSource => [
      sqlText = 'SELECT * FROM person ORDER BY id'
      dataSource = createDataSource()
    ]

    source.open()
    val records = IteratorExtensions.toList(source.map[it])
    source.close()

    val expectedRecords = people.map[toRecord]

    assertEquals(expectedRecords, records)
  }
}