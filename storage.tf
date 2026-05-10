# Landing zone for ingestion data
resource "docker_volume" "raw_landing_storage" {
    name = "raw_landing_storage"
}

#analytics storage
resource "docker_volume" "analytics_vault_storage" {
    name = "analytics_vault_storage"
}

#ingestor container (landing zone)
resource "docker_container" "data_ingestor" {
    name = "fraud-data-generator"
    image = "python:3.9-slim"

    networks_advanced {
        name = docker_network.ingestion_vpc.name
    }

    volumes {
        volume_name = docker_volume.raw_landing_storage.name
        container_path = "/app/raw_data"
    }

    #Keep the container running so we can exec into it
    #optional
    # the command will run indefinitely keeping the container running
    command = ["tail", "-f", "/dev/null"]
}

#analytics container
resource "docker_container" "localstack_analytics" {
    name = "aws-storage-emulator"
    image = "localstack/localstack:latest"

    # apply to analytics Network  using advanced settings in terraform
    networks_advanced { 
        name = docker_network.analytics_vpc.name
    }

    #mount  volume for gold tables
    volumes {
        volume_name = docker_volume.analytics_vault_storage.name
        container_path = "/var/lib/localstack" # Add this line
    }

}

#bridge container for processing

resource "docker_container" "spark_processor" {
    name = "etl-engine"
    image = "apache/spark:3.5.0"

    networks_advanced {name = docker_network.ingestion_vpc.name}
    networks_advanced {name = docker_network.analytics_vpc.name}

    env = [
        "SPARK_MODE=master",
        "SPARK_RPC_AUTHENTICATION_ENABLED=no"  #dontneed it since we're local
    ]

    #keep spark alive
    command = ["/opt/spark/bin/spark-class", "org.apache.spark.deploy.master.Master"]

    #needs to see the ingestion Side
    volumes {
        volume_name = docker_volume.raw_landing_storage.name
        container_path = "/app/raw_data"
    }

    volumes {
        volume_name    = docker_volume.analytics_vault_storage.name
        container_path = "/data/vault"
    }
}