#this will make two docker containers for fraud data analysis.  One as the data ingestion, other as the storage and load.  This will be done offline as a small sandbox to test before production on AWS live.

# 1. The Ingest Network (The "Public" Side)
resource "docker_network" "ingestion_vpc" {
  name = "ingestion_network"
}

# 2. The Analytics Network (The "Private" Vault)
resource "docker_network" "analytics_vpc" {
  name = "analytics_network"
}