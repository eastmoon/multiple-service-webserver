@rem
@rem Copyright 2020 the original author jacky.eastmoon
@rem All commad module need 3 method :
@rem [command]        : Command script
@rem [command]-args   : Command script options setting function
@rem [command]-help   : Command description
@rem Basically, CLI will not use "--options" to execute function, "--help, -h" is an exception.
@rem But, if need exception, it will need to thinking is common or individual, and need to change BREADCRUMB variable in [command]-args function.
@rem NOTE, batch call [command]-args it could call correct one or call [command] and "-args" is parameter.
@rem

:: ------------------- batch setting -------------------
@rem setting batch file
@rem ref : https://www.tutorialspoint.com/batch_script/batch_script_if_else_statement.htm
@rem ref : https://poychang.github.io/note-batch/

@echo off
setlocal
setlocal enabledelayedexpansion

:: ------------------- declare CLI file variable -------------------
@rem retrieve project name
@rem Ref : https://www.robvanderwoude.com/ntfor.php
@rem Directory = %~dp0
@rem Object Name With Quotations=%0
@rem Object Name Without Quotes=%~0
@rem Bat File Drive = %~d0
@rem Full File Name = %~n0%~x0
@rem File Name Without Extension = %~n0
@rem File Extension = %~x0

set CLI_DIRECTORY=%~dp0
set CLI_FILE=%~n0%~x0
set CLI_FILENAME=%~n0
set CLI_FILEEXTENSION=%~x0

:: ------------------- declare CLI variable -------------------

set BREADCRUMB=cli
set COMMAND=
set COMMAND_BC_AGRS=
set COMMAND_AC_AGRS=

:: ------------------- declare variable -------------------

for %%a in ("%cd%") do (
    set PROJECT_NAME=%%~na
)
set PROJECT_ENV=dev
set PROJECT_SSH_USER=somesshuser
set PROJECT_SSH_PASS=somesshpass

:: ------------------- execute script -------------------

call :main %*
goto end

:: ------------------- declare function -------------------

:main (
    call :argv-parser %*
    call :%BREADCRUMB%-args %COMMAND_BC_AGRS%
    call :main-args %COMMAND_BC_AGRS%
    IF defined COMMAND (
        set BREADCRUMB=%BREADCRUMB%-%COMMAND%
        call :main %COMMAND_AC_AGRS%
    ) else (
        call :%BREADCRUMB%
    )
    goto end
)
:main-args (
    for %%p in (%*) do (
        if "%%p"=="-h" ( set BREADCRUMB=%BREADCRUMB%-help )
        if "%%p"=="--help" ( set BREADCRUMB=%BREADCRUMB%-help )
    )
    goto end
)
:argv-parser (
    set COMMAND=
    set COMMAND_BC_AGRS=
    set COMMAND_AC_AGRS=
    set is_find_cmd=
    for %%p in (%*) do (
        IF NOT defined is_find_cmd (
            echo %%p | findstr /r "\-" >nul 2>&1
            if errorlevel 1 (
                set COMMAND=%%p
                set is_find_cmd=TRUE
            ) else (
                set COMMAND_BC_AGRS=!COMMAND_BC_AGRS! %%p
            )
        ) else (
            set COMMAND_AC_AGRS=!COMMAND_AC_AGRS! %%p
        )
    )
    goto end
)

:: ------------------- Main mathod -------------------

:cli (
    goto cli-help
)

:cli-args (
    goto end
)

:cli-help (
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo If not input any command, at default will show HELP
    echo.
    echo Options:
    echo      --help, -h        Show more information with CLI.
    echo.
    echo Command:
    echo      react             Build client website for react.js.
    echo      vue               Build client website for vue.
    echo      angular           Build client website for angular.
    echo      node              Control node server.
    echo      dotnet            Control .net core server.
    echo.
    echo Run 'cli [COMMAND] --help' for more information on a command.
    goto end
)

:: ------------------- Command "react" mathod -------------------

:cli-react (
    @rem Initial cache
    IF NOT EXIST cache\react\modules (
        mkdir cache\react\modules
    )
    IF NOT EXIST cache\react\publish (
        mkdir cache\react\publish
    )
    echo ^> Build image
    docker build --rm^
        -t msw.react:%PROJECT_NAME%^
        ./docker/client/react

    echo ^> Startup docker container instance
    docker rm -f %PROJECT_NAME%-client-react
    docker run -ti -d ^
        -v %cd%\src\client\react\:/repo^
        -v %cd%\cache\react\modules/:/repo/node_modules^
        -v %cd%\cache\react\publish/:/repo/dist^
        -p 8081:3000^
        --name %PROJECT_NAME%-client-react^
        msw.react:%PROJECT_NAME%

    echo ^> Install package dependencies
    docker exec -ti %PROJECT_NAME%-client-react^ bash -l -c "yarn install"

    @rem Execute command
    IF defined DEVELOPER_REACT (
        echo ^> Start deveopment server
        docker exec -ti %PROJECT_NAME%-client-react^ bash -l -c "yarn start"
    )
    IF defined INTO_REACT (
        echo ^> Into container instance
        docker exec -ti %PROJECT_NAME%-client-react^ bash
    )
    IF defined BUILD_REACT (
        echo ^> Build project
        docker exec -ti %PROJECT_NAME%-client-react^ bash -l -c "yarn build"
    )
    goto end
)

:cli-react-args (
    set BUILD_REACT=1
    for %%p in (%*) do (
        if "%%p"=="--dev" (
            set DEVELOPER_REACT=1
            set BUILD_REACT=
        )
        if "%%p"=="--into" (
            set INTO_REACT=1
            set BUILD_REACT=
        )
    )
    goto end
)

:cli-react-help (
    echo Build react.js project.
    echo.
    echo Options:
    echo      --dev             Run dev mode.
    echo      --into            Go into container.
    echo.
    goto end
)

:: ------------------- Command "vue" mathod -------------------

:cli-vue (
    @rem Initial cache
    IF NOT EXIST cache\vue\modules (
        mkdir cache\vue\modules
    )
    IF NOT EXIST cache\vue\publish (
        mkdir cache\vue\publish
    )
    echo ^> Build image
    docker build --rm^
        -t msw.vue:%PROJECT_NAME%^
        ./docker/client/vue

    echo ^> Startup docker container instance
    docker rm -f %PROJECT_NAME%-client-vue
    docker run -ti -d ^
        -v %cd%\src\client\vue\:/repo^
        -v %cd%\cache\vue\modules/:/repo/node_modules^
        -v %cd%\cache\vue\publish/:/repo/dist^
        -p 8082:4000^
        --name %PROJECT_NAME%-client-vue^
        msw.vue:%PROJECT_NAME%

    echo ^> Install package dependencies
    docker exec -ti %PROJECT_NAME%-client-vue^ bash -l -c "yarn install"

    @rem Execute command
    IF defined DEVELOPER_VUE (
        echo ^> Start deveopment server
        docker exec -ti %PROJECT_NAME%-client-vue^ bash -l -c "yarn dev"
    )
    IF defined INTO_VUE (
        echo ^> Into container instance
        docker exec -ti %PROJECT_NAME%-client-vue^ bash
    )
    IF defined BUILD_VUE (
        echo ^> Build project
        docker exec -ti %PROJECT_NAME%-client-vue^ bash -l -c "yarn build"
    )
    goto end
)

:cli-vue-args (
    set BUILD_VUE=1
    for %%p in (%*) do (
        if "%%p"=="--dev" (
            set DEVELOPER_VUE=1
            set BUILD_VUE=
        )
        if "%%p"=="--into" (
            set INTO_VUE=1
            set BUILD_VUE=
        )
    )
    goto end
)

:cli-vue-help (
    echo Build vue.js project.
    echo.
    echo Options:
    echo      --dev             Run dev mode.
    echo      --into            Go into container.
    echo.
    goto end
)

:: ------------------- Command "angular" mathod -------------------

:cli-angular (
    @rem Initial cache
    IF NOT EXIST cache\angular\modules (
        mkdir cache\angular\modules
    )
    IF NOT EXIST cache\angular\publish (
        mkdir cache\angular\publish
    )
    echo ^> Build image
    docker build --rm^
        -t msw.angular:%PROJECT_NAME%^
        ./docker/client/angular

    echo ^> Startup docker container instance
    docker rm -f %PROJECT_NAME%-client-angular
    docker run -ti -d ^
        -v %cd%\src\client\angular\:/repo^
        -v %cd%\cache\angular\modules/:/repo/node_modules^
        -v %cd%\cache\angular\publish/:/repo/dist^
        -p 8083:4200^
        --name %PROJECT_NAME%-client-angular^
        msw.angular:%PROJECT_NAME%

    echo ^> Install package dependencies
    docker exec -ti %PROJECT_NAME%-client-angular^ bash -l -c "yarn install"

    @rem Execute command
    IF defined DEVELOPER_ANGULAR (
        echo ^> Start deveopment server
        docker exec -ti %PROJECT_NAME%-client-angular^ bash -l -c "ng serve --host 0.0.0.0"
    )
    IF defined INTO_ANGULAR (
        echo ^> Into container instance
        docker exec -ti %PROJECT_NAME%-client-angular^ bash
    )
    IF defined BUILD_ANGULAR (
        echo ^> Build project
        docker exec -ti %PROJECT_NAME%-client-angular^ bash -l -c "yarn build"
    )
    goto end
)

:cli-angular-args (
    set BUILD_ANGULAR=1
    for %%p in (%*) do (
        if "%%p"=="--dev" (
            set DEVELOPER_ANGULAR=1
            set BUILD_ANGULAR=
        )
        if "%%p"=="--into" (
            set INTO_ANGULAR=1
            set BUILD_ANGULAR=
        )
    )
    goto end
)

:cli-angular-help (
    echo Build angular.js project.
    echo.
    echo Options:
    echo      --dev             Run dev mode.
    echo      --into            Go into container.
    echo.
    goto end
)

:: ------------------- Command "node" mathod -------------------

:cli-node (
    @rem Initial cache
    IF NOT EXIST cache\node\modules (
        mkdir cache\node\modules
    )
    echo ^> Build image
    docker build --rm^
        -t msw.node:%PROJECT_NAME%^
        ./docker/server/node

    echo ^> Startup docker container instance
    docker rm -f %PROJECT_NAME%-server-node
    docker run -ti -d ^
        -v %cd%\src\server\node\:/repo^
        -v %cd%\cache\node\modules/:/repo/node_modules^
        -p 8001:3000^
        --name %PROJECT_NAME%-server-node^
        msw.node:%PROJECT_NAME%

    echo ^> Install package dependencies
    docker exec -ti %PROJECT_NAME%-server-node^ bash -l -c "yarn install"

    @rem Execute command
    IF defined INTO_NODE (
        echo ^> Into container instance
        docker exec -ti %PROJECT_NAME%-server-node^ bash
    ) else (
        echo ^> Start server
        docker exec -ti %PROJECT_NAME%-server-node^ bash -l -c "yarn start"
    )
    goto end
)

:cli-node-args (
    for %%p in (%*) do (
        if "%%p"=="--into" (
            set INTO_NODE=1
        )
    )
    goto end
)

:cli-node-help (
    echo Build angular.js project.
    echo.
    echo Options:
    echo      --dev             Run dev mode.
    echo      --into            Go into container.
    echo.
    goto end
)

:: ------------------- End method-------------------

:end (
    endlocal
)
