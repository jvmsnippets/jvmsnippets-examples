package jvmsnippets.xrecords.xtend.fixed

import jvmsnippets.xrecords.xtend.Record
import jvmsnippets.xrecords.xtend.field.DoubleParser
import jvmsnippets.xrecords.xtend.field.FixedField
import jvmsnippets.xrecords.xtend.field.IntegerParser
import jvmsnippets.xrecords.xtend.field.StringParser
import jvmsnippets.xrecords.xtend.io.StringReaderProvider
import org.junit.Test

import static jvmsnippets.xrecords.xtend.util.Extensions.*
import static org.junit.Assert.*

class FixedSourceTest {
  @Test
  def void readsRecordsProperly() {
    val inputRecords = '''
            123Bolts x 10              0012000245
            234Eau de Perrier          2000000075
            345Acqua Pellegrino        0520000055
            456Caturro Coffee          0032015024
        '''.toString.replaceAll('\\r?\\n', '')

    val source = new FixedSource => [
      length = 37
      fields = cast(#[
        new FixedField => [
          name = 'code'
          parser = new IntegerParser('000')
          offset = 0
          length = 3
        ],
        new FixedField => [
          name = 'desc'
          parser = new StringParser
          offset = 3
          length = 24
        ],
        new FixedField => [
          name = 'qty'
          parser = new IntegerParser('0000')
          offset = 27
          length = 4
        ],
        new FixedField => [
          name = 'price'
          parser = new DoubleParser('000000', 100)
          offset = 31
          length = 6
        ]
      ])

      input = new StringReaderProvider(inputRecords)
    ]

    val expectedRecords = #[
      new Record => [
        setField('code', 123)
        setField('desc', 'Bolts x 10')
        setField('qty', 12)
        setField('price', 2.45)
      ],
      new Record => [
        setField('code', 234)
        setField('desc', 'Eau de Perrier')
        setField('qty', 2000)
        setField('price', 0.75)
      ],
      new Record => [
        setField('code', 345)
        setField('desc', 'Acqua Pellegrino')
        setField('qty', 520)
        setField('price', 0.55)
      ],
      new Record => [
        setField('code', 456)
        setField('desc', 'Caturro Coffee')
        setField('qty', 32)
        setField('price', 150.24)
      ]
    ]

    source.open()
    val actualRecords = source.toList
    source.close()

    assertEquals(expectedRecords, actualRecords)
  }
}