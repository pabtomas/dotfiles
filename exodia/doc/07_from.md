# From object

- **description**: The only use case of this object is in `Request.from`.
- **exemple**: This is the same exemple you can find in the `Request object` section:
```yaml
if: '{{ gt (len $registernetworks) 0 }}'
endpoint: /networks/{id}
method: DELETE
from:
  id: from.networks.json
  filter: '{{ $array := "" }}{{ range $registernetworks }}{{ $array = print $array "{\"path\":{\"id\":\"" .Name "\"}}," }}{{ end }}{{ print "[" $array "]" | data.YAMLArray }}'
  depends_on:
    - networks.json
```
This Request object will send a network deletion to the Docker Engine for each network listed in the previously registered Datasource if its content is not empty.

### `From.id`

- **type**: string
- **required**: true
- **description**: A unique ID. This field will not be transmitted to the Requests created by the template.

### `From.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: Exodia uses as many process as possible and runs a Request (or Command) as soon as possible. So this is here that you can schedule the Exodia execution. You can let this list empty but that means that you do not mind that the matching Request or Command runs first. This attribute takes a list of ID. Exodia will run the Request after the Requests and Commands listed here will end their execution. This field will not be transmitted to the Requests created by the template.

### `From.errexit`

- **type**: boolean
- **required**: false
- **default**: `true`
- **description**: If the filter Request failed, Exodia stops its execution in failure. This field will not be transmitted to the Requests created by the template.

### `From.filter`

- **type**: string
- **required**: true
- **description**: A Golang template filter returning a list of Body objects. Each element of this list will be used to run a matching Docker Engine API Request. Please build the result as a string containing a YAML array. When you want to return the result print and pipe it to the `data.YAMLArray` filter:
```yaml
filter: '{{ $array := "" }}{{ $array = print $array "{\"fruit\":\"apple\"}" }}{{ print "[" $array "]" | data.YAMLArray }}"
```
