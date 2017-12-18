name "webserver"
description "The base role for systems that serve HTTP traffic"
run_list "recipe[httpd]", "recipe[demo]"
override_attributes "init" => { "VAL" => "300" }
