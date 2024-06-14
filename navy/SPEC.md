# Specification

Keywords:

1. [datasources](#datasources)
2. [anchors](#anchors)
3. [include](#include)
4. [versions](#versions)
5. [run](#run)
6. [post](#post)

Objects:

7. [Request](#request-object)
    - [endpoint](#requestendpoint)
    - [method](#requestmethod)
    - [register](#requestregister)
    - [from](#requestfrom)
    - [loop](#requestloop)
    - [if](#requestif)
8. [Body](#body-object)
    - [id](#bodyid)
    - [depends_on](#bodydepends_on)
    - [path](#bodypath)
    - [query](#bodyquery)
    - [virtual](#bodyvirtual)
    - [extends](#bodyextends)
    - [context](#bodycontext)
9. [Register](#register-object)
    - [depends_on](#registerdepends_on)
    - [query](#registerquery)
    - [as](#registeras)
10. [From](#from-object)
    - [id](#fromid)
    - [depends_on](#fromdepends_on)
    - [filter](#fromfilter)
11. [Command](#command-object)
    - [id](#commandid)
    - [depends_on](#commanddepends_on)
    - [argv](#commandargv)
12. [Datasource](#datasource-object)
    - [id](#datasourceid)
    - [source](#datasourcesource)
    - [scope](#datasourcescope)
13. [Anchor](#anchor-object)
    - [source](#anchorsource)
    - [in](#anchorin)
14. [Query & Path](#query--path-dictionnaries)

## `datasources`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: List of Datasources available in GO templates. In this list, **A Datasource have to be a YAML file to be correctly processed by Navy**. More details on the Datasource available fields into the [Datasource object section](#datasource-object).
- **good to know**:
    - The `datasources` keyword is the first thing Navy will processed when executed, its location can not be outside your main Navy file.
- **exemple**:
```yaml
datasources:
  - source: datasources/first.yaml
    id: my-first-datasource
    scope: *
  - source: datasources/second.yaml
    id: my-second-datasource
    scope: images.create.*
```

## `anchors`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: List of Anchors. In this list, you can define a YAML file and share its anchors across multiple files. More details on the Anchor available fields into the [Anchor object section](#anchor-object).
- **good to know**:
    - The `anchors` keyword is processed after the `datasources` keyword when Navy is executed and before the `include` keyword. Its location is in your main Navy file.
- **exemple**:
```yaml
anchors:
  - source: anchors/file.yaml
    in:
      - anchors-user1.yaml
      - anchors-user2.yaml
```

## `include`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: List of files to include into the current file. Including files in another will merge their contents. Each file can contain its own `include` list.
- **good to know**:
    - The `include` keyword is processed after the `anchors` keyword when Navy is executed
- **exemple**:
```yaml
include:
  - networks/create.yaml
  - volumes/create.yaml
  - images/pull.yaml
  - containers/create.yaml
```

## `versions`

- **type**: list
- **required**: true
- **description**: List of Docker Engine API versions targetted by your project. Navy will run with the first available version. Navy will fail if the Docker Engine does not support any targetted version.
- **good to know**:
    - For the Docker Engine API versions after 1.25 (included), the documentation specify this:
    ```
    Engine releases in the near future should support this version of the API, so your client will continue to work even if it is talking to a newer Engine.
    ```
    - Here the command line to check your Docker Engine API version:
    ```
    docker version --format '{{ .Server.APIVersion }}'
    ```
- **exemple**:
```yaml
versions:
  - 1.45
  - 1.44
  - 1.43
  - '{{ $CONTEXTVERSION.ApiVersion }}
```

## `run`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: A list of Requests and Commands. If a Request (or Command) in this list fails, Navy skips whatever comes after in this list and run the `post` list.
- **exemple**:
```yaml
```

## `post`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: A list of Requests and Commands reserved for cleanup actions. Navy will run every Request (or Command) in this list whatever happens.

## Request object

- **description**: A Request has 3 mandatory fields:
    - `endpoint`,
    - `method`,
    - one between these fields:
        - `register`
        - `from`
        - `loop`
- **exemples**:
```yaml
```

### `Request.endpoint`

- **type**: string
- **required**: true
- **description**: The HTTP Request endpoint. Possible values are listed [here](https://docs.docker.com/engine/api/latest) depending of the Docker Engine API you are targetting.

### `Request.method`

- **type**: string
- **required**: true
- **description**: The HTTP Request method to use (GET, POST, DELETE, ...).

### `Request.register`

- **type**: Register
- **required**: false
- **default**: `{}`
- **description**: The Docker Engine answer of the Request will be stored as a JSON datasource. It is useful if you want to use the result of this Request for another Request or Command later  

### `Request.from`

- **type**: From
- **required**: false
- **default**: `""`
- **description**: 

### `Request.loop`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**:

### `Request.if`

- **type**: boolean
- **required**: false
- **default**: true
- **description**:

## Body object

- **description**:
- **exemples**:
```yaml
```

### `Body.id`

- **type**: string
- **required**: true
- **description**:

### `Body.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**:

### `Body.query`

- **type**: dictionnary
- **required**: false
- **default**: `{}`
- **description**:

### `Body.path`

- **type**: Path
- **required**: false
- **default**: `{}`
- **description**:

### `Body.virtual`

- **type**: boolean
- **required**: false
- **default**: false
- **description**:

### `Body.extends`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**:

### `Body.context`

- **type**: string
- **required**: false
- **default**: `"."`
- **description**:

## Register object

- **description**:
- **exemples**:
```yaml
```

### `Register.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**:

### `Register.query`

- **type**: dictionnary
- **required**: false
- **default**: `{}`
- **description**:

### `Register.as`

- **type**: Datasource
- **required**: true
- **description**:
    - Datasource id is the id of the Register

## From object

- **description**:
- **exemples**:
```yaml
```

### `From.id`

- **type**: string
- **required**: true
- **description**:

### `From.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**:

### `From.filter`

- **type**: string
- **required**: true
- **description**: A GO template filter returning a list of Body objects. Each element of this list will be used to run a matching Request.

## Command object

- **description**: A custom command for specific needs or to compensate some Navy's lacks.
- **exemples**:
```yaml
```

### `Command.id`

- **type**: string
- **required**: true
- **description**:

### `Command.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**:

### `Command.argv`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**:

## Datasource object

- **description**:
    - A Datasource is a gomplate concept. Most of the time, you will find everything you need in [the gomplate documentation](https://docs.gomplate.ca/) concerning this issue.
    - Used with the `datasources` keyword, the Datasource object have to be YAML file. Used with the `Register.as` keyword, the Datasource object is a JSON answer from Docker Engine. A Datasource has 3 available fields (each of them is described in its own section):
        - id
        - source
        - scope
- **exemples**:
    - Here an exemple of a Datasource object used into the `datasources` list:
    ```yaml
    source: datasources/message.yaml
    id: message
    scope: *
    ```
    The `datasources/message.yaml` YAML file will be loaded as Datasource object. You can refer this Datasource as the `$message` variable into your GO templates. It will be visible into all your Requests & Commands.
    - Here an exemple of the YAML file content used by the Datasource object shown above:
    ```yaml
    ---
    # datasources/message.yaml

    sender: Alice
    receiver: Bob

    # You can use the other Datasources in your Datasource files (whatever the defined scope).
    message: 'Hello {{ (ds "datasources/message.yaml").receiver }}, you received a message from {{ (ds "datasources/message.yaml").sender }}'

    # You can use the Datasource.id field (if you used it) to have more readable code
    same_message: 'Hello {{ $message.receiver }}, you received a message from {{ $message.sender }}'

    # You can use the special CONTEXTVERSION/CONTEXTINFO Datasources in your Datasource files
    message2: 'Your Docker Engine is using the {{ $CONTEXTVERSION.ApiVersion }} version of the API and is already running {{ $CONTEXTINFO.Containers }} container(s) !'

    ...
    ```
    - Here an exemple of a Datasource object into the `Register.as` field:
    ```yaml
    endpoint: /containers/json
    method: GET
    register:
      query:
        filters: '{"label":{"navy":true}}'
      as:
        id: registercontainersjson
        scope: *
    ```
    The result of the `/containers/json` request will be store into the `registercontainersjson` variable into your GO templates. It will be visible into all your Requests & Commands.

### `Datasource.id`

- **type**: string
- **required**: false
- **default value**: `""`
- **description**: An **alphanumeric** string allowing you to access your Datasource in a more readable way in your Go templates.

### `Datasource.source`

- **type**: string
- **required**:
    - required if used into the `datasources` list,
    - ignored if used into the `Register.as` field.
- **description**: The path (relative to your main Navy file) of the YAML file you want to use as a Datasource.

### `Datasource.scope`

- **type**: string
- **required**: false
- **default**: `*`
- **description**: An extended regex pattern applied on the `id` field of Requests and Commands. It allows you to filter access to the Datasource.

## Anchor object

- **description**: A YAML file containing anchors definitions.
- **exemples**:
    - Here an exemple of an Anchor object used into the `anchors` list:
    ```yaml
    source: anchors/volumes.yaml
    in:
      - volumes/create.yaml
      - volumes/cleanup.yaml
    ```
    Anchors from `anchors/volumes.yaml` will be visible into `volumes/create.yaml` and `volumes/cleanup.yaml`
    - Here an exemple of the YAML file content containing anchors you want to share with other files:
    ```yaml
    ---
    # anchors/volumes.yaml

    x-volume: &volume
      Type: volume
      VolumeOptions: {}
    x-volume-ro: &readonly-volume
      <<: *volume
      ReadOnly: true

    ...
    ```

### `Anchor.source`

- **type**: string
- **required**: true
- **description**: The path (relative to your main Navy file) of the YAML file that defines anchors you want to use outside.

### `Anchor.in`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: A list of YAML filepaths (relative to your main Navy file) where anchors from the `Anchor.source` path will be visible.

## Query & Path dictionnaries

[Here](https://docs.docker.com/engine/api/v1.45/#tag/Container/operation/ContainerInspect) a simple Docker Engine API endpoint to make quickly the distinction between both.

Query fields are listed [here](https://docs.docker.com/engine/api/latest) and depends of:
- the Docker Engine API you are targetting,
- the endpoint and method you want to submit to the Docker Engine.

### `Query.buildargs`

TODO
