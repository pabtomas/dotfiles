# Specification

## Keywords

### `versions`

**type**: list
**required**: true
**description**: List of Docker Engine API versions targetted by your project. Navy will run with the first available version. Navy will fail if the Docker Engine does not support any targetted version.
**exemple**:
```yaml
```

### `include`

**type**: list
**required**: false
**default**: `[]`
**description**: List of files. Including files in another will merge their contents.
**exemple**:
```yaml
```

### `requests`

**type**: list
**required**: false
**default**: `[]`
**description**: A list of Requests. If a Request in this list fails, Navy stops other Requests in this list and run Requests in the `handlers` list.
**exemple**:
```yaml
```

### `handlers`

**type**: list
**required**: false
**default**: `[]`
**description**: A list of Requests reserved for cleanup actions. Navy will run Requests in this list after running Requests from the `requests` list. Navy will run every Request in this list whatever happens.

## Objects

### Request

A Request has 3 mandatory fields:
- `endpoint`,
- `method`,
- one between these fields:
  - `register`
  - `from`
  - `loop`

#### `Request.endpoint`

**type**: string
**required**: true
**description**: The HTTP Request endpoint. Possible values are listed [here](https://docs.docker.com/engine/api/latest) depending of the Docker Engine API you are targetting.
**exemple**:
```yaml
```

#### `Request.method`

**type**: string
**required**: true
**description**: The HTTP Request method to use (GET, POST, DELETE, ...).

#### `Request.register`

**type**: Register
**required**: false
**default**: `{}`
**description**:
**exemple**:
```yaml
```

#### `Request.from`

**type**: string
**required**: false
**default**: `""`
**description**: A GO template filter returning a list of Body objects. Each element of this list will be used to run a matching Request.
**exemple**:
```yaml
```

#### `Request.loop`

**type**: list
**required**: false
**default**: `[]`
**description**:
**exemple**:
```yaml
```

### Register

#### `Register.query`

**type**: Query
**required**: false
**default**: `{}`
**description**:
**exemple**:
```yaml
```

#### `Register.datasource`

**type**: string
**required**: true
**description**:
**exemple**:
```yaml
```

### Body

#### `Body.query`

**type**: Query
**required**: false
**default**: `{}`
**description**:
**exemple**:
```yaml
```

#### `Body.path`

**type**: Path
**required**: false
**default**: `{}`
**description**:
**exemple**:
```yaml
```

#### `Body.id`

**type**: string
**required**: false
**default**: `""`
**description**:
**exemple**:
```yaml
```

#### `Body.virtual`

**type**: boolean
**required**: false
**default**: false
**description**:
**exemple**:
```yaml
```

#### `Body.context`

**type**: path
**required**: false
**default**: `.`
**description**:
**exemple**:
```yaml
```

#### `Body.depends_on`

**type**: list
**required**: false
**default**: `[]`
**description**:
**exemple**:
```yaml
```

#### `Body.extends`

**type**: list
**required**: false
**default**: `[]`
**description**:
**exemple**:
```yaml
```

### Query & Path parameters

[Here](https://docs.docker.com/engine/api/v1.45/#tag/Container/operation/ContainerInspect) a simple Docker Engine API endpoint to make quickly the distinction between both.

#### Query

Fields are listed [here](https://docs.docker.com/engine/api/latest) and depends of:
- the Docker Engine API you are targetting,
- the endpoint and method you want to submit to the Docker Engine.

#### `Query.buildargs`

TODO

### Path

Path parameters of the request.
