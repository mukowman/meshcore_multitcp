# meshcore_multitcp

multiplexing a meshcore tcp-connected companion to multiple clients as cli-chat, observer or bots

## what you can do with this software

- use one companion with multiple client-apps simultaneously

## what you will need

- companion radio with wifi-firmware to allow tcp-connections
- linux device (tested under debian trixie) **or Docker**
- python3 (not required when using Docker)
- python meshcore package (pip install meshcore) *(not required when using Docker)*

---

## usage (native Python)

```bash
python3 meshcore_multitcp.py -d Device-IP:PORT -s Server-IP:PORT [-q|-v]
```

- **-d** sets IP & port of your companion radio  
- **-s** sets IP & port of the machine this script listens to clients  
- **-q** minimizes CLI-output  
- **-v** maximizes CLI-output  
- **-f** sets secondary IP & port for listening to clients using message-storage (see S&F)  
- **-sql** activates message-storage for clients which connect at second ip/port given by `-f` (see S&F)

After meshcore_multitcp is running you can connect your clients to IP/port set with `-s`.

---

## 🐳 usage (Docker)

You can run meshcore_multitcp in a container without installing Python or dependencies.

### Build the image

From the repository root:

```bash
docker build -t meshcore-multitcp .
```

---

### Run — basic mode

Starts the proxy listening on port **5000** and connects to your companion radio.

```bash
docker run -d \
  --name meshcore-multitcp \
  -p 5000:5000 \
  -e SERVER_ADDR="0.0.0.0:5000" \
  -e DEVICE_ADDR="192.168.5.62:5000" \
  meshcore-multitcp
```

Replace `192.168.5.62:5000` with your device IP and port.

Clients can then connect to:

```
<host-ip>:5000
```

---

### Run — Store & Forward (SQLite enabled)

Enables message storage and a secondary forwarding port.

```bash
docker run -d \
  --name meshcore-multitcp \
  -p 5000:5000 \
  -p 5001:5001 \
  -e SERVER_ADDR="0.0.0.0:5000" \
  -e DEVICE_ADDR="192.168.5.62:5000" \
  -e ENABLE_FORWARD="true" \
  -e FORWARD_ADDR="0.0.0.0:5001" \
  -e SQLITE="true" \
  -v meshcore_data:/data \
  meshcore-multitcp
```

---

### Logging options (Docker)

| LOG_LEVEL | Behaviour |
|-----------|-----------|
| `info` (default) | Standard output |
| `quiet` | Minimal logging |
| `debug` | Verbose logging |

Example:

```bash
-e LOG_LEVEL="debug"
```

---

### Environment variables (Docker)

| Variable | Required | Description |
|----------|----------|-------------|
| `SERVER_ADDR` | Yes | IP:PORT for clients to connect |
| `DEVICE_ADDR` | Yes | IP:PORT of companion radio |
| `ENABLE_FORWARD` | No | Enable secondary listener |
| `FORWARD_ADDR` | No | IP:PORT for store-forward clients |
| `SQLITE` | No | Enable message storage |
| `LOG_LEVEL` | No | `info`, `quiet`, or `debug` |

---

### Stop / remove container

```bash
docker stop meshcore-multitcp
docker rm meshcore-multitcp
```

---

## S&F — store & forward messages

Using option `-sql` (or `SQLITE=true` in Docker) meshcore-multitcp will store all incoming private & channel messages in a local sqlite3 database.

If a client connects at the secondary IP/port given by `-f` (or `FORWARD_ADDR` in Docker), meshcore-multitcp will forward all stored messages since the last message exchange.

Dumping a large number of messages can cause hung clients and messages could be lost.

⚠️ WARNING: There is currently no database clean-up.  
If a new client connects for the first time, meshcore-multitcp will attempt to forward all stored messages.

---

## what you should know before you start

This software comes as it is without any guarantee to work stable and secure.  
It contains modified parts of the original meshcore_py-scripts.  
There are several things untested and a lot of bugs in it.  
Some client-app functions don't work as expected and could throw timeout errors or crash the whole app.

---

## TEST
