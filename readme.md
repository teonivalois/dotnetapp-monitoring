# DotNet Core Sample with Monitoring

## Create the app
```bash
# create the source folder
$ mkdir src

# create the main solution
$ cd src
$ dotnet new sln -n Sample.App

# create the sample app and add it to the solution
$ dotnet new webapp -n Sample.App.Web -f netcoreapp2.2
$ dotnet sln add ./Sample.App.Web/Sample.App.Web.csproj
```

## Instrument the app

```bash
# Add app-metrics packages to the project
$ cd ./Sample.App.Web
$ dotnet add package App.Metrics.AspNetCore.Mvc
$ dotnet add package App.Metrics.AspNetCore.Tracking
$ dotnet add package App.Metrics.Formatters.Prometheus
$ dotnet add package Serilog
$ dotnet add package Serilog.Enrichers.Environment
$ dotnet add package Serilog.Exceptions
$ dotnet add package Serilog.Extensions.Logging
$ dotnet add package Serilog.Sinks.ElasticSearch
```

Once the application is generated, open the ```Startup.cs``` file and add the following line to the ```Startup``` method:

```csharp
var logConfiguration = new LoggerConfiguration()
    .Enrich.FromLogContext()
    .Enrich.WithExceptionDetails()
    .Enrich.WithMachineName();

string elasticUri = Environment.GetEnvironmentVariable("ELASTICSEARCH_HOSTS");
if(!string.IsNullOrEmpty(elasticUri))
    logConfiguration.WriteTo.Elasticsearch(new ElasticsearchSinkOptions(new Uri(elasticUri))
    {
        AutoRegisterTemplate = true,
    });

Log.Logger = logConfiguration.CreateLogger();
```

On the ```Configure``` method, add the ```ILoggerFactory loggerFactory``` as a parameter for the method, so the loggerFactory can be injected, and add the following line of code to enable *Serilog* as the logger:

```csharp
loggerFactory.AddSerilog();
```

Next, on the ```ConfigureServices``` method, add the following:

```csharp
services.AddMvcCore().AddMetricsCore();
```

Finally, add the following ```using``` statements to the ```Startup.cs``` file:

```csharp
using Microsoft.Extensions.Logging;
using Serilog;
using Serilog.Exceptions;
using Serilog.Sinks.Elasticsearch;
```

Then, for the ```Program.cs``` file, on the ```CreateWebHostBuilder```, before calling ```UsingStartUp<Startup>()```, add the following:

```csharp
.ConfigureMetrics(metrics => {
    metrics.OutputMetrics.AsPrometheusPlainText();
    metrics.Configuration.Configure( options => {
        options.AddAppTag();
        options.AddEnvTag();
        options.AddServerTag();
    });
})
.UseMetrics()
.UseMetricsWebTracking()
```

Also, add the following using statements to ```Program.cs```:
```csharp
using App.Metrics;
using App.Metrics.AspNetCore;
```

## Run it
Now run it from the root of the repository:
```bash
$ docker-compose up --build
```

## Monitor it
The provided Grafana setup is already configured with the provided Prometheus as a datasource. You can access the monitoring tools on:

- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090
- cAdvisor: http://localhost:8080

The default credentials for Grafana are **user: admin, password: secret**. Once logged in, import the following grafana dashboards:

- App-Metrics Prometheus Dashboard: **2204**
- cAdvisor Dashboard: **193**

These dashboards will give you a really good insight on how your application is running.****

## Check the logs for it
For logs, **Kibana** will be up and running on port http://localhost:5601