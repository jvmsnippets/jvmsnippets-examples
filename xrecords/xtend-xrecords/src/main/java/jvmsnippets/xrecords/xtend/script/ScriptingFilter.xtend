package jvmsnippets.xrecords.xtend.script

import java.util.Map
import jvmsnippets.xrecords.xtend.Filter
import jvmsnippets.xrecords.xtend.Record

class ScriptingFilter extends RecordScript implements Filter {
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
}
