# Specification

Keywords:
1. [anchors](#anchors)
2. [include](#include)
3. [datasources](#datasources)
4. [versions](#versions)
5. [requests](#requests)
6. [handlers](#handlers)

Objects:
7. [Request](#Request-object)
    1. [endpoint](#Requestendpoint)
    2. [method](#Requestmethod)
    3. [register](#Requestregister)
    4. [from](#Requestfrom)
    5. [loop](#Requestloop)
    6. [if](#Requestif)
8. [Register](#Register-object)
    1. [query](#Registerquery)
    2. [as](#Registeras)
9. [Body](#Body-object)
    1. [path](#Bodypath)
    2. [query](#Bodyquery)
    3. [id](#Bodyid)
    4. [virtual](#Bodyvirtual)
    5. [depends_on](#Bodydepends_on)
    6. [extends](#Bodyextends)
    7. [context](#Bodycontext)
10. [Datasource](#Datasource-object)
    1. [input](#Datasourceinput)
    3. [scope](#Datasourcescope)
11. [Anchor](#Anchor-object)
    1. [source](#Anchorsource)
    2. [in](#Anchorin)
12. [Query & Path](#Query-amp-Path-dictionnaries)

## `anchors`

**type**: list
**required**: false
**default**: `[]`
**description**: List of Anchors.
**good to know**:
- The `anchors` keyword is the first thing Navy will processed when executed, so the location of this directive is in your main Navy file.
**exemple**:
```yaml
```

## `include`

**type**: list
**required**: false
**default**: `[]`
**description**: List of files. Including files in another will merge their contents.
**good to know**:
- The `include` keyword is processed after the `anchors` keyword when Navy is executed
**exemple**:
```yaml
```

## `datasources`

**type**: list
**required**: false
**default**: `[]`
**description**: List of Datasources available in GO templates. More details on how to use it with Navy into the [Datasource object section](#Datasource-object)
**good to know**:
- The `datasources` keyword is processed after the `include` keyword when Navy is executed
**exemple**:
```yaml
```

## `versions`

**type**: list
**required**: true
**description**: List of Docker Engine API versions targetted by your project. Navy will run with the first available version. Navy will fail if the Docker Engine does not support any targetted version.
**good to know**:
- For the Docker Engine API versions after 1.25 (included), the documentation specify this:
```
Engine releases in the near future should support this version of the API, so your client will continue to work even if it is talking to a newer Engine.
```
- Here the command line to check your Docker Engine API version:
```
docker version --format '{{ .Server.APIVersion }}'
```
**exemple**:
```yaml
```

## `requests`

**type**: list
**required**: false
**default**: `[]`
**description**: A list of Requests. If a Request in this list fails, Navy stops other Requests in this list and run Requests in the `handlers` list.
**exemple**:
```yaml
```

## `handlers`

**type**: list
**required**: false
**default**: `[]`
**description**: A list of Requests reserved for cleanup actions. Navy will run Requests in this list after running Requests from the `requests` list. Navy will run every Request in this list whatever happens.

## Request object

**description**: A Request has 3 mandatory fields:
- `endpoint`,
- `method`,
- one between these fields:
  - `register`
  - `from`
  - `loop`
**exemples**:
```yaml
```

### `Request.endpoint`

**type**: string
**required**: true
**description**: The HTTP Request endpoint. Possible values are listed [here](https://docs.docker.com/engine/api/latest) depending of the Docker Engine API you are targetting.

### `Request.method`

**type**: string
**required**: true
**description**: The HTTP Request method to use (GET, POST, DELETE, ...).

### `Request.register`

**type**: Register
**required**: false
**default**: `{}`
**description**:

### `Request.from`

**type**: string
**required**: false
**default**: `""`
**description**: A GO template filter returning a list of Body objects. Each element of this list will be used to run a matching Request.

### `Request.loop`

**type**: list
**required**: false
**default**: `[]`
**description**:

### `Request.if`

**type**: boolean
**required**: false
**default**: true
**description**:

## Register object

**description**:
**exemples**:
```yaml
```

### `Register.query`

**type**: dictionnary
**required**: false
**default**: `{}`
**description**:

### `Register.as`

**type**: Datasource
**required**: true
**description**:

## Body object

**description**:
**exemples**:
```yaml
```

### `Body.query`

**type**: dictionnary
**required**: false
**default**: `{}`
**description**:

### `Body.path`

**type**: Path
**required**: false
**default**: `{}`
**description**:

### `Body.id`

**type**: string
**required**: false
**default**: `""`
**description**:

### `Body.virtual`

**type**: boolean
**required**: false
**default**: false
**description**:

### `Body.depends_on`

**type**: list
**required**: false
**default**: `[]`
**description**:

### `Body.extends`

**type**: list
**required**: false
**default**: `[]`
**description**:

### `Body.context`

**type**: string
**required**: false
**default**: `"."`
**description**:

## Datasource object

**description**: A gomplate YAML Datasource. **A Datasource have to be a YAML file to be correctly processed by Navy**.
**exemples**:
- Here an exemple of a Datasource object:
```yaml
```
- Here an exemple of what could be the YAML file used by the Datasource object shown above:
```yaml
---

sender: Alice
receiver: Bob

# You can use the 'inventory' special datasource in your Datasource files to use your other variables (whatever the Datasource file it comes from and whatever the scope you define).
message: 'Hello {{ (ds "inventory").receiver }}, you received a message from {{ (ds "inventory").sender }}'

...
```

### `Datasource.input`

**type**: string
**required**: true
**default**: `""`
**description**:

### `Datasource.scope`

**type**: string
**required**: false
**default**: `*`
**description**: An extended regex pattern applied on Requests id that filters access to the Datasource.

## Anchor object

**description**: A YAML file containing anchors definitions.
**exemples**:
```yaml
```

### `Anchor.source`

**type**: string
**required**: true
**description**:

### `Anchor.in`

**type**: list
**required**: false
**default**: `[]`
**description**:

## Query & Path dictionnaries

[Here](https://docs.docker.com/engine/api/v1.45/#tag/Container/operation/ContainerInspect) a simple Docker Engine API endpoint to make quickly the distinction between both.

Query fields are listed [here](https://docs.docker.com/engine/api/latest) and depends of:
- the Docker Engine API you are targetting,
- the endpoint and method you want to submit to the Docker Engine.

### `Query.buildargs`

TODO
