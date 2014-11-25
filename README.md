## DirectiveRecord

A thin layer on top of ActiveRecord for using paths within queries without thinking about association joins

### Installation

Add `DirectiveRecord` in your `Gemfile`:

    gem "directiverecord"

Run the following in your console to install with Bundler:

    $ bundle install

### Demo

To try `DirectiveRecord` right out-of-the-box, please clone

https://github.com/archan937/directiverecord-console

and follow the README instructions. It is provided with a sample database and a Pry console in which you can play with `DirectiveRecord`.

### Testing

Run the following command for testing:

    $ rake

You can also run a single test file:

    $ ruby test/unit/test_directive_record.rb

### TODO

* Add more tests

### License

Copyright (c) 2014 Paul Engel, released under the MIT License

http://github.com/archan937 – http://twitter.com/archan937 – http://gettopup.com – pm_engel@icloud.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
