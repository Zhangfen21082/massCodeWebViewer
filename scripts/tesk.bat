@echo off
REM Windows Task Scheduler Manager
REM Interactive CLI tool for creating and managing scheduled tasks

chcp 65001 >nul
setlocal enabledelayedexpansion

:MAIN_MENU
cls
echo ================================================
echo    Windows 任务计划管理器 (Task Manager)
echo ================================================
echo.
echo 1. 创建新任务 (Create New Task)
echo 2. 查看所有任务 (List All Tasks)
echo 3. 查看任务详情 (View Task Details)
echo 4. 修改任务 (Modify Task)
echo 5. 启用/禁用任务 (Enable/Disable Task)
echo 6. 删除任务 (Delete Task)
echo 7. 立即运行任务 (Run Task Now)
echo 8. 查看任务历史 (View Task History)
echo 0. 退出 (Exit)
echo.
set /p "CHOICE=请选择操作 (Enter your choice): "

if "!CHOICE!"=="1" goto CREATE_TASK
if "!CHOICE!"=="2" goto LIST_TASKS
if "!CHOICE!"=="3" goto VIEW_TASK
if "!CHOICE!"=="4" goto MODIFY_TASK
if "!CHOICE!"=="5" goto TOGGLE_TASK
if "!CHOICE!"=="6" goto DELETE_TASK
if "!CHOICE!"=="7" goto RUN_TASK
if "!CHOICE!"=="8" goto VIEW_HISTORY
if "!CHOICE!"=="0" exit /b 0
goto MAIN_MENU

REM ==========================================
REM CREATE NEW TASK
REM ==========================================
:CREATE_TASK
cls
echo ================================================
echo    创建新任务 (Create New Task)
echo ================================================
echo.

REM Task Name
set /p "TASK_NAME=任务名称 (Task Name): "
if "!TASK_NAME!"=="" (
    echo [错误] 任务名称不能为空
    pause
    goto MAIN_MENU
)

REM Script/Program Path
echo.
echo 要执行的脚本或程序路径:
echo (例如: C:\Scripts\backup.bat 或 C:\Program Files\MyApp\app.exe)
set /p "TASK_PATH=程序路径 (Program Path): "
if "!TASK_PATH!"=="" (
    echo [错误] 程序路径不能为空
    pause
    goto MAIN_MENU
)

if not exist "!TASK_PATH!" (
    echo [警告] 文件不存在: !TASK_PATH!
    set /p "CONFIRM=是否继续? (y/n): "
    if /i not "!CONFIRM!"=="y" goto MAIN_MENU
)

REM Arguments (optional)
echo.
set /p "TASK_ARGS=程序参数 (可选, 按Enter跳过): "

REM Working Directory (optional)
echo.
set /p "WORK_DIR=工作目录 (可选, 按Enter跳过): "

REM Schedule Type
echo.
echo ================================================
echo 选择任务触发类型:
echo ================================================
echo 1. 每天运行 (Daily)
echo 2. 每周运行 (Weekly)
echo 3. 每月运行 (Monthly)
echo 4. 系统启动时运行 (At Startup)
echo 5. 用户登录时运行 (At Logon)
echo 6. 自定义间隔运行 (Custom Interval - 每X分钟/小时)
echo.
set /p "SCHED_TYPE=选择类型 (1-6): "

if "!SCHED_TYPE!"=="1" goto DAILY_SCHEDULE
if "!SCHED_TYPE!"=="2" goto WEEKLY_SCHEDULE
if "!SCHED_TYPE!"=="3" goto MONTHLY_SCHEDULE
if "!SCHED_TYPE!"=="4" goto STARTUP_SCHEDULE
if "!SCHED_TYPE!"=="5" goto LOGON_SCHEDULE
if "!SCHED_TYPE!"=="6" goto INTERVAL_SCHEDULE
echo [错误] 无效选择
pause
goto CREATE_TASK

REM --- Daily Schedule ---
:DAILY_SCHEDULE
echo.
echo [每天运行模式]
set /p "START_TIME=开始时间 (格式 HH:MM, 例如 09:00): "
set /p "DAYS_INTERVAL=每隔几天运行一次 (默认1=每天): "
if "!DAYS_INTERVAL!"=="" set "DAYS_INTERVAL=1"

set "SCHEDULE_CMD=/SC DAILY /ST !START_TIME! /RI !DAYS_INTERVAL!"
goto CREATE_TASK_EXECUTE

REM --- Weekly Schedule ---
:WEEKLY_SCHEDULE
echo.
echo [每周运行模式]
set /p "START_TIME=开始时间 (格式 HH:MM, 例如 09:00): "
echo.
echo 选择星期几运行 (可多选, 用逗号分隔):
echo MON, TUE, WED, THU, FRI, SAT, SUN
echo 例如: MON,WED,FRI
set /p "DAYS_OF_WEEK=星期: "
if "!DAYS_OF_WEEK!"=="" set "DAYS_OF_WEEK=MON"

set "SCHEDULE_CMD=/SC WEEKLY /ST !START_TIME! /D !DAYS_OF_WEEK!"
goto CREATE_TASK_EXECUTE

REM --- Monthly Schedule ---
:MONTHLY_SCHEDULE
echo.
echo [每月运行模式]
set /p "START_TIME=开始时间 (格式 HH:MM, 例如 09:00): "
set /p "DAY_OF_MONTH=每月第几天运行 (1-31, 或 * 表示每天): "
if "!DAY_OF_MONTH!"=="" set "DAY_OF_MONTH=1"

set "SCHEDULE_CMD=/SC MONTHLY /ST !START_TIME! /D !DAY_OF_MONTH!"
goto CREATE_TASK_EXECUTE

REM --- Startup Schedule ---
:STARTUP_SCHEDULE
echo.
echo [系统启动时运行]
set "SCHEDULE_CMD=/SC ONSTART"
goto CREATE_TASK_EXECUTE

REM --- Logon Schedule ---
:LOGON_SCHEDULE
echo.
echo [用户登录时运行]
set "SCHEDULE_CMD=/SC ONLOGON"
goto CREATE_TASK_EXECUTE

REM --- Custom Interval Schedule ---
:INTERVAL_SCHEDULE
echo.
echo [自定义间隔运行]
echo 此模式会创建一个每天运行的任务，并设置重复间隔
echo.
set /p "START_TIME=首次开始时间 (格式 HH:MM, 例如 00:00): "
if "!START_TIME!"=="" set "START_TIME=00:00"

echo.
echo 选择间隔单位:
echo 1. 分钟 (Minutes)
echo 2. 小时 (Hours)
set /p "INTERVAL_UNIT=选择 (1-2): "

if "!INTERVAL_UNIT!"=="1" (
    set /p "INTERVAL_VALUE=每隔多少分钟运行一次 (1-1439): "
    set "REPEAT_INTERVAL=!INTERVAL_VALUE!"
    set "DURATION=1440"
) else if "!INTERVAL_UNIT!"=="2" (
    set /p "INTERVAL_VALUE=每隔多少小时运行一次 (1-23): "
    set /a "REPEAT_INTERVAL=!INTERVAL_VALUE!*60"
    set "DURATION=1440"
) else (
    echo [错误] 无效选择
    pause
    goto CREATE_TASK
)

set "SCHEDULE_CMD=/SC DAILY /ST !START_TIME! /RI !REPEAT_INTERVAL! /DU !DURATION!"
goto CREATE_TASK_EXECUTE

REM --- Execute Task Creation ---
:CREATE_TASK_EXECUTE
echo.
echo ================================================
echo 任务配置摘要:
echo ================================================
echo 任务名称: !TASK_NAME!
echo 程序路径: !TASK_PATH!
if not "!TASK_ARGS!"=="" echo 参数: !TASK_ARGS!
if not "!WORK_DIR!"=="" echo 工作目录: !WORK_DIR!
echo 计划: !SCHEDULE_CMD!
echo ================================================
echo.
set /p "CONFIRM=确认创建此任务? (y/n): "
if /i not "!CONFIRM!"=="y" goto MAIN_MENU

REM Build command
set "CREATE_CMD=schtasks /CREATE /TN "!TASK_NAME!" /TR "!TASK_PATH!""

if not "!TASK_ARGS!"=="" (
    set "CREATE_CMD=!CREATE_CMD! !TASK_ARGS!"
)

if not "!WORK_DIR!"=="" (
    set "CREATE_CMD=!CREATE_CMD! /SD "!WORK_DIR!""
)

set "CREATE_CMD=!CREATE_CMD! !SCHEDULE_CMD! /F"

echo.
echo 正在创建任务...
echo.
%CREATE_CMD%

if errorlevel 1 (
    echo.
    echo [失败] 任务创建失败
    echo 可能需要管理员权限
) else (
    echo.
    echo [成功] 任务创建成功！
)

pause
goto MAIN_MENU

REM ==========================================
REM LIST ALL TASKS
REM ==========================================
:LIST_TASKS
cls
echo ================================================
echo    所有计划任务 (All Scheduled Tasks)
echo ================================================
echo.
schtasks /QUERY /FO LIST /V | findstr /C:"任务名:" /C:"TaskName:" /C:"状态:" /C:"Status:" /C:"下次运行时间:" /C:"Next Run Time:"
echo.
echo ================================================
pause
goto MAIN_MENU

REM ==========================================
REM VIEW TASK DETAILS
REM ==========================================
:VIEW_TASK
cls
echo ================================================
echo    查看任务详情 (View Task Details)
echo ================================================
echo.
set /p "TASK_NAME=输入任务名称: "
if "!TASK_NAME!"=="" goto MAIN_MENU

echo.
echo 任务详细信息:
echo ================================================
schtasks /QUERY /TN "!TASK_NAME!" /FO LIST /V

echo.
pause
goto MAIN_MENU

REM ==========================================
REM MODIFY TASK
REM ==========================================
:MODIFY_TASK
cls
echo ================================================
echo    修改任务 (Modify Task)
echo ================================================
echo.
set /p "TASK_NAME=输入要修改的任务名称: "
if "!TASK_NAME!"=="" goto MAIN_MENU

echo.
echo 选择要修改的内容:
echo 1. 修改运行时间
echo 2. 修改程序路径
echo 3. 启用/禁用任务
echo 0. 返回主菜单
echo.
set /p "MOD_CHOICE=选择 (1-3, 0返回): "

if "!MOD_CHOICE!"=="1" goto MODIFY_TIME
if "!MOD_CHOICE!"=="2" goto MODIFY_PATH
if "!MOD_CHOICE!"=="3" goto TOGGLE_TASK
if "!MOD_CHOICE!"=="0" goto MAIN_MENU
goto MODIFY_TASK

:MODIFY_TIME
echo.
set /p "NEW_TIME=新的运行时间 (格式 HH:MM): "
schtasks /CHANGE /TN "!TASK_NAME!" /ST !NEW_TIME!
echo.
if errorlevel 1 (
    echo [失败] 修改失败
) else (
    echo [成功] 时间已更新
)
pause
goto MAIN_MENU

:MODIFY_PATH
echo.
set /p "NEW_PATH=新的程序路径: "
schtasks /CHANGE /TN "!TASK_NAME!" /TR "!NEW_PATH!"
echo.
if errorlevel 1 (
    echo [失败] 修改失败
) else (
    echo [成功] 路径已更新
)
pause
goto MAIN_MENU

REM ==========================================
REM TOGGLE TASK (Enable/Disable)
REM ==========================================
:TOGGLE_TASK
cls
echo ================================================
echo    启用/禁用任务 (Enable/Disable Task)
echo ================================================
echo.
set /p "TASK_NAME=输入任务名称: "
if "!TASK_NAME!"=="" goto MAIN_MENU

echo.
echo 1. 启用任务 (Enable)
echo 2. 禁用任务 (Disable)
echo.
set /p "TOGGLE_CHOICE=选择 (1-2): "

if "!TOGGLE_CHOICE!"=="1" (
    schtasks /CHANGE /TN "!TASK_NAME!" /ENABLE
    echo [成功] 任务已启用
) else if "!TOGGLE_CHOICE!"=="2" (
    schtasks /CHANGE /TN "!TASK_NAME!" /DISABLE
    echo [成功] 任务已禁用
)

pause
goto MAIN_MENU

REM ==========================================
REM DELETE TASK
REM ==========================================
:DELETE_TASK
cls
echo ================================================
echo    删除任务 (Delete Task)
echo ================================================
echo.
set /p "TASK_NAME=输入要删除的任务名称: "
if "!TASK_NAME!"=="" goto MAIN_MENU

echo.
echo [警告] 即将删除任务: !TASK_NAME!
set /p "CONFIRM=确认删除? (y/n): "
if /i not "!CONFIRM!"=="y" goto MAIN_MENU

schtasks /DELETE /TN "!TASK_NAME!" /F

if errorlevel 1 (
    echo [失败] 删除失败
) else (
    echo [成功] 任务已删除
)

pause
goto MAIN_MENU

REM ==========================================
REM RUN TASK NOW
REM ==========================================
:RUN_TASK
cls
echo ================================================
echo    立即运行任务 (Run Task Now)
echo ================================================
echo.
set /p "TASK_NAME=输入任务名称: "
if "!TASK_NAME!"=="" goto MAIN_MENU

echo.
echo 正在运行任务...
schtasks /RUN /TN "!TASK_NAME!"

if errorlevel 1 (
    echo [失败] 运行失败
) else (
    echo [成功] 任务已启动
)

pause
goto MAIN_MENU

REM ==========================================
REM VIEW TASK HISTORY
REM ==========================================
:VIEW_HISTORY
cls
echo ================================================
echo    查看任务历史 (View Task History)
echo ================================================
echo.
set /p "TASK_NAME=输入任务名称 (留空查看所有): "

echo.
echo 最近的任务运行记录:
echo ================================================

if "!TASK_NAME!"=="" (
    wevtutil qe Microsoft-Windows-TaskScheduler/Operational /c:20 /f:text /rd:true
) else (
    wevtutil qe Microsoft-Windows-TaskScheduler/Operational /c:20 /f:text /rd:true | findstr /C:"!TASK_NAME!"
)

echo.
echo ================================================
echo 注意: 需要管理员权限才能查看完整历史
pause
goto MAIN_MENU