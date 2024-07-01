# Datasource object

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
    The `datasources/message.yaml` YAML file will be loaded as Datasource object. You can refer this Datasource as the `$message` variable into your Golang templates. It will be visible into all your Requests & Commands.
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
      id: register.containers.json
      query:
        filters: '{"label":{"exodia":true}}'
      as:
        id: registercontainersjson
    ```
    The result of the `/containers/json` Request will be store into the `registercontainersjson` variable into your Golang templates. It will be visible into all your Requests & Commands.

### `Datasource.id`

- **type**: string
- **required**: true
- **description**: An **alphanumeric** string allowing you to access your Datasource in a more readable way in your Golang templates.

### `Datasource.source`

- **type**: string
- **required**:
    - required if used into the `datasources` list,
    - ignored if used into the `Register.as` attribute.
- **description**: The path (relative to your main Exodia file) of the YAML file you want to use as a Datasource.
