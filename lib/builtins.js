module.exports = new function () {
  'use strict';

  /*********************************************/

  this._path = function (data, path) {
    var node = data;
    for (var i = 0; i < path.length; i++) {
      if (node == null) return node;
      node = node[path[i]];
    }
    return node != null ? node : null;
  };

  this._comparison_less = function (data, left, right) {
    return left < right;
  };

  this._comparison_more = function (data, left, right) {
    return left > right;
  };

  /********************************************/

  this.map = function (data, filter) {
    const type = this._type(data);
    switch (type) {
    case 'array': case 'arguments':
      var result = [];
      for (var i = 0; i < data.length; i++) {
        var value = this._execute(filter, data[i]);
        if (value === this.__EMPTY__) continue ;
        result.push(value);
      }
      return result;
    case 'object':
      var result = {};
      for (var key in data) {
        var value = this._execute(filter, data[key]);
        if (value === this.__EMPTY__) continue ;
        result[key] = value;
      }
      return result;
    default:
      throw new Error('Cannot iterate over ' + type);
    }
  };

  this.select = function (data, predicate) {
    return this._execute(predicate, data) ? data : this.__EMPTY__;
  };

  this.sort_by = function (data, accessor) {
    if (this._type(data) != 'array') throw new Error('Only array can be sorted');
    var sortable = [];
    var mapping = {};
    for (var i = 0; i < data.length; i++) {
      var value = this._execute(accessor, data[i]);
      var type = typeof value;
      if (type != 'string' && type != 'number') value = JSON.stringify(value);
      if (mapping.hasOwnProperty(value)) {
        mapping[value].push(data[i]);
      } else {
        sortable.push(value);
        mapping[value] = [data[i]];
      }
    }
    sortable.sort(function (l, r) { return l > r; });
    var result = [];
    for (var i = 0; i < sortable.length; i++)
      Array.prototype.push.apply(result, mapping[sortable[i]]);
    return result;
  };

  this.join = function (data, separator) {
    return Array.prototype.join.call(data, separator != null ? separator : '');
  };

};