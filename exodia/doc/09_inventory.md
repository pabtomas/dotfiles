# Inventory object

- **description**:
    - Used with the `inventory` keyword, the Inventory object have to be YAML file. Used with the `Register.as` keyword, the Inventory object is a JSON response from Docker Engine. A Inventory has 3 available attributes (each of them is described in its own section):
        - id
        - source
- **exemples**:
    - Here an exemple of a Inventory object used into the `inventory` list:
    ```yaml
    source: inventory/message.yaml
    id: message
    ```
    The `inventory/message.yaml` YAML file will be loaded as Inventory object. You can refer this Inventory as the `$message` variable into your templates. It will be visible into all your Requests & Commands.
    - Here an exemple of the YAML file content used by the Inventory object shown above:
    ```yaml
    ---
    # inventory/message.yaml

    sender: Alice
    receiver: Bob

    # You can use content from other Inventory files
    message: 'Hello {{ $message.receiver }}, you received a message from {{ $message.sender }}'

    # You can use the special VERSION/INFO Inventory in your Inventory files
    message2: 'Your Docker Engine is using the {{ $VERSION.ApiVersion }} version of the API and is already running {{ $INFO.Containers }} container(s) !'

    ...
    ```
    - Here an exemple of a Inventory object into the `Register.as` attribute:
    ```yaml
    endpoint: /containers/json
    method: GET
    register:
      id: register.containers.json
      query:
        filters: '{"label":{"exodia":true}}'
      as:
        id: registercontainersjson
    ```
    The result of the `/containers/json` Request will be store into the `registercontainersjson` variable into your Golang templates. It will be visible into all your Requests & Commands.

### `Inventory.id`

- **type**: string
- **required**: true
- **description**: An **alphanumeric** string allowing you to access your Inventory in a more readable way in your templates.

### `Inventory.source`

- **type**: string
- **required**:
    - required if used into the `inventory` list,
    - ignored if used into the `Register.as` attribute.
- **description**: The path (relative to your main Exodia file) of the YAML file you want to use as an Inventory.
