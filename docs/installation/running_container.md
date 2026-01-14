---
layout: default
title: "Running the server"
parent: "📥 Installation"
nav_order: 4
---

## Running the container.

Make sure to SSH from a desktop environment into the Docker container. If you run Docker on your current machine, use the following command:

```bash
docker exec -it CONTAINER_NAME /bin/sh
```

>Tip to get the name of the docker container use `docker ps`

1. **Authentication cli tool** Follow the on-screen prompts to authorize the hytale-downloader. Once verified via the hytale website, the tool will fetch the server files. The container will then automatically extract the package.

> **WARNING** This step may take a while. do not stop the process unless an error occurs.

3. **Authentication hytale server** Every time you start the container, the server will start automatically. You only need to authorise the server.

To authenticate the server you run this code in the docker machine host terminal:

```bash
docker attach CONTAINER_NAME
```

Then in the terminal you should see a ">" sign instead of a "$" sign. Then you can type the following:

```bash
/auth login device
```
Follow the instruction for authorisation

4. Done!