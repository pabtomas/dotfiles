# Specification

Keywords:
1. [datasources](#datasources)
2. [anchors](#anchors)
3. [include](#include)
4. [versions](#versions)
5. [tasks](#tasks)
6. [handlers](#handlers)

Objects:
7. [Request](#Request-object)
    1. [endpoint](#Requestendpoint)
    2. [method](#Requestmethod)
    3. [register](#Requestregister)
    4. [from](#Requestfrom)
    5. [loop](#Requestloop)
    6. [if](#Requestif)
8. [Body](#Body-object)
    1. [id](#Bodyid)
    2. [depends_on](#Bodydepends_on)
    3. [path](#Bodypath)
    4. [query](#Bodyquery)
    5. [virtual](#Bodyvirtual)
    6. [extends](#Bodyextends)
    7. [context](#Bodycontext)
9. [Register](#Register-object)
    1. [as](#Registeras)
10. [From](#From-object)
    1. [filter](#Fromfilter)
11. [Command](#Command-object)
    1. [argv](#Commandargv)
12. [Datasource](#Datasource-object)
    1. [scope](#Datasourcescope)
13. [Anchor](#Anchor-object)
    1. [source](#Anchorsource)
    2. [in](#Anchorin)
14. [Query & Path](#Query-amp-Path-dictionnaries)

## `datasources`

**type**: list
**required**: false
**default**: `[]`
**description**: List of Datasources available in GO templates. More details on how to use it with Navy into the [Datasource object section](#Datasource-object)
**good to know**:
- The `datasources` keyword is the first thing Navy will processed when executed, its location is in your main Navy file.
**exemple**:
```yaml
```

## `anchors`

**type**: list
**required**: false
**default**: `[]`
**description**: List of Anchors.
**good to know**:
- The `anchors` keyword is processed after the `datasources` keyword when Navy is executed and before the `include` keyword. Its location is in your main Navy file.
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

## `tasks`

**type**: list
**required**: false
**default**: `[]`
**description**: A list of Requests and Commands. If a Request (or Command) in this list fails, Navy skips the rest of the list and run the `handlers` list.
**exemple**:
```yaml
```

## `handlers`

**type**: list
**required**: false
**default**: `[]`
**description**: A list of Requests and Commands reserved for cleanup actions. Navy will run every Request (or Command) in this list whatever happens.

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

**type**: From
**required**: false
**default**: `""`
**description**:

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

## Body object

**description**:
**exemples**:
```yaml
```

### `Body.id`

**type**: string
**required**: true
**description**:

### `Body.depends_on`

**type**: list
**required**: false
**default**: `[]`
**description**:

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

### `Body.virtual`

**type**: boolean
**required**: false
**default**: false
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

## Register object

**description**:
- depends_on
- query
**exemples**:
```yaml
```

### `Register.as`

**type**: Datasource
**required**: true
**description**:
- Datasource id is the id of the Register

## From object

**description**:
- id
- depends_on
**exemples**:
```yaml
```

### `From.filter`

**type**: string
**required**: true
**description**: A GO template filter returning a list of Body objects. Each element of this list will be used to run a matching Request.

## Command object

**description**: A custom command for specific needs or to compensate some Navy's lacks.
- id
- depends_on
**exemples**:
```yaml
```

### `Command.argv`

**type**: list
**required**: false
**default**: `[]`
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
# datasources/exemple.yaml

sender: Alice
receiver: Bob

# You can use the other defined Datasources in your Datasource files (whatever the defined scope).
message: 'Hello {{ (ds "datasources.exemple.yaml").receiver }}, you received a message from {{ (ds "datasources.exemple.yaml").sender }}'

...
```

### `Datasource.scope`

**type**: string
**required**: false
**default**: `*`
**description**: An extended regex pattern applied on Requests and Commands id that filters access to the Datasource.

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
