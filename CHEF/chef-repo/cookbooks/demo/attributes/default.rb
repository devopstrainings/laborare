#
ALOC='/opt'
default['URL']='http://redrockdigimark.com/apachemirror/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz'
ATAR = default['URL'].split('/').last
default['TAR'] = "#{ALOC}/#{ATAR}"

##
normal['init']['VAL']='200'
