## 多服務網路伺服器

此專案為一個多服務來源的整合網站伺服器，透過 .NET 做路由來統一路由運作

+ Server
  - node.js
  - .net core
+ Client
  - react
  - vue
  - angular

### Server

#### .NET Core

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
