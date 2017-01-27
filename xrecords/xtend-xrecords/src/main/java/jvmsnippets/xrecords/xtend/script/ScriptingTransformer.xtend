package jvmsnippets.xrecords.xtend.script

import java.util.Map
import jvmsnippets.xrecords.xtend.Record
import jvmsnippets.xrecords.xtend.Transformer

class ScriptingTransformer extends RecordScript implements Transformer {
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
