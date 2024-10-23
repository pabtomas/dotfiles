# Body object

You can start to use a Body object with the `body` keyword.

- **description**: Body of a request. The only use case of this object is in the `Requests.with` attribute.
- **example**:
```json
rule:
  id: 'up'
  run:
    - requests:
        endpoint: /containers/create
        method: POST
        with:
          - body:
              id: containers.create.mycontainer
              query:
                name: mycontainer
    - requests:
        endpoint: /containers/{id}/start
        method: POST
        with:
          - body:
              id: containers.start.mycontainer
              path:
                id: mycontainer
              depends_on:
                - containers.create.mycontainer
```

### `Body.id`

- **type**: string
- **required**: true
- **description**: A unique ID attributed to a request.

### `Body.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: Navy uses as many process as possible and runs a task as soon as possible. So this is here that you can schedule the Navy execution. You can let this list empty but that means that you do not mind that the matching request runs first. This attribute takes a list of ID. Navy will run the request after the tasks listed here will end their execution.

### `Body.errexit`

- **type**: boolean
- **required**: false
- **default**: `true`
- **description**: By default, if the request failed, Navy stops its execution in failure. If you want to change this behavior for a request, set this attribute to `false`.

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
- **description**: [Here](https://docs.docker.com/engine/api/v1.45/#tag/Container/operation/ContainerInspect) a simple Docker Engine API endpoint to make quickly the distinction between Query and Path request parameters. This attribute is required when the `Requests.endpoint` contains variables. Attributes in this dictionnary must match all the variables in the request endpoint.

### `Body.virtual`

- **type**: boolean
- **required**: false
- **default**: false
- **description**: A virtual Body will not result as a request execution by Navy. It is particularly useful when you want to reuse common attributes between Bodies.

### `Body.extends`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: This attribute lets you share common attributes among different Bodies.
    - order in this list is not trivial: if 2 Bodies share a common attribute, the last one prevails. If a Body in this list shares a common attribute with the Body you are extending, the attribute of the Body you are extending prevails:
    **example**:
    ```json
    endpoint: /build
    method: POST
    with:
      - body:
          id: images.build.virtual1
          virtual: true
          query:
            buildargs: |
              {
                "FILEPATH":"/my/file/path"
              }
      - body:
          id: images.build.virtual2
          virtual: true
          query:
            buildargs: |
              {
                "FILEPATH":"/my/other/file/path",
                "USER":"myuser"
              }
      - body:
          id: images.build.myimage
          query:
            buildargs: |
              {
                "USER":"root"
              }
          extends:
            - images.build.virtual1
            - images.build.virtual2
    ```
    will results as this final Body for `images.build.myimage`:
    ```json
      - body:
          id: images.build.myimage
          query:
            buildargs: |
              {
                "FILEPATH":"/my/other/file/path", # images.build.virtual1 prevails on images.build.virtual2
                "USER":"root" # images.build.myimage prevails on images.build.virtual1 and images.build.virtual2
              }
    ```
    - extending from a virtual or a non-virtual Body is different:
        - from a non-virtual Body, the extended Body will inherit these attributes: `query`, `path`, `context`.
        - from a virtual Body, the extended Body will inherit these attributes: `query`, `path`, `context`. `depends_on`.

### `Body.context`

- **type**: string
- **required**: false
- **default**: `"."` for a `/build` request and empty for other endpoints.
- **description**: This attribute is only useful when you are making a `/build` request to the Docker Engine. It defines either a path to a directory containing a Dockerfile, or a URL to a git repository. When the value supplied is a relative path, it is interpreted as relative to the location of your main Navy file. 
- **example**:
```json
endpoint: /build
method: POST
requests:
  - body:
      id: images.build.myimage
      query:
        buildargs: |
          {
            "USER":"root"
          }
        t: 'myimage:latest'
      context: 'dir/of/myimage'
```

### `Body.register`

- **type**: string 
- **required**: false
- **description**: When this attribute is not empty, that means that you want to store the response of the Docker Engine in a variable to use it later in your templates. The response will be stored in the variable with the name you wrote. If the variable is not empty, the content will be erased.
