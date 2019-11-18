FROM mcr.microsoft.com/dotnet/core/aspnet:2.2 AS base
ARG configuration
RUN if [ ${configuration:-Debug} = Debug ]; then \
        apt-get update && \
        apt-get install -y procps unzip && \
        curl -sSL https://aka.ms/getvsdbgsh | /bin/sh /dev/stdin -v latest -l /vsdbg \
    ; fi
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build
ARG project
ARG configuration

#! Copy solution and projects
WORKDIR /src
COPY *.sln ./
COPY **/*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p ./${file%.*}/ && mv $file ./${file%.*}/; done

RUN dotnet restore
COPY . .

#! Generate Binaries
WORKDIR /src/${project}
RUN dotnet publish ${project}.csproj -c ${configuration:-Debug} -o /app

FROM base AS final
ARG project
WORKDIR /app
COPY --from=build /app .
RUN echo "#!/bin/sh\ncd $(pwd)\ndotnet ${project}.dll" > ./run.sh \
    && chmod +x ./run.sh
ENTRYPOINT ["/app/run.sh"]