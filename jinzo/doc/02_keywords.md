# Keywords

## `inventory`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: List of files containing variables available in Mustache templates and JQ filters. In this list, **An inventory have to be a JSON file to be correctly processed by Jinzo**. More details on the Inventory object available attributes into the [dedicated section](#inventory-object).
- **good to know**:
    - The `inventory` keyword is the first thing Jinzo will processed when executed, its location can not be outside your main Jinzo file.
- **example**:
```json
inventory:
  - source: inventory/message.json
    register: message
```
The `inventory/message.json` file will be parsed and loaded. You can refer this inventory as the `message` variable into your templates and filters. It will be visible into all your tasks.
- Here an example of the JSON file content used by the Inventory object shown above:
```json
# inventory/message.json

sender: Alice
receiver: Bob

# You can use content from other Inventory files
message: 'Hello {{ message.receiver }}, you received a message from {{ message.sender }}'

# You can use the special VERSION/INFO Inventory in your Inventory files
message2: 'Your Docker Engine is using the {{ VERSION.ApiVersion }} version of the API and is already running {{ INFO.Containers }} container(s) !'
```

## `include`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: List of files to include into the current file. Including files in another will merge their contents. Each file can contain its own `include` list.
- **good to know**:
    - The `include` keyword is processed after the `inventory` keyword when Jinzo is executed
- **example**:
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
- **description**: List of Docker Engine API versions targetted by your project. Jinzo will run with the first available version. Jinzo will fail if the Docker Engine does not support any targetted version.
- **good to know**:
    - For the Docker Engine API versions after 1.25 (included), the documentation specify this:
    ```
    Engine releases in the near future should support this version of the API, so your client will continue to work even if it is talking to a newer Engine.
    ```
    - Here the command line to check your Docker Engine API version with an usual docker client:
    ```
    docker version --format '{{ .Server.APIVersion }}'
    ```
- **example**:
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
- **example**:
```json
rules:
  - id: 'pull_alpine'
    description: 'pull the latest official Dockerhub Alpine image'
```