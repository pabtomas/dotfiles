# Register object

TODO

- **description**: The only use case of this object is in `Request.register`.
- **exemple**: See `Request object`.

### `Register.id`

- **type**: string
- **required**: true
- **description**: See `Body.id`.

### `Register.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: See `Body.depends_on`.

### `Register.errexit`

- **type**: boolean
- **required**: false
- **default**: `true`
- **description**: See `Body.errexit`.

### `Register.query`

- **type**: dictionnary
- **required**: false
- **default**: `{}`
- **description**: See `Body.query`

### `Register.as`

- **type**: Datasource
- **required**: true
- **description**: The Datasource object where the JSON answer of the Docker Engine will be stored. The `Datasource.source` attribute is ignored.
