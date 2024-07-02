# Register object

- **description**: The only use case of this object is in `Request.register`.
- **exemple**: This is the same exemple you can find in the `Request object` section:
```yaml
endpoint: /networks
method: GET
register:
  id: networks.json
  as:
    id: registernetworks
```
This will store the JSON response from the Docker Engine as a Datasource into `registernetworks`.

### `Register.id`

- **type**: string
- **required**: true
- **description**: A unique ID attributed to a Request. `Register.id` and `Register.as.id` are different:
    - `Register.id` is the id of the Request. Other Requests or Commands can use it to specify dependencies.
    - `Register.as.id` is the id of the Datasource where the Docker Engine response will be stored. It is only useful in Golang Templates.

### `Register.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: Exodia uses as many process as possible and runs a Request (or Command) as soon as possible. So this is here that you can schedule the Exodia execution. You can let this list empty but that means that you do not mind that the matching Request or Command runs first. This attribute takes a list of ID. Exodia will run the Request after the Requests and Commands listed here will end their execution.

### `Register.errexit`

- **type**: boolean
- **required**: false
- **default**: `true`
- **description**: If the Request you want register failed, Exodia stops its execution in failure.

### `Register.query`

- **type**: dictionnary
- **required**: false
- **default**: `{}`
- **description**: Attributes in this dictionnary are listed [here](https://docs.docker.com/engine/api/latest) and depends of:
    - the Docker Engine API you are targetting,
    - the endpoint and method you want to submit to the Docker Engine.

### `Register.as`

- **type**: Datasource
- **required**: true
- **description**: The Datasource object where the JSON response of the Docker Engine will be stored. The `Datasource.source` attribute is ignored.
