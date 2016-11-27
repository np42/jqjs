{
  var mkfunc = function (name) {
    return { type: 'evaluation', func: name, args: Array.prototype.slice.call(arguments, 1) }
  };

  var mkfuncArgs = function (name, args) {
    return { type: 'evaluation', func: name, args: args }
  };

  var lambda = function (value) {
    return { type: 'lambda', value: value };
  };
}

main = ws Events ws

/********** HELPERS *******************/

ws = [ \n\r\t\v\uFEFF]* { return text(); }

digit = [0-9]

identifier = [a-z_$A-Z][a-z_$A-Z0-9]* { return text(); }

integer = '-'?[0-9]+ { return parseInt(text(), 10); }

/********** SYNTAX ********************/

Events = h:Flow t:(ws ',' ws Flow)* {
  var list = [h];
  for (var i = 0; i < t.length; i++) list.push(t[i][3]);
  return { type: 'events', list: list };
}

Flow = h:Value t:(ws ('|' / '|=') ws Value)* {
  var list = [h];
  for (var i = 0; i < t.length; i++) list.push(t[i][3]);
  return { type: 'flow', list: list };
}

Value = Value_Compound / Value_Simple

Value_Compound = a:Value_Simple ws f:Operator ws b:Value {
  return { type: 'evaluation', func: f, args: [a, b] }
}

Value_Simple = Path / Field / Production / Evaluation / Function / Primitive / Dot

Dot = '.' { return { type: 'dot' } }

Path = l:('.' identifier)+ {
  var list = [];
  for (var i = 0; i < l.length; i++) list.push(l[i][1]);
  return { type: 'path', list: list };
}

Field = '.[' ws f:(Field_Offset / Field_Name / Field_Range) ws ']' {
  return f;
}

Field_Offset = o:integer {
  return { type: 'field-offset', offset: o };
}

Field_Name = s:JSON_String {
  return { type: 'field-name', name: s };
}

Field_Range = b:integer ':' e:integer {
  return { type: 'field-range', range: { begin: b, end: e } };
}

Production = Production_Array / Production_Object

Production_Array = '[' ws e:Events ws ']' {
  return { type: 'production-array', elements: e };
}

Production_Object = '{' ws e:Object_Values ws '}' {
  return { type: 'production-object', elements: e };
}

Object_Values = h:Object_Value t:(ws ',' ws Object_Value)* {
  var list = [h];
  for (var i = 0; i < t.length; i++) list.push(t[i][3]);
  return list;
}

Object_Value = k:Object_Key ws ':' v:Flow { return { key: k, value: v }; }
             / k:Object_Key { return { key: k, value: { type: 'path', list: [k] }; }
             / k:Evaluation ws ':' v:Flow { return { key: k, value: v }; }

Object_Key = identifier / JSON_String

Evaluation = '(' ws v:Flow ws ')' {
  return v;
}

Primitive = JSON_String / JSON_Number / JSON_Boolean / JSON_Null

Dot = '.' { return { type: 'dot' } }

Operator = '//' { return 'alternative' }
         / '+' { return 'operator-plus' }
         / '-' { return 'operator-minus' }
         / '*' { return 'operator-multiply' }
         / '/' { return 'operator-divide' }
         / '%' { return 'operator-modulo' }
         / '<' { return 'comparison-less' }
         / '<=' { return 'comparison-less-or-equal' }
         / '>' { return 'comparison-more' }
         / '>=' { return 'comparison-more-or-equal' }
         / '==' { return 'comparison-equal' }
         / '!=' { return 'comparison-not-equal' }
         / 'and' { return 'comparison-and' }
         / 'or' { return 'comparison-or' }

/********** BUILTINS ******************/

Function = Function_WithArgs
         / Function_WithLambdas
         / Function_WithoutArgs

Function_WithArgs
  = f:'has' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'in' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'getpath' ws '(' ws a:Events ws ')' { return mkfuncArgs(f, a.list); }
  / f:'setpath' ws '(' ws a:Events ws ';' ws b:Flow ws ')' { return mkfunc(f, a.list, b); }
  / f:'flatten' ws '(' ws a:Flow ws ')' { return mkfuncArgs(f, a); }
  / f:'range' ws '(' ws a:Flow ws ';' ws b:Flow ws ';' ws c:Flow ws ')' { return mkfuncArgs(f, a, b, c); }
  / f:'range' ws '(' ws a:Flow ws ';' ws b:Flow ws ')' { return mkfuncArgs(f, a, b); }
  / f:'range' ws '(' ws a:Flow ws ')' { return mkfuncArgs(f, a); }

Function_WithLambdas
  = f:'map' ws '(' ws a:Flow ws ')' { return mkfunc(f, lambda(a)); }
  / f:'map_values' ws '(' ws a:Flow ws ')' { return mkfunc(f, lambda(a)); }
  / f:'path' ws '(' ws a:Flow ws ')' { return mkfunc(f, lambda(a)); }
  / f:'del' ws '(' ws a:Flow ws ')' { return mkfunc(f, lambda(a)); }
  / f:'with_entries' ws '(' ws a:Flow ws ')' { return mkfunc(f, lambda(a)); }
  / f:'select' ws '(' ws a:Flow ws ')' { return mkfunc(f, lambda(a)); }
  / f:'paths' ws '(' ws a:Flow ws ')' { return mkfunc(f, lambda(a)); }
  / f:('any' / 'all') ws '(' ws a:Flow ws ';' ws b:Flow ws ')' { return mkfunc(f, lambda(a), lambda(b)); }
  / f:('any' / 'all') ws '(' ws a:Flow ws ')' { return mkfunc(f, lambda(a)); }
  / f:'sort_by' ws '(' ws a:Flow ws ')' { return mkfunc(f, lambda(a)); }
  / f:'group_by' ws '(' ws a:Flow ws ')' { return mkfunc(f, lambda(a)); }
  / f:'min_by' ws '(' ws a:Flow ws ')' { return mkfunc(f, lambda(a)); }
  / f:'max_by' ws '(' ws a:Flow ws ')' { return mkfunc(f, lambda(a)); }

Function_WithoutArgs
  = ( 'length' / 'utf8bytelength'
    / 'keys' / 'keys_unsorted'
    / 'to_entries' / 'from_entries'
    / 'arrays' / 'objects' / 'iterables' / 'booleans' / 'numbers'
    / 'normals', 'finites' / 'strings' / 'nulls' / 'values' / 'scalars'
    / 'empty'
    / 'paths' / 'leaf_paths'
    / 'add' / 'any' / 'all'
    / 'flatten'
    / 'floor' / 'sqrt'
    / 'tonumber' / 'tostring' / 'type'
    / 'infinite' / 'nan' / 'isinfinite' / 'isnan' / 'isfinite' / 'isnormal'
    / 'sort' / 'min' / 'max'
    ) { return mkfunc(text()); }

/* TODO: uniq */

/********** JSON **********************/

JSON = JSON_Value { return text(); }

JSON_Object = '{' ws JSON_Object_fields? ws '}'

JSON_Object_fields = JSON_Object_field ws (',' ws JSON_Object_field ws)*

JSON_Object_field = JSON_String ws ':' ws JSON_Value

JSON_Array = '[' ws JSON_Array_values? ws ']'

JSON_Array_values = JSON_Value ws (',' ws JSON_Value ws)*

JSON_Value = JSON_Primitives / JSON_Number / JSON_String / JSON_Array / JSON_Object

JSON_String = '"' JSON_Character* '"'

JSON_Character = JSON_Character_unicode / JSON_Character_escaped

JSON_Character_unicode = !'\n' [^\\"]

JSON_Character_escaped = '\\' (["\\/bfnrt] / ('u' hex hex hex hex))

JSON_Number = '-' ? JSON_Number_digit JSON_Number_decimal ? JSON_Number_tenp ?

JSON_Number_digit = '0' / ([1-9] digit*)

JSON_Number_decimal = '.' digit+

JSON_Number_tenp = [eE] ('+' / '-') ? digit+

JSON_Primitives = 'null' / 'false' / 'true'

/********** REGEXP ********************/

RegExp = '/' s:(RegExp_character) + '/' f:RegExp_flag ?
  { return { source: s.join(''), flag: f }; }

RegExp_character = [^/] / '\\\\' / '\\/'

RegExp_flag
  = ( 'gim' / 'gmi' / 'img' / 'igm' / 'mig' / 'mgi'
    / 'gi' / 'gm' / 'im' / 'ig' / 'mi' / 'mg'
    / 'g' / 'i' / 'm'
    )
  { return text(); }
