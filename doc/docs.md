# TeamControl Dokumentation

## TeamControl & Reader API

### __Ping__ __-__ __Statusabfrage__
Der Server teilt der Lesestation mit ob diese registriert ist.

| Parameter | Länge | Erlaubte Zeichen | Beispiel |
| --------- | ----- | ---------------- | -------- |
| Identifikation | 12 | 0-9, a-f | 12da4f5aaacd |

Eine Statusabfrage an `/api/v1/ping` wird mittels GET-Request durchgeführt. Im Request ist ein Header mit der Identifikation der Lesestation enthalten.

```
GET
  URL: ServerAdresse/api/v1/ping
  Headers:
    X-Tc-Token: Identifikation
```

Antwortet der Server mit `HTTP-StatusCode: 200` ist ihm die Station bekannt.

  - 200
    - Die Lesestation ist bekannt
  - 401
    - Die Lesestation ist nicht bekannt

### __Event__
Die Lesestation sendet NFC-Tag-IDs an den Server. Der Server antwortet mit einem Status und einer textuellen Meldung auf die ID. Die Daten werden als JSON gesendet und empfangen.

### _Request_

| Request-Parameter | Länge | Erlaubte Zeichen | Beispiel |
| ----------------- | ----- | ---------------- | -------- |
| Identifikation | 12 | 0-9, a-f | 12da4f5aaacd |
| id | 14 | 0-9, a-f | 0e2c122da4bf5a |

Ein Event wird mittels POST-Request an `/api/v1/event` gesendet. Im Request ist wieder der Header mit der Identifikation der Lesestation enthalten. Siehe [Ping - Statusabfrage](#ping-statusabfrage).

```
POST
  Url: ServerAdresse/api/v1/event
  Headers:
    X-Tc-Token: Identifikation
    Content-Type: application/json
  FormData:
    id: NFC-Tag-Id
```

### _Response_

| Response-Parameter | Erlaubte Antwort |
| ------------------ | ---------------- |
| status | info, error, success |
| message | "Textuelle Meldung" |
| title | "Textuelle Zusatzinformation" |

Der Server antwortet mit einem __HTTP-StatusCode__, einem __status__ einer __message__ und einem __title__.

HTTP-StatusCodes

  - 200
    - Die Lesestation ist bekannt und die NFC-Tag-Id wurde erfolgreich verarbeitet
    - Es wird ein __status__, eine __message__ und ein __title__ erwartet
    - status = success
  - 201
    - Ein Tag wurde mit einem Fahrer verknüpft
    - Es wird ein __status__, eine __message__ und ein __title__ erwartet
    - status = success
  - 401
    - Die Lesestation ist nicht bekannt
  - 406
    - Der Server konnte mit der NFC-Tag-Id nichts anfangen
    - Es wird ein __status__, eine __message__ und ein __title__ erwartet
    - status = error
  - 500
    - Der Server konnte mit der NFC-Tag-Id nicht umgehen
    - Bsp. Es existiert kein Rennen
    - Es wird ein __status__, eine __message__ und ein __title__ erwartet
    - status = error




