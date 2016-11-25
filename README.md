jqjs
====

jqjs is a pure javascript JSON processor based on the awesome [stedolan/jq](https://github.com/stedolan/jq) work.

It's currently in dev and not usable now, but I'm working on !

---

See full documentation [here](https://stedolan.github.io/jq/manual/#Basicfilters) but only basic features will be implemented.

---

```shell-script
$> npm install jqjs
```
```javascript
import jqjs from 'jqjs'

const data = [{ a: 60, b: 'world' }, { a: 15, b: 'BAD' }, { a: 42, b: 'hello' }];
const selector = 'map(select(.a > 40)) | sort_by(.a) | map(.b) | join(" ")';
console.log(jqjs(selector).first(data));
```

---
Features delayed:
> **? token**: does not output even an error

