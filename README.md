# Mac_Vivado
2017.4 Vivado docker builder for macos
### How to Run Vivado Docker Image for macOS

This repository contains scripts to create a Docker image with Vivado for macOS. Follow these steps to build the image and run it on your system.

### Prerequisites

- Docker installed on your macOS system.
- Python 3 installed to run a custom HTTP server for file sharing between host and Docker.
- Vivado 2017.4 installer (.zip file) added to the `resources` directory.

### Building the Docker Image

1. Clone this repository to your local machine.

2. Navigate to the repository directory.

3. Execute the `./build.sh` script with the desired Vivado version and build number arguments.

```bash
./build.sh
```

###  Running the Docker Container

After successfully building the Docker image, you can run it with the following commands:

1. Start the Docker container with SSH service enabled:

```bash
docker run -it -p 2222:22 "docker_id" sh -c "service ssh start && bash"
```
2. Forward XQuartz for graphical display:

```bash
docker exec -it -e DISPLAY=host.docker.internal:0 "container_name" /bin/bash
```
3. Share files between host and Docker container using wget:

```bash
wget -q http://host.docker.internal:8000/
```


Make sure to have the custom Python script start_http.py running on the host.

### Automating File Sharing with Alias

To simplify file sharing, you can set up an alias in your shell profile:

1. Edit

```bash
 ~/.zshrc
or
```bash
 ~/.bashrc
```
and add the following line:
```bash
alias share='/dir_to_bash_script/start_http.sh'
```

Replace /dir_to_bash_script/start_http.sh with the path to your bash script.

2. Source the updated shell configuration:
```bash
source ~/.zshrc  # or source ~/.bashrc
```
Now, you can use the share command from any directory to share its contents.

### Additional Notes

1.    Ensure XQuartz is running on your macOS system for graphical forwarding.
2.    Modify the paths in the scripts as necessary to match your environment.
3.    Customize the Vivado version and build number in the ./build.sh script.
4.    The python script and bash script will be on the extras folder

