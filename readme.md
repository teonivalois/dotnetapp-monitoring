# DotNet Core Sample with Monitoring

## Create the app
```bash
# create the source folder
$ mkdir src

# create the main solution
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
```

Once the application is generated, open the ```Startup.cs``` file and add the following line to the ```ConfigureServices``` method:

```csharp
services.AddMvcCore().AddMetricsCore();
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

## Run it
```bash
$ docker-compose up --build
```

## Monitor it
Go to http://localhost:3000 to load Grafana. The default credentials are **user: admin, password: secret**. Once logged in, add the prometheus datasource (http://prometheus:9090) and import the following grafana dashboards:

- App-Metrics Prometheus Dashboard: **2204**
- cAdvisor Dashboard: **193**

These dashboards will give you a really good insight on how your application is running.