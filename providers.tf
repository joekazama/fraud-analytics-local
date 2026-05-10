terraform {
    required_providers{
        docker = {
            source = "kreuzwerker/docker"
            version = "~> 3.0.1"
        }
    }
}

provider "docker" {
# This path is the standard "pipe" in WSL2 that connects 
  # your Ubuntu terminal to Docker Desktop on Windows.
  host = "unix:///var/run/docker.sock"
}
    