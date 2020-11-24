@rem This batch script is work on build all project
@rem Build client

call dockerw react
call dockerw vue
call dockerw angular

@rem Build server

call dockerw dotnet
