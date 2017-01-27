package jvmsnippets.xrecords.scala

import java.time.LocalDate

import org.scalatest.FunSuite

/**
  * `Record` unit tests.
  */
class RecordTest extends FunSuite {
  test("Populates fields from map") {

    val name = "John Doe"
    val dob = LocalDate.of(1999, 11, 24)
    val gender = "male"

    val map = Map(
      "name" -> name,
      "dob" -> dob,
      "gender" -> gender
    )

    val record = Record(map)

    assert(record.fields.size == 3)
    assert(record.fields("name") == name)
    assert(record.fields("dob") == dob)
    assert(record.fields("gender") == gender)
  }

  test("Sees field name after addition") {
    val record = Record()

    assert(!record.hasField("lastName"))

    record("lastName") = "Doe"

    assert(record.hasField("lastName"))
  }

  test("Sets and gets field value") {
    val record = Record()

    assert(record("lastName").isEmpty)

    record("lastName") = "Doe"

    assert(record("lastName").contains("Doe"))
  }

  test("Removes field") {
    val record = Record()
    assert(!record.hasField("year"))

    record("year") = 2017

    assert(record.hasField("year"))
    assert(record("year") contains 2017)

    assert((record -= "year") contains 2017)

    assert(!record.hasField("year"))
    assert(!record("year").contains(2017))
  }

  test("Returns destination size as number of fields") {

    val name = "John Doe"
    val dob = LocalDate.of(1999, 11, 24)
    val gender = "male"

    val record = Record()
    assert(record.size == 0)

    record("name") = name
    assert(record.size == 1)

    record("dob") = dob
    assert(record.size == 2)

    record("gender") = gender
    assert(record.size == 3)
  }

  test("Clears all elements") {

    val name = "John Doe"
    val dob = LocalDate.of(1999, 11, 24)
    val gender = "male"

    val map = Map(
      "name" -> name,
      "dob" -> dob,
      "gender" -> gender
    )

    val record = Record(map)
    assert(record.fieldNames.size == 3)

    record.clear()
    assert(record.fieldNames.isEmpty)
  }

  test("Lists field names") {

    val name = "John Doe"
    val dob = LocalDate.of(1999, 11, 24)
    val gender = "male"

    val record = Record()

    record("name") = name
    assert(record.fieldNames == Set("name"))

    record("dob") = dob
    assert(record.fieldNames == Set("name", "dob"))

    record("gender") = gender
    assert(record.fieldNames == Set("name", "dob", "gender"))
  }

  test("Copies to destination record") {

    val name = "John Doe"
    val dob = LocalDate.of(1999, 11, 24)
    val gender = "male"

    val map = Map(
      "name" -> name,
      "dob" -> dob,
      "gender" -> gender
    )

    val sourceRecord = Record(map)
    assert(sourceRecord.size == 3)

    val destinationRecord = Record()
    destinationRecord("time") = "12:00pm"
    assert(destinationRecord.size == 1)

    sourceRecord.copyTo(destinationRecord)
    assert(destinationRecord.size == 4)
    assert(destinationRecord("name").contains(name))
    assert(destinationRecord("dob").contains(dob))
    assert(destinationRecord("gender").contains(gender))

    assert(sourceRecord.size == 3)
  }

  test("Copy to destination record overwrites existing fields and preserves remaining ones") {

    val sourceRecord = Record(Map(
      "name" -> "John Doe",
      "dob" -> LocalDate.of(1999, 11, 24),
      "gender" -> "male"
    ))
    assert(sourceRecord.fieldNames == Set("name", "dob", "gender"))

    val destinationRecord = Record(Map(
      "name" -> "Jack the Knife",
      "gender" -> "male",
      "address" -> "123 Elm St"
    ))
    assert(destinationRecord.fieldNames == Set("name", "gender", "address"))

    sourceRecord.copyTo(destinationRecord)

    assert(destinationRecord.fieldNames == Set("name", "dob", "gender", "address"))
    assert(destinationRecord("name").contains("John Doe"))
    assert(destinationRecord("gender").contains("male"))
    assert(destinationRecord("dob").contains(LocalDate.of(1999, 11, 24)))
    assert(destinationRecord("address").contains("123 Elm St"))

    assert(sourceRecord.fieldNames == Set("name", "dob", "gender"))
    assert(sourceRecord("name").contains("John Doe"))
    assert(sourceRecord("gender").contains("male"))
    assert(sourceRecord("dob").contains(LocalDate.of(1999, 11, 24)))
  }

  test("Copy from source record overwrites existing fields and preserves remaining ones") {

    val sourceRecord = Record(Map(
      "name" -> "Jack the Knife",
      "gender" -> "male",
      "address" -> "123 Elm St"
    ))
    assert(sourceRecord.fieldNames == Set("name", "gender", "address"))

    val destinationRecord = Record(Map(
      "name" -> "John Doe",
      "dob" -> LocalDate.of(1999, 11, 24),
      "gender" -> "male"
    ))
    assert(destinationRecord.fieldNames == Set("name", "dob", "gender"))

    destinationRecord.copyFrom(sourceRecord)

    assert(destinationRecord.fieldNames == Set("name", "dob", "gender", "address"))
    assert(destinationRecord("name").contains("Jack the Knife"))
    assert(destinationRecord("gender").contains("male"))
    assert(destinationRecord("dob").contains(LocalDate.of(1999, 11, 24)))
    assert(destinationRecord("address").contains("123 Elm St"))

    assert(sourceRecord.fieldNames == Set("name", "gender", "address"))
    assert(sourceRecord("name").contains("Jack the Knife"))
    assert(sourceRecord("gender").contains("male"))
    assert(sourceRecord("address").contains("123 Elm St"))
  }

  test("Copies from source record") {

    val name = "John Doe"
    val dob = LocalDate.of(1999, 11, 24)
    val gender = "male"

    val map = Map(
      "name" -> name,
      "dob" -> dob,
      "gender" -> gender
    )

    val destinationRecord = Record()
    destinationRecord("time") = "12:00pm"
    assert(destinationRecord.size == 1)

    val sourceRecord = Record(map)
    assert(sourceRecord.size == 3)

    destinationRecord.copyFrom(sourceRecord)
    assert(destinationRecord.size == 4)
    assert(destinationRecord("name") contains name )
    assert(destinationRecord("dob").contains(dob))
    assert(destinationRecord("gender").contains(gender))

    assert(sourceRecord.size == 3)
  }

  test("Converts record to map") {

    val name = "John Doe"
    val dob = LocalDate.of(1999, 11, 24)
    val gender = "male"

    val map = Map(
      "name" -> name,
      "dob" -> dob,
      "gender" -> gender
    )

    val record = Record(map)
    assert(record.size == 3)

    val resultMap = record.toMap
    assert(record.fields == resultMap)
  }
}
