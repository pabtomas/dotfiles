# Request object

- **description**: A Request has 3 mandatory attributes:
    - `endpoint`,
    - `method`,
    - one between these attributes:
        - `loop`
        - `register`
        - `from`

Depending of what you choosed as a third attribute, the Request object will behave differently.
A Request has also an optional attribute: `if`.
- **exemples**:
    - This Request object will send 2 networks creation to the Docker Engine:
    ```yaml
    endpoint: /networks/create
    method: POST
    loop:
      - id: create.my-net
        query:
          Name: my-net
      - id: create.my-net-2
        query:
          Name: my-net-2
    ```
    - This Request object will ask for the current network list and store the JSON answer from the Docker Engine as a Datasource:
    ```yaml
    endpoint: /networks
    method: GET
    register:
      id: networks.json
      as:
        id: registernetworks
    ```
    - This Request object will send a network deletion to the Docker Engine for each network listed in the previously registered Datasource if its content is not empty:
    ```yaml
    if: '{{ gt (len $registernetworks) 0 }}'
    endpoint: /networks/{id}
    method: DELETE
    from:
      id: from.networks.json
      filter: '{{ $array := "" }}{{ range $registernetworks }}{{ $array = print $array "{\"path\":{\"id\":\"" .Name "\"}}," }}{{ end }}{{ print "[" $array "]" | data.YAMLArray }}'
      depends_on:
        - networks.json
    ```

### `Request.endpoint`

- **type**: string
- **required**: true
- **description**: The HTTP Request endpoint. Possible values are listed [here](https://docs.docker.com/engine/api/latest) depending of the Docker Engine API you are targetting.

### `Request.method`

- **type**: string
- **required**: true
- **description**: The HTTP Request method to use (GET, POST, DELETE, ...).

### `Request.loop`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: A list of Body objects. A Request will be send to the Docker Engine for each element in this list. Each element in this list must match required (and optional) parameters used by the selected Docker Engine API Request.

### `Request.register`

- **type**: Register
- **required**: false
- **default**: `{}`
- **description**: The Docker Engine answer of the Request will be stored as a JSON Datasource. It is useful if you want to use the result of this Request for another Request or Command later.

### `Request.from`

- **type**: From
- **required**: false
- **default**: `""`
- **description**: A From object. This object will be evaluated 2 times. The first one as a Golang template. The result of this first resolution is a list. Each element of this list will be evaluated as an element of a `Request.loop` keyword.

### `Request.if`

- **type**: boolean
- **required**: false
- **default**: true
- **description**: The result of this expression must a boolean. It this expression is evaluated as true, the matching Request will be executed. Otherwise, it will not.
