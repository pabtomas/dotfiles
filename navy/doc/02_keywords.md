# Keywords

## `inventory`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: List of files containing variables available in Mustache templates. In this list, **An inventory have to be a JSON file to be correctly processed by Navy**. More details on the Inventory object available attributes into the [dedicated section](#inventory-object).
- **good to know**:
    - The `inventory` keyword is the first thing Navy will processed when executed, its location can not be outside your main Navy file.
- **exemple**:
```json
inventory:
  - source: inventory/first.json
    as: my-first-inventory
  - source: inventory/second.json
    as: my-second-inventory
```

## `include`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: List of files to include into the current file. Including files in another will merge their contents. Each file can contain its own `include` list.
- **good to know**:
    - The `include` keyword is processed after the `inventory` keyword when Navy is executed
- **exemple**:
```json
include:
  - networks/create.json
  - volumes/create.json
  - images/pull.json
  - containers/create.json
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
    - Here the command line to check your Docker Engine API version with an usual docker client:
    ```
    docker version --format '{{ .Server.APIVersion }}'
    ```
- **exemple**:
```json
versions:
  - 1.45
  - 1.44
  - 1.43
  - '{{ $VERSION.ApiVersion }}
```

## `rules`

- **type**: list
- **required**: true
- **default**: `[]`
- **description**: A list of user defined rules.
- **exemple**:
```json
rules:
  - id: 'pull_alpine'
    description: 'pull the latest official Dockerhub Alpine image'
```
