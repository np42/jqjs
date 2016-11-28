var jq = require('../dist/jq.js');
var assert = require('assert');

describe('Hello World', function () {

  var data = [{ a: 60, b: 'World' }, { a: 15, b: 'BAD' }, { a: 42, b: 'Hello' }];
  var find_hw = jq('map(select(.a > 40)) | sort_by(.a) | map(.b) | join(" ")');
  it('should returns Hello World', function () {
    assert.equal('Hello World', find_hw.first(data))
  });

});
