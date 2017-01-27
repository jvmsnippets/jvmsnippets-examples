package jvmsnippets.xrecords.xtend.fixed

import java.util.List
import jvmsnippets.xrecords.xtend.field.FixedField
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * The base class for both `FixedSource` and `DestinationDestination`.
 * This class captures the properties common to both fixed-length components:
 *
 * - `length`: the record length in characters.
 * - `fields`: the list of `FixedField` metadata objects describing each  fixed field: position,
 * length, data type.
*/
abstract class FixedBase {
  /**
   * The record length in characters. Each record in the fixed-length field has the same length.
   * Fixed-length record may or may not be terminated by a newline character.
  */
  @Accessors int length

  /**
   * The list of field metadata items dictating each fixed field's metadata: offset within the
   * record, length in characters, parser/formatter to be used in converting the field's value
   * from/to its `String` representation.
  */
  @Accessors List<FixedField<Object>> fields
}