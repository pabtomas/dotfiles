# Body object

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
