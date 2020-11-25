## 多服務網路伺服器

此專案為一個多服務來源的整合網站伺服器，透過 Nginx 做路由來統一路由運作

+ Server
  - node.js
  - .net core
+ Client
  - react
  - vue
  - angular

### 專案操作

+ 操作各專案開發、測試、編譯指令

```
dockerw.bat [react | vue | angular | node | dotnet] [--dev | --into]
```
> 此功能會啟動獨立編寫用的開發容器

+ 編譯全專案

```
build.bat
```
> 呼叫全部專案 dockerw 指令

+ 操作整合服務

```
service.bat [start | down]
```
> 此功能透過 docker-compose 啟動複數容器來建立主機關係

測試專案是否正常可以使用以下網址

+ http://localhost:4444/
+ http://localhost:4444/react/
+ http://localhost:4444/vue/
+ http://localhost:4444/node/
+ http://localhost:4444/dotnet/api/values

由於範本 react、vue 要能正常執行必需為根目錄，在此不多加調整；若要正常顯示可調整 ```docker/docker-compose-dev.yml``` 中相關設定

```
services:
  nginx:
    volumes:
      - ../cache/angular/publish/repo/:/usr/share/nginx/html
      - ../cache/react/publish/:/usr/share/nginx/html/react/
```
> 透過調換目錄達到切換網頁根層會顯示的內容，這邊須注意，此處前端的錯誤可透過調整 webpack 的 publish path 調整。

### Server

#### .NET Core

使用 dotnet cli 工具建立專案，此工具可直接引用 [mcr.microsoft.com/dotnet/core/sdk](https://hub.docker.com/_/microsoft-dotnet-sdk) 的 Docker 容器；相關操作細節可參考如下說明：

+ [.NET CLI 總覽](https://docs.microsoft.com/zh-tw/dotnet/core/tools/)
    - [利用 dotnet CLI 安裝並使用套件](https://docs.microsoft.com/zh-tw/nuget/quickstart/install-and-use-a-package-using-the-dotnet-cli)
    - [使用 ASP.NET Core 建立 web API](https://docs.microsoft.com/zh-tw/aspnet/core/tutorials/first-web-api?view=aspnetcore-2.2&tabs=visual-studio-code)

+ 建立 WebAPI 專案

```
dotnet new webapi -o TodoAPI
```

+ 重建相依

```
dotnet build
```
> 在執行  ```dotnet run``` 時，會自動執行此一動作

+ 測試執行

```
cd TodoAPI
dotnet run
```
> 相同指令在 conssole 與 webapi 專案中會有不同的效果

+ 發佈

```
dotnet publish --configuration Release
```
> [dotnet publish](https://docs.microsoft.com/zh-tw/dotnet/core/tools/dotnet-publish) 是將應用程式及其相依性發行至資料夾，以部署至 Runtime 容器中

#### Node.js + LoopBack

使用 loopback cli 工具建立專案，此工具會在 Docker 映像檔階段安裝到專案
> [LoopBack CLI](https://loopback.io/doc/en/lb4/Command-line-interface.html)

```
lb4 app
```
> 透過 loopback cli 指令 ```lb4``` 進行相關專案的操控，此部分可參考上述或相關說明

此框架基於 OpenAPI 與 DDD 開發概念設計，但在 4.X 與 3.X 版本中差距甚多，選用需注意。

+ ```dockerw react``` 啟動專案的伺服器，Server 3000、Docker port: 8001

### Client

#### React

使用 create-react-app 工具建立專案
> [Github : Create React App](https://github.com/facebook/create-react-app)

```
npx create-react-app react
```
> [How to use npx: the npm package runner](https://blog.scottlogic.com/2018/04/05/npx-the-npm-package-runner.html)

+ ```dockerw react --dev``` 啟動 react 專案的開發伺服器，Dev Server 3000、Docker port: 8081

#### Vue

使用 create-vue-app 工具建立專案
> [Github : Create Vue App](https://github.com/vue-land/create-vue-app)

```
npx create-vue-app vue
```
> [How to use npx: the npm package runner](https://blog.scottlogic.com/2018/04/05/npx-the-npm-package-runner.html)

+ ```dockerw vue --dev``` 啟動 vue 專案的開發伺服器，Dev Server 4000、Docker port: 8082

#### Angular

使用 angluar-cli 工具建立專案，此工具會在 Docker 映像檔階段安裝到專案或用 ```npx``` 產生
> [Angular CLI](https://cli.angular.io/)

```
npx @angular/cli new angular
```
> [How to use npx: the npm package runner](https://blog.scottlogic.com/2018/04/05/npx-the-npm-package-runner.html)

+ ```dockerw vue --dev``` 啟動 vue 專案的開發伺服器，Dev Server 4200、Docker port: 8083
