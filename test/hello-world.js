var jqjs = require('../dist/jq.js');
var assert = require('assert');

describe('Hello World', function () {

  it('should returns hello world', function () {
    var data = [{ a: 60, b: 'world' }, { a: 15, b: 'BAD' }, { a: 42, b: 'hello' }];
    var find_hw = jqjs('map(select(.a > 40)) | sort_by(.a) | map(.b) | join(" ")');
    assert.equals('Hello World', find_hw.first(data))
  });

});
