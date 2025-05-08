# About this project

Running a local LLM model with docker, using `ollama`, `open-webui` images.
An all in one `docker-compose.yml` file and `.env` settings for fast build up a locally running ollama server.
// Purely CPU, this is a simple template. (you can find how to modify the `docker run` command modifications to run with GPU easily.)


# Ollama and Open WebUI Docker Compose Setup

This document explains how to set up and run the Ollama and Open WebUI services using Docker Compose, connecting them to share data and provide a web interface for interacting with models.

## 0. What is `docker-compose.yml`?

A `docker-compose.yml` file is a YAML file that defines how to configure and run multi-container Docker applications. Instead of running each container with separate `docker run` commands, you define all your services (containers), networks, and volumes in one place. The `docker compose` command then uses this file to manage the entire application stack (start, stop, build, etc.) with single commands. It simplifies the process of defining and sharing complex application environments.

## 1. How to Use

To use this setup, follow these steps:

1.  **Clone the Repository:** Obtain the project files by cloning the repository. Navigate into the project directory.

    ```bash
    git clone [https://gerrit.googlesource.com/git-repo](https://gerrit.googlesource.com/git-repo)
    cd ollama-webui # Or the name of the cloned directory
    ```

2.  **Ensure Docker is Running:** Make sure Docker Desktop (which includes Docker Compose) is running on your system (WSL2 in your case).

3.  **Create External Volumes and Network (if they don't exist):**  Docker Compose expects these `volumes` and `network` to be created manually before starting the stack. Create them using the following commands if you haven't already:

    ```bash
    $ bash ./create_env.sh
    ```

4.  **Start the Stack:** Run the following command in your project directory (where `docker-compose.yml` and `.env` are located) to start the containers defined in the file:

    ```bash
    docker compose up -d
    ```
    The `-d` flag runs the containers in detached mode (in the background).

5.  **Access Open WebUI:** Once the containers are running, open your web browser and go to `http://localhost:3000`. You should see the Open WebUI interface, and it should connect to your Ollama instance and show your models.

6.  **Stop the Stack:** To stop and remove the containers and the default network created by Docker Compose, run:

    ```bash
    docker compose down
    ```
    This will stop the services but will NOT remove the named volumes, so your data persists.

## 2. Configuration Files and Variables

This project uses two main configuration files: `.env` for variables and `docker-compose.yml` for service definitions.

### `.env` File

The `.env` file defines variables that customize the `docker-compose.yml` without modifying the YAML directly. Create this file in your project directory:

```dotenv
# .env file
OLLAMA_CONTAINER_NAME=ollama-cpu
OPENWEBUI_CONTAINER_NAME=open-webui-docker

OLLAMA_VOLUME_NAME=ollama-local-share
OPENWEBUI_VOLUME_NAME=open-webui-local-share

# Uncomment the network sections in docker-compose.yml and set this variable
# if you want to use a specific named network instead of the default compose network.
# NETWORK_NAME=ollama-webui-net  
```

---

# Alternative way
```bash
# !bin\bash
# Set the variables defined in your .env file
# (Make sure these match the values you intend to use, e.g., if NETWORK_NAME is uncommented)
export OLLAMA_CONTAINER_NAME="ollama-cpu"
export OPENWEBUI_CONTAINER_NAME="open-webui-docker"

export OLLAMA_VOLUME_NAME="ollama-local-share"
export OPENWEBUI_VOLUME_NAME="open-webui-local-share"

# Set NETWORK_NAME only if you uncommented it in your .env and YAML
export NETWORK_NAME="ollama-webui-net"


# Create the network (only needed the first time, like docker compose up does)
docker network create $NETWORK_NAME

# Create the volumes if they don't already exist
docker volume create $OLLAMA_VOLUME_NAME
docker volume create $OPENWEBUI_VOLUME_NAME

# Stop and remove the old container if it exists
docker stop $OLLAMA_CONTAINER_NAME 2>/dev/null || true
docker rm $OLLAMA_CONTAINER_NAME 2>/dev/null || true

# Run the Ollama container, connecting it to the network and using the volume
docker run -d \
  --name $OLLAMA_CONTAINER_NAME \
  --network $NETWORK_NAME \
  -p 11434:11434 \
  -v ${OLLAMA_VOLUME_NAME}:/root/.ollama \
  ollama/ollama \
  serve


# Stop and remove the old container if it exists
docker stop $OPENWEBUI_CONTAINER_NAME 2>/dev/null || true
docker rm $OPENWEBUI_CONTAINER_NAME 2>/dev/null || true

# Run the Open WebUI container, connecting it to the network, using the volume, and setting the OLLAMA_BASE_URL
docker run -d \
  --name $OPENWEBUI_CONTAINER_NAME \
  --network $NETWORK_NAME \
  -p 3000:8080 \
  -v ${OPENWEBUI_VOLUME_NAME}:/app/backend/data \
  -e OLLAMA_BASE_URL=http://${OLLAMA_CONTAINER_NAME}:11434 \
  --restart always \
  ghcr.io/open-webui/open-webui:latest

```

---