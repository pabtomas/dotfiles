# Requests object

You can start to use a Requests object with the `requests` keyword.

- **description**: A Requests object has 3 mandatory attributes:
    - `endpoint`,
    - `method`,
    - `with`
and 2 other optional attributes:
    - `if`,
    - `depends_on`,

The Requests object is your main way to send requests to the Docker Engine. It takes an API endpoint, an HTTP method and for each request body into the `with` attribute, it will send a matching request.

**exemple**:
This Requests object will send 2 networks creation to the Docker Engine:
```json
rule:
  id: create_my_networks
  run:
    - requests:
        endpoint: /networks/create
        method: POST
        with:
          - body:
              id: create.my-net
              query:
                Name: my-net
          - body:
              id: create.my-net-2
              query:
                Name: my-net-2
```

You can run these requests conditionally with the `if` attribute. You will see exemples later for this because it is not really interesting to use without Processor objects. The same reasoning is applyable for the `depends_on` attribute. This attribute is useful when you want to evaluate the content of a variable after you use a Processor object. If this sentence is not clear now, it is not a big deal. You will understand when the Processor object will be introduced.

### `Requests.endpoint`

- **type**: string
- **required**: true
- **description**: The HTTP requests endpoint. Possible values are listed [here](https://docs.docker.com/engine/api/latest) depending of the Docker Engine API you are targetting.

### `Requests.method`

- **type**: string
- **required**: true
- **description**: The HTTP Request method to use (GET, POST, DELETE, ...).

### `Requests.with`

- **type**: list
- **required**: true
- **description**: A list of Body objects. A Request will be send to the Docker Engine for each element in this list. Each element in this list must match required (and optional) parameters used by the selected Docker Engine API Request.

### `Requests.if`

- **type**: boolean
- **required**: false
- **description**: It the content is true, the matching Request will be executed. Otherwise, it will not.

### `Requests.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: Navy uses as many process as possible and runs a Request (or Command) as soon as possible. So this is here that you can schedule the Navy execution. You can let this list empty but that means that you do not mind that the variables used into the Requests attributes are evaluated first. This attribute takes a list of ID. Navy will evaluate content of the Requests attributes after the other objects listed here will end their execution.
