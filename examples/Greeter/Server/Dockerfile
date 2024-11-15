FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy the main source project files
COPY ["Server/Server.csproj", "Server/"]
COPY ["Proto/greet.proto", "Proto/"]

# Restore as distinct layers
RUN dotnet restore "Server/Server.csproj"

# Copy everything else and build
COPY . .
RUN dotnet build "Server/Server.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Server/Server.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Server.dll"]
