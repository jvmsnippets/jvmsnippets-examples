package jvmsnippets.xrecords.xtend.script

import java.util.Map
import jvmsnippets.xrecords.xtend.Record
import org.junit.Test

import static org.junit.Assert.*

class ScriptTest {
  @Test
  def void runsScript() {
    val Map<String, ?extends Object> scriptBindings = # { 'lower' -> 0}
    val Map<String, ?extends Object> executionBindings = # { 'upper' -> 42}
    val script = new Script('lower < upper', scriptBindings)
    assertTrue(script.execute(executionBindings) as Boolean)
  }

  @Test
  def void matches() {
    val script = new ScriptingFilter => [
      script = 'id > 0'
      language = 'javascript'
    ]
    val record = new Record => [
      setField('id', 123)
    ]
    assertTrue(script.matches(record))
  }

  @Test
  def void transforms() {
    val script = new ScriptingTransformer => [
      script = '({code: id * 2})'
      language = 'javascript'
    ]

    val inputRecord = new Record => [
      setField('id', 123d)
    ]

    val expectedRecord = new Record => [
      setField('code', 246d)
    ]

    val actualRecord = script.transform(inputRecord)
    assertEquals(expectedRecord, actualRecord)
  }
}