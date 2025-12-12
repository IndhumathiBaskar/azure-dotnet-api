# HelloAzure .NET API Docker Learning

This repository contains a simple **.NET API** project (`HelloAzure`) and a **Dockerfile** for containerizing it.  
It is used for learning **Docker**, **Azure Container Registry (ACR)**, and **Azure Container Apps** deployment.

---

## Project Overview

- Simple .NET API with `/weatherforecast` endpoint
- Returns random weather data
- Built using .NET 10 (or your version)
- Dockerized for container deployment

---

## Prerequisites

- GitHub account  
- Azure free account  
- Codespaces (or local machine with Docker installed)  
- Azure CLI (`az`)  

---

## Steps Completed

### 1. Login to Azure CLI
```bash
az login
````

* Opens a link in browser to authenticate
* After login, Codespaces terminal shows your subscription and tenant

---

### 2. Create Dockerfile

**Dockerfile (Multi-stage build):**

```dockerfile
# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore HelloAzure.csproj
RUN dotnet publish HelloAzure.csproj -c Release -o /app

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app .
EXPOSE 8080
ENTRYPOINT ["dotnet","HelloAzure.dll"]
```

**Explanation:**

* **Stage 1 (Build)**: Restores NuGet packages and compiles the app
* **Stage 2 (Runtime)**: Copies compiled app into smaller runtime image
* `EXPOSE 8080`: Container listens on port 8080
* `ENTRYPOINT`: Runs the compiled `HelloAzure.dll`

---

### 3. Build Docker Image Locally

```bash
docker build -t helloazure:latest .
```

---

### 4. Run Docker Image in Codespaces

```bash
docker run -p 8080:8080 helloazure:latest
```

* Open the **forwarded URL in Codespaces browser**, e.g.:
  `https://special-spoon-xxxx-8080.app.github.dev/weatherforecast`

---

### 5. Push Docker Image to Azure Container Registry (ACR)

```bash
az acr login --name azuredotnetapi
docker tag helloazure:latest azuredotnetapi.azurecr.io/helloazure:latest
docker push azuredotnetapi.azurecr.io/helloazure:latest
```

* **Login**: Authenticates Docker to your Azure Container Registry
* **Tag**: Prepares local image for ACR
* **Push**: Uploads image to ACR

---

### 6. Pull Docker Image from ACR

```bash
docker pull azuredotnetapi.azurecr.io/helloazure:latest
```

* Use this to **redeploy** or test the image elsewhere

---

### 7. Clean-up / Learning Tip

* If you delete the ACR, no problem — your **Dockerfile + source code in GitHub** is enough to rebuild
* Steps to repeat in the future:

  1. Open Codespaces (or local machine)
  2. Clone the repository
  3. Build Docker image
  4. Push to new ACR if needed

---

### ✅ Key Learning Points

* GitHub stores **source code**
* Docker image is a **self-contained package** (compiled app + dependencies + runtime)
* Azure Container Registry stores **Docker images permanently**
* Codespaces is **temporary** — Docker images there disappear if closed

---

## 8. Deploy Docker Image to Azure Container App

1. **Create Container App**

   * Go to **Azure Portal → Container Apps → Create → Container App**
   * Fill in the basics:

     * **Name**: `helloazure-app`
     * **Subscription**: your Azure subscription
     * **Resource Group**: select or create one
     * **Region**: your preferred region

2. **Configure Container**

   * **Image Source**: Azure Container Registry
   * **Registry**: `azuredotnetapi.azurecr.io`
   * **Image**: `helloazure`
   * **Tag**: `latest`
   * **Target Port**: `8080` (matches Dockerfile EXPOSE)
   * **Authentication**: Managed Identity (System-assigned)

3. **Enable Ingress**

   * Check **Enable Ingress**
   * **Ingress type**: HTTP
   * **Target port**: `8080`
   * This allows the app to be publicly accessible

4. **Workload Profile**

   * Choose **Consumption** (0.5 CPU / 1 GiB memory) for learning
   * Click **Review + Create → Create**

5. **Test Public URL**

   * Once deployment completes, go to **Overview → Application URL**
   * Open in browser:

```
https://helloazure-app.<random>.azurecontainerapps.io/weatherforecast
```

* You should see the **Weather Forecast JSON data** from your .NET API.

---

## 9. Update Container App with New Image

* When your app changes:

  1. Rebuild Docker image in Codespaces
  2. Push to ACR with same or new tag
  3. Update Container App image to the new version
  4. Container App automatically creates a new **revision** and serves the updated API

---

### ✅ Key Learning Points – Container App

* Container Apps run **directly from Docker image in ACR**
* **Public URL** works independently of GitHub or Codespaces
* Container Apps handle scaling and networking automatically
* **Ingress must be enabled** to make the app publicly accessible

---



