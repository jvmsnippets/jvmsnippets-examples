package jvmsnippets.xrecords.xtend.script

import java.util.Map
import jvmsnippets.xrecords.xtend.Filter
import jvmsnippets.xrecords.xtend.Record
import jvmsnippets.xrecords.xtend.Transformer

class CopierScript extends RecordScript implements Filter, Transformer {

  new() {
  }

  new(String script) {
    super(script)
  }

  new(String language, String script) {
    super(language, script)
  }

  new(String script, Map<String, ? extends Object> environment) {
    super(script, environment)
  }

  override matches(Record record) {
    val result = execute(record)

    switch (result) {
      Boolean: result
      default:
        throw new IllegalArgumentException('''Expected boolean, got: «result»''')
    }
  }

  override transform(Record record) {
    val result = execute(record)
    switch (result) {
      Record: result
      Map<?, ?>: new Record => [
        result.forEach[n, v|setField(n.toString, v)]
      ]
      default:
        throw new IllegalArgumentException('''Don't know how to build record from «result»''')
    }
  }
}