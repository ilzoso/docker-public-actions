FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
USER ContainerAdministrator
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["docker-public-actions.csproj", "./"]
RUN dotnet restore "docker-public-actions.csproj"
COPY . .
WORKDIR "/src"
RUN dotnet build "docker-public-actions.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "docker-public-actions.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENV ASPNETCORE_URLS="https://+:443;http://+:80"
ENV LOGGING__CONSOLE__FORMATTERNAME=json
ENTRYPOINT ["dotnet", "docker-public-actions.dll"]
