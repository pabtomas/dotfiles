# Rule object

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
