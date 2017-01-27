package jvmsnippets.xrecords.xtend.io

import org.eclipse.xtend.lib.annotations.Accessors

/**
 * Base class for FTP `Source`s and `Destination`s.
*/
abstract class FtpBase {
  @Accessors String host
  @Accessors int port = 21
  @Accessors String user = 'anonymous'
  @Accessors String password = 'someone@somewhere.net'
  @Accessors String path
  @Accessors boolean binary = false

  private var String location

  def getLocation() {
    if(location == null) {
      location = buildFtpUri
    }
    location
  }

  def String buildFtpUri() {
    val credentialsFragment = {
      if(user == null) ''
      else if(password == null) '''«user»@'''
      else '''«user»:«password»@'''
    }

    val portFragment = {
      if(port == 21) ''
      else ''':«port»'''
    }

    val pathFragment = {
      if(path.startsWith('/')) path
      else '''/«path»'''
    }

    val binaryFragment =
      if(binary) ';type=i'
      else ''

    '''ftp://«credentialsFragment»«host»«portFragment»«pathFragment»«binaryFragment»'''
  }
}
