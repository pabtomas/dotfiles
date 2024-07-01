# Explode object

- **description**: A YAML file using anchors definitions from other YAML files.
- **exemples**:
    - Here an exemple of an Explode object used into the `explode` list:
    ```yaml
    anchors:
      - anchors/volumes.yaml
      - anchors/bonds.yaml
    in: volumes/create.yaml
    ```
    anchors from `anchors/volumes.yaml` and `anchors/binds.yaml` will be visible into `volumes/create.yaml`
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

### `Explode.in`

- **type**: string
- **required**: true
- **description**: The path (relative to your main Exodia file) of the YAML file that needs anchors from other YAML files.

### `Explode.anchors`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: A list of YAML filepaths (relative to your main Exodia file) where anchors needed by the `Explode.in` file.
