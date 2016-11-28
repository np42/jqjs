jqjs
====

jqjs is a pure javascript JSON processor based on the awesome [stedolan/jq](https://github.com/stedolan/jq) work.

The JQJS project stopped at this point, use [jmespath](http://jmespath.org/specification.html) instead or fork it to implement missing builtins.

---

See full documentation [here](https://stedolan.github.io/jq/manual/#Basicfilters) but only basic features will be implemented.

---

## Installation
```shell-script
$> git clone https://github.com/np42/jqjs
```

## Development build
```shell-script
$> node build.js # create a ./dist/jq.js file
```

## Usage
```javascript
import jq from 'jqjs';

const data = [{ a: 60, b: 'world' }, { a: 15, b: 'BAD' }, { a: 42, b: 'hello' }];
const selector = 'map(select(.a > 40)) | sort_by(.a) | map(.b) | join(" ")';
console.log(jq(selector).first(data));
```

---

## List of builtins

| Function Name  | Implemented | Tested |
|----------------|:-----------:|:------:|
| Operator //    | ✘           | ✘      |
| Operator +     | ✘           | ✘      |
| Operator -     | ✘           | ✘      |
| Operator *     | ✘           | ✘      |
| Operator /     | ✘           | ✘      |
| Operator %     | ✘           | ✘      |
| Operator <     | ✓           | ✘      |
| Operator >     | ✓           | ✘      |
| Operator <=    | ✘           | ✘      |
| Operator >=    | ✘           | ✘      |
| Operator ==    | ✘           | ✘      |
| Operator !=    | ✘           | ✘      |
| Operator and   | ✘           | ✘      |
| Operator or    | ✘           | ✘      |
| Opertaor not   | ✘           | ✘      |
| has            | ✘           | ✘      |
| in             | ✘           | ✘      |
| getpath        | ✘           | ✘      |
| setpath        | ✘           | ✘      |
| flatten        | ✘           | ✘      |
| range          | ✘           | ✘      |
| indices        | ✘           | ✘      |
| index          | ✘           | ✘      |
| rindex         | ✘           | ✘      |
| stratswith     | ✘           | ✘      |
| endswith       | ✘           | ✘      |
| combinations   | ✘           | ✘      |
| ltrimstr       | ✘           | ✘      |
| rtrimstr       | ✘           | ✘      |
| split          | ✘           | ✘      |
| join           | ✓           | ✘      |
| test           | ✘           | ✘      |
| match          | ✘           | ✘      |
| sub            | ✘           | ✘      |
| map            | ✓           | ✘      |
| map_values     | ✘           | ✘      |
| path           | ✘           | ✘      |
| del            | ✘           | ✘      |
| with_entries   | ✘           | ✘      |
| select         | ✓           | ✘      |
| paths          | ✘           | ✘      |
| any            | ✘           | ✘      |
| all            | ✘           | ✘      |
| sort_by        | ✓           | ✘      |
| group_by       | ✘           | ✘      |
| min_by         | ✘           | ✘      |
| max_by         | ✘           | ✘      |
| unique_by      | ✘           | ✘      |
| while          | ✘           | ✘      |
| until          | ✘           | ✘      |
| recurse        | ✘           | ✘      |
| walk           | ✘           | ✘      |
| length         | ✘           | ✘      |
| utf8bytelength | ✘           | ✘      |
| keys           | ✘           | ✘      |
| keys_unsorted  | ✘           | ✘      |
| to_entries     | ✘           | ✘      |
| from_entries   | ✘           | ✘      |
| arrays         | ✘           | ✘      |
| objects        | ✘           | ✘      |
| iterables      | ✘           | ✘      |
| booleans       | ✘           | ✘      |
| numbers        | ✘           | ✘      |
| normals        | ✘           | ✘      |
| finites        | ✘           | ✘      |
| strings        | ✘           | ✘      |
| nulls          | ✘           | ✘      |
| values         | ✘           | ✘      |
| scalars        | ✘           | ✘      |
| empty          | ✘           | ✘      |
| leaf_paths     | ✘           | ✘      |
| add            | ✘           | ✘      |
| flatten        | ✘           | ✘      |
| reverse        | ✘           | ✘      |
| floor          | ✘           | ✘      |
| sqrt           | ✘           | ✘      |
| tonumber       | ✘           | ✘      |
| tostring       | ✘           | ✘      |
| type           | ✘           | ✘      |
| tojson         | ✘           | ✘      |
| fromjson       | ✘           | ✘      |
| infinite       | ✘           | ✘      |
| nan            | ✘           | ✘      |
| isinfinite     | ✘           | ✘      |
| isnan          | ✘           | ✘      |
| isfinite       | ✘           | ✘      |
| isnormal       | ✘           | ✘      |
| sort           | ✘           | ✘      |
| min            | ✘           | ✘      |
| max            | ✘           | ✘      |
| unique         | ✘           | ✘      |
| explode        | ✘           | ✘      |
| implode        | ✘           | ✘      |
| ascii_downcase | ✘           | ✘      |
| ascii_upcase   | ✘           | ✘      |
| recurse        | ✘           | ✘      |
| ..             | ✘           | ✘      |
| recurse_down   | ✘           | ✘      |
| transpose      | ✘           | ✘      |

---
Features delayed:
* **? token**: does not output even an error

TODO:
* Replace var keyword by let when es6 transpilation implemented
* Use Yolo.serialize instread of JSON.serialize
* Check for missing natives function (like Object.keys, JSON.parse, ...)
* Optimize selector parsing (quite slow)
