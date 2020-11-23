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
    echo.
    echo Run 'cli [COMMAND] --help' for more information on a command.
    goto end
)

:: ------------------- Command "react" mathod -------------------

:cli-react (
    @rem Initial cache
    IF NOT EXIST cache\clietn-react\modules (
        mkdir cache\client-react\modules
    )
    IF NOT EXIST cache\client-react\publish (
        mkdir cache\client-react\publish
    )
    echo ^> Build image
    docker build --rm^
        -t msw.react:%PROJECT_NAME%^
        ./docker/client/react

    echo ^> Startup docker container instance
    docker rm -f %PROJECT_NAME%-client-react
    docker run -ti -d ^
        -v %cd%\src\client\react\:/repo^
        -v %cd%\cache\client-react\modules/:/repo/node_modules^
        -v %cd%\cache\client-react\publish/:/repo/build^
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

:cli-react (
    @rem Initial cache
    IF NOT EXIST cache\clietn-react\modules (
        mkdir cache\client-react\modules
    )
    IF NOT EXIST cache\client-react\publish (
        mkdir cache\client-react\publish
    )
    echo ^> Build image
    docker build --rm^
        -t msw.react:%PROJECT_NAME%^
        ./docker/client/react

    echo ^> Startup docker container instance
    docker rm -f %PROJECT_NAME%-client-react
    docker run -ti -d ^
        -v %cd%\src\client\react\:/repo^
        -v %cd%\cache\client-react\modules/:/repo/node_modules^
        -v %cd%\cache\client-react\publish/:/repo/build^
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

:: ------------------- End method-------------------

:end (
    endlocal
)
