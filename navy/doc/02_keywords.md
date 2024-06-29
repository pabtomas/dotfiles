# Keywords

## `datasources`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: List of Datasources available in Golang templates. In this list, **A Datasource have to be a YAML file to be correctly processed by Navy**. More details on the Datasource available attributes into the [Datasource object section](#datasource-object).
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

## `explode`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: List of Explode objects. In this list, you can define a YAML file and specify where its anchors are coming from. More details on the Explode available attributes into the [Explode object section](#explode-object).
- **good to know**:
    - The `explode` keyword is processed after the `datasources` keyword when Navy is executed and before the `include` keyword. Its location is in your main Navy file.
- **exemple**:
```yaml
explode:
  - anchors:
      - anchors/file.yaml
      - anchors/file2.yaml
    in: anchors-user1.yaml
  - anchors:
      - anchors/file.yaml
    in: anchors-user2.yaml
```

## `include`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: List of files to include into the current file. Including files in another will merge their contents. Each file can contain its own `include` list.
- **good to know**:
    - The `include` keyword is processed after the `explode` keyword when Navy is executed
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
