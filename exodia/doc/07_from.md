# From object

TODO

- **description**: The only use case of this object is in `Request.from`.
- **exemple**: See `Request object`.

### `From.id`

TODO

- **type**: string
- **required**: true
- **description**: See `Body.id`.

### `From.depends_on`

TODO

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: See `Body.depends_on`.

### `From.errexit`

TODO

- **type**: boolean
- **required**: false
- **default**: `true`
- **description**: See `Body.errexit`.

### `From.filter`

- **type**: string
- **required**: true
- **description**: A Golang template filter returning a list of Body objects. Each element of this list will be used to run a matching Docker Engine API Request.
