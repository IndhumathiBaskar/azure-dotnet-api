#Stage 1: Build

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore HelloAzure.csproj
RUN dotnet publish HelloAzure.csproj -c Release -o /app

#Stage 2: Runtime

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app .
EXPOSE 8080
ENTRYPOINT ["dotnet","HelloAzure.dll"]