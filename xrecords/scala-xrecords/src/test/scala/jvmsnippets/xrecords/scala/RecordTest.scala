package jvmsnippets.xrecords.scala

import java.time.LocalDate

import utest._

/**
  * `Record` unit tests.
  */
class RecordTest extends TestSuite {
  val tests = this {

    'populatesFieldsFromMap {
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

    'seesFieldNameAfterAddition {
      val record = Record()

      assert(!record.hasField("lastName"))

      record("lastName") = "Doe"

      assert(record.hasField("lastName"))
    }

    'setsAndGetsFieldValue {
      val record = Record()

      assert(record("lastName").isEmpty)

      record("lastName") = "Doe"

      assert(record("lastName").contains("Doe"))
    }

    'removesField {
      val record = Record()
      assert(!record.hasField("year"))

      record("year") = 2017

      assert(record.hasField("year"))
      assert(record("year") contains 2017)

      assert((record -= "year") contains 2017)

      assert(!record.hasField("year"))
      assert(!record("year").contains(2017))
    }

    'returnsDestinationSizeAsFieldCount {

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

    'clearsAllElements {

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

    'listsAllFieldNames {

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

    'copiesToDestinationRecord {

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

    'CopyToDestinationRecordOverwritesExistingFieldsAndPreservesRemainingOnes {

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

    'copyFromSourceRecordOverwritesExistingFieldsAndPreservesRemainingOnes {

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

    'copiesFromSourceRecord {

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
      assert(destinationRecord("name") contains name)
      assert(destinationRecord("dob").contains(dob))
      assert(destinationRecord("gender").contains(gender))

      assert(sourceRecord.size == 3)
    }

    'convertsRecordToMap {

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
}
