#
LOC = '/opt'
default['httpd']['default']['LOC']='/opt'
default['httpd']['default']['MODJK_URL']="http://redrockdigimark.com/apachemirror/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz"
TAR = default['httpd']['default']['MODJK_URL'].split('/').last
TARDIR= TAR.gsub(".tar.gz", "")
default['httpd']['default']['TARFILE']="#{LOC}/#{TAR}"
default['httpd']['default']['TARDIR']="#{LOC}/#{TARDIR}"

default['httpd']['default']['WORKER']='127.0.0.1'