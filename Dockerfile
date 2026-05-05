# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy csproj files trước để tận dụng layer cache
COPY ["SRSS.IAM/SRSS.IAM.API/SRSS.IAM.API.csproj",          "SRSS.IAM/SRSS.IAM.API/"]
COPY ["SRSS.IAM/SRSS.IAM.Services/SRSS.IAM.Services.csproj", "SRSS.IAM/SRSS.IAM.Services/"]
COPY ["SRSS.IAM/SRSS.IAM.Repositories/SRSS.IAM.Repositories.csproj", "SRSS.IAM/SRSS.IAM.Repositories/"]
COPY ["Shared/Shared/Shared.csproj", "Shared/Shared/"]

RUN dotnet restore "SRSS.IAM/SRSS.IAM.API/SRSS.IAM.API.csproj"

# Copy toàn bộ source
COPY . .

WORKDIR "/src/SRSS.IAM/SRSS.IAM.API"
RUN dotnet publish "SRSS.IAM.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Tạo user không phải root
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

COPY --from=build --chown=appuser:appgroup /app/publish .

USER appuser

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "SRSS.IAM.API.dll"]
