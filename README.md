AMPJS
=====
A Javascript WEB-STOMP-based client for [AMP](https://github.com/Berico-Technologies/AMP)


Installation
------------

    npm install -g bower
    npm install -g karma 
    npm install -g phantomjs 
    bower install 
    mimosa build 

Running Tests
-------------
1. Compile the source code. We're using mimosa, so either have the project running 'mimosa watch -s' or compile the code 'mimosa build'

2. Once the code is compiled you should be able to run the unit tests 'karma start'

    **NOTE: the project does not currently include phantomjs. **You need to download it yourself and set the PHANTOMJS_BIN environement variable like this:
    >export PHANTOMJS_BIN=/Applications/phantomjs-1.9.0-macosx/bin/phantomjs
