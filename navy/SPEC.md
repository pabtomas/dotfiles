# Specification

### Keywords:

1. [datasources](#datasources)
2. [anchors](#anchors)
3. [include](#include)
4. [versions](#versions)
5. [rules](#rules)

### Objects:

6. [Rule](#rule-object)
    - [id](#ruleid)
    - [description](#ruledescription)
    - [run](#rulerun)
7. [Request](#request-object)
    - [endpoint](#requestendpoint)
    - [method](#requestmethod)
    - [loop](#requestloop)
    - [register](#requestregister)
    - [from](#requestfrom)
    - [if](#requestif)
8. [Body](#body-object)
    - [id](#bodyid)
    - [depends_on](#bodydepends_on)
    - [errexit](#bodyerrexit)
    - [path](#bodypath)
    - [query](#bodyquery)
    - [virtual](#bodyvirtual)
    - [extends](#bodyextends)
    - [context](#bodycontext)
9. [Register](#register-object)
    - [id](#registerid)
    - [depends_on](#registerdepends_on)
    - [errexit](#registererrexit)
    - [query](#registerquery)
    - [as](#registeras)
10. [From](#from-object)
    - [id](#fromid)
    - [depends_on](#fromdepends_on)
    - [errexit](#fromerrexit)
    - [filter](#fromfilter)
11. [Command](#command-object)
    - [id](#commandid)
    - [depends_on](#commanddepends_on)
    - [errexit](#commanderrexit)
    - [if](#commandif)
    - [argv](#commandargv)
12. [Datasource](#datasource-object)
    - [id](#datasourceid)
    - [source](#datasourcesource)
13. [Anchor](#anchor-object)
    - [source](#anchorsource)
    - [in](#anchorin)

## `datasources`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: List of Datasources available in GO templates. In this list, **A Datasource have to be a YAML file to be correctly processed by Navy**. More details on the Datasource available attributes into the [Datasource object section](#datasource-object).
- **good to know**:
    - The `datasources` keyword is the first thing Navy will processed when executed, its location can not be outside your main Navy file.
- **exemple**:
```yaml
datasources:
  - source: datasources/first.yaml
    id: my-first-datasource
  - source: datasources/second.yaml
    id: my-second-datasource
```

## `anchors`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: List of Anchors. In this list, you can define a YAML file and share its anchors across multiple files. More details on the Anchor available attributes into the [Anchor object section](#anchor-object).
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
  - '{{ $VERSION.ApiVersion }}
```

## `rules`

TODO

- **type**: list
- **required**: true
- **default**: `[]`
- **description**: A list of user defined Rules.
- **exemple**:
```yaml
rules:
```

## Rule object

TODO

### `Rule.id`

TODO

### `Rule.description`

TODO

### `Rule.run`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: A list of Requests and Commands.
- **exemple**:
```yaml
rules:
  - id: 'up'
    run:
      - endpoint: /volumes/create
        method: POST
        loop:
          - query:
              Name: my-volume
          - query:
              Name: my-volume-2
```

## Request object

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
      - query:
          Name: my-net
      - query:
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
- **description**: A From object. This object will be evaluated 2 times. The first one as a GO template. The result of this first resolution is a list. Each element of this list will be evaluated as an element of a `Request.loop` keyword.

### `Request.if`

- **type**: boolean
- **required**: false
- **default**: true
- **description**: The result of this expression must a boolean. It this expression is evaluated as true, the matching Request will be executed. Otherwise, it will not.

## Body object

- **description**: Body of a Request. The only use case of this object is in the `Request.loop` attribute.
- **exemple**:
```yaml
rules:
  - id: 'up'
    run:
      - endpoint: /containers/create
        method: POST
        loop:
          - id: containers.create.mycontainer
            query:
              name: mycontainer
      - endpoint: /containers/{id}/start
        method: POST
        loop:
          - id: containers.start.mycontainer
            path:
              id: mycontainer
            depends_on:
              - containers.create.mycontainer
```

### `Body.id`

- **type**: string
- **required**: true
- **description**: A unique ID attributed to a Request.

### `Body.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: Navy uses as many process as possible and runs a Request (or Command) as soon as possible. So this is here that you can schedule the Navy execution. You can let this list empty but that means that you do not mind that the matching Request or Command runs first. This attribute takes a list of ID. Navy will run the Request after the Requests and Commands listed here are executed.

### `Body.errexit`

- **type**: boolean
- **required**: false
- **default**: `true`
- **description**: If the Request failed, Navy stops its execution in failure.

### `Body.query`

- **type**: dictionnary
- **required**: false
- **default**: `{}`
- **description**: Attributes in this dictionnary are listed [here](https://docs.docker.com/engine/api/latest) and depends of:
    - the Docker Engine API you are targetting,
    - the endpoint and method you want to submit to the Docker Engine.

### `Body.path`

- **type**: Path
- **required**: false
- **default**: `{}`
- **description**: [Here](https://docs.docker.com/engine/api/v1.45/#tag/Container/operation/ContainerInspect) a simple Docker Engine API endpoint to make quickly the distinction between Query and Path Request parameters. This attribute is required when the `Request.endpoint` contains variables. Attributes in this dictionnary must match all the variables in the Request endpoint.

### `Body.virtual`

- **type**: boolean
- **required**: false
- **default**: false
- **description**: A virtual Body will not result as a Request execution by Navy. It is particularly useful when you want to reuse common attributes between Bodies.

### `Body.extends`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: This attribute lets you share common attributes among different Bodies.
    - order in this list is not trivial: if 2 Bodies share a common attribute, the last one prevails. If a Body in this list shares a common attribute with the Body you are extending, the attribute of the Body you are extending prevails:
    **exemple**:
    ```yaml
    endpoint: /build
    method: POST
    loop:
      - id: images.build.virtual1
        virtual: true
        query:
          buildargs: |
          {
            "FILEPATH":"/my/file/path"
          }
      - id: images.build.virtual2
        virtual: true
        query:
          buildargs: |
          {
            "FILEPATH":"/my/other/file/path",
            "USER":"myuser"
          }
      - id: images.build.myimage
        query:
          buildargs: |
          {
            "USER":"root"
          }
        extends:
          - images.build.virtual1
          - images.build.virtual2
    ```
    will results as this requests for `images.build.myimage`:
    ```yaml
      - id: images.build.myimage
        query:
          buildargs: |
          {
            "FILEPATH":"/my/other/file/path", # images.build.virtual1 prevails on images.build.virtual2
            "USER":"root" # images.build.myimage prevails on images.build.virtual1 and images.build.virtual2
          }
    ```
    - extending from a virtual or a non-virtual Body will not share same attributes:
        - from a non-virtual Body, the extended Body will inherit these attributes: `query`, `path`, `context`.
        - from a virtual Body, the extended Body will inherit these attributes: `query`, `path`, `context`. `depends_on`.

### `Body.context`

- **type**: string
- **required**: false
- **default**: `"."`
- **description**: This attribute is only useful when you are making a `/build` Request to the Docker Engine. It defines either a path to a directory containing a Dockerfile, or a URL to a git repository. When the value supplied is a relative path, it is interpreted as relative to the location of your main Navy file. 
- **exemple**:
```yaml
endpoint: /build
method: POST
loop:
  - id: images.build.myimage
    query:
      buildargs: |
      {
        "USER":"root"
      }
      t: 'myimage:latest'
    context: 'dir/of/myimage'
```

## Register object

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

## From object

- **description**: The only use case of this object is in `Request.from`.
- **exemple**: See `Request object`.

### `From.id`

- **type**: string
- **required**: true
- **description**: See `Body.id`.

### `From.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: See `Body.depends_on`.

### `From.errexit`

- **type**: boolean
- **required**: false
- **default**: `true`
- **description**: See `Body.errexit`.

### `From.filter`

- **type**: string
- **required**: true
- **description**: A GO template filter returning a list of Body objects. Each element of this list will be used to run a matching Docker Engine API Request.

## Command object

- **description**: A custom command for specific need or to compensate Navy's lacks.
- **exemples**:
```yaml
rules:
  - id: 'up'
    run:
      - id: commands.install.docker-cli
        argv:
          - 'apk'
          - 'add'
          - '--no-cache'
          - 'docker-cli'
        depends_on:
          - containers.start.my-container
      - id: commands.attach
        argv:
          - 'docker'
          - 'attach'
          - 'my-container'
        depends_on:
          - commands.install.docker-cli
```

### `Command.id`

- **type**: string
- **required**: true
- **description**: See `Body.id`.

### `Command.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: See `Body.depends_on`.

### `Command.errexit`

- **type**: boolean
- **required**: false
- **default**: `true`
- **description**: See `Body.errexit`.

### `Command.if`

- **type**: boolean
- **required**: false
- **default**: true
- **description**: See `Request.if`.

### `Command.argv`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: The list of arguments of your command.

## Datasource object

- **description**:
    - A Datasource is a gomplate concept. Most of the time, you will find everything you need in [the gomplate documentation](https://docs.gomplate.ca/).
    - Used with the `datasources` keyword, the Datasource object have to be YAML file. Used with the `Register.as` keyword, the Datasource object is a JSON answer from Docker Engine. A Datasource has 3 available attributes (each of them is described in its own section):
        - id
        - source
- **exemples**:
    - Here an exemple of a Datasource object used into the `datasources` list:
    ```yaml
    source: datasources/message.yaml
    id: message
    ```
    The `datasources/message.yaml` YAML file will be loaded as Datasource object. You can refer this Datasource as the `$message` variable into your GO templates. It will be visible into all your Requests & Commands.
    - Here an exemple of the YAML file content used by the Datasource object shown above:
    ```yaml
    ---
    # datasources/message.yaml

    sender: Alice
    receiver: Bob

    # You can use the other Datasources in your Datasource files
    message: 'Hello {{ $message.receiver }}, you received a message from {{ $message.sender }}'

    # You can use the special VERSION/INFO Datasources in your Datasource files
    message2: 'Your Docker Engine is using the {{ $VERSION.ApiVersion }} version of the API and is already running {{ $INFO.Containers }} container(s) !'

    ...
    ```
    - Here an exemple of a Datasource object into the `Register.as` attribute:
    ```yaml
    endpoint: /containers/json
    method: GET
    register:
      query:
        filters: '{"label":{"navy":true}}'
      as:
        id: registercontainersjson
    ```
    The result of the `/containers/json` Request will be store into the `registercontainersjson` variable into your GO templates. It will be visible into all your Requests & Commands.

### `Datasource.id`

- **type**: string
- **required**: true
- **description**: An **alphanumeric** string allowing you to access your Datasource in a more readable way in your Go templates.

### `Datasource.source`

- **type**: string
- **required**:
    - required if used into the `datasources` list,
    - ignored if used into the `Register.as` attribute.
- **description**: The path (relative to your main Navy file) of the YAML file you want to use as a Datasource.

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
