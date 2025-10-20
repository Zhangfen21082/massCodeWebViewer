# massCode Web Viewer

一个基于 Web 的 massCode 数据库查看器，让你随时随地访问自己的代码片段。

## 项目背景

[massCode](https://github.com/massCodeIO/massCode) 是一款优秀的开源代码片段管理工具，提供了强大的代码组织和搜索功能，支持多种编程语言的语法高亮，并且拥有简洁美观的用户界面。它极大地提高了开发者管理代码片段的效率。

![image-20251020160432437](https://obsidian-note-1304818111.cos.ap-guangzhou.myqcloud.com/others/image-20251020160432437.png)

然而，**massCode 作为一款桌面端应用，存在一个明显的局限性：无法随时随地访问自己收藏的代码片段**。当你在不同设备间切换，或者临时需要查看某个代码片段时，往往无法及时获取。

**为了解决这个问题，我开发了 massCode Web Viewer**。只需要 massCode 的数据库文件 `massCode.db`，便可以在任何有网络的地方，使用浏览器访问自己的代码片段库。

**项目地址**：[Zhangfen21082/massCodeWebViewer](https://github.com/Zhangfen21082/massCodeWebViewer)

![image-20251020160616797](https://obsidian-note-1304818111.cos.ap-guangzhou.myqcloud.com/others/image-20251020160616797.png)

## 主界面展示

![image-20251016155814214](https://obsidian-note-1304818111.cos.ap-guangzhou.myqcloud.com/others/image-20251016155814214.png)

![image-20251016155345023](https://obsidian-note-1304818111.cos.ap-guangzhou.myqcloud.com/others/image-20251016155345023.png)

## 核心特性

- 完整支持 massCode 数据库格式，浏览和搜索所有代码片段
- GitHub OAuth 身份认证，保护你的代码片段安全
- API Token 机制，安全上传数据库文件
- 自动数据库备份功能，防止数据丢失
- 深色/浅色主题切换，适应不同使用场景
- 响应式设计，支持桌面和移动设备访问
- 代码语法高亮，保持与 massCode 一致的阅读体验

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/Zhangfen21082/massCodeWebViewer.git
cd massCodeWebViewer
```

### 2. 安装依赖

```bash
pip install -r requirements.txt
```

### 3. 配置应用

**方式一**：使用配置文件

```bash
cp config.example.json config.json
# 编辑 config.json 填入你的配置信息
```

**方式二**：使用 Web 配置界面（http://ip:5000/settings）

直接运行应用后访问配置页面，通过可视化界面完成配置。应用会在保存配置后自动重启。

![image-20251016160122493](https://obsidian-note-1304818111.cos.ap-guangzhou.myqcloud.com/others/image-20251016160122493.png)

### 4. 运行应用

```bash
python app.py
```

应用默认运行在 http://localhost:5000

## 配置说明

### 服务器配置

- host: 服务器绑定地址，0.0.0.0 表示监听所有网络接口
- port: 服务器端口号，默认 5000
- debug: 调试模式，生产环境请设置为 false

### 安全配置

- enabled: 是否启用安全认证
- authType: 认证方式，当前支持 github
- secretKey: 会话加密密钥，至少 32 个字符
- sessionLifetime: 会话有效期，单位秒，默认 86400（24小时）

### GitHub OAuth 配置

1. 访问 https://github.com/settings/developers 创建 OAuth App
2. 填写以下信息：
   - Application name: 自定义名称
   - Homepage URL: 你的服务器地址
   - Authorization callback URL: http://your-domain.com:5000/auth/callback
3. 获取 Client ID 和 Client Secret 填入配置文件
4. 在 allowedUsers 中添加允许访问的 GitHub 用户名

### API Token 配置

在 Web 界面的设置页面中生成 API Token，用于自动化脚本上传数据库文件。

### 应用配置

- autoLoadDatabase: 启动时自动加载数据库
- autoRestartOnSave: 保存配置后自动重启应用
- maxUploadSizeMB: 最大上传文件大小（MB）
- uploadDirectory: 上传文件存储目录

### 备份配置

- enabled: 是否启用自动备份
- autoBackupOnUpload: 上传新数据库时自动备份
- maxBackups: 保留的最大备份数量
- backupDirectory: 备份文件存储目录

## 上传 massCode.db 到服务器

### 方式一：手动上传

在 Web 界面的上传页面直接选择 massCode.db 文件上传。

### 方式二：使用自动化脚本

项目提供了多平台的自动化同步脚本，位于 `scripts` 目录下：

- sync-to-cloud.bat - Windows 批处理脚本
- sync-to-cloud(silent task run and compare).bat - Windows 静默运行脚本（带文件比对）
- sync-to-cloud.ps1 - Windows PowerShell 脚本
- sync-to-cloud.sh - Linux/macOS Shell 脚本

#### Windows 用户使用步骤

1. 配置同步脚本

```bash
cd scripts
copy sync-config.example.json sync-config.json
```

2. 编辑 sync-config.json 文件

```json
{
  "serverUrl": "http://your-server-domain.com:5000",
  "apiToken": "your-api-token-here",
  "dbPath": "C:/Users/YourUsername/AppData/Roaming/massCode/storage/massCode.db"
}
```

配置说明：
- serverUrl: 你的服务器地址和端口
- apiToken: 在 Web 界面设置页面生成的 API Token
- dbPath: massCode 数据库文件路径
  - Windows 默认路径: C:/Users/你的用户名/AppData/Roaming/massCode/storage/massCode.db
  - 如果脚本未找到配置，会使用默认路径 %APPDATA%\massCode\storage\massCode.db

3. 执行同步脚本

**普通模式**（交互式）：

双击运行 `sync-to-cloud.bat` 或在命令行中执行：

```bash
cd scripts
sync-to-cloud.bat
```

**静默模式**（适合定时任务）：

双击运行 `sync-to-cloud(silent task run and compare).bat` 或在命令行中执行：

```bash
cd scripts
"sync-to-cloud(silent task run and compare).bat"
```

静默模式会自动比对本地和服务器上的数据库文件，仅在有差异时才上传。

脚本会显示以下信息：
- 数据库文件路径和大小
- 服务器地址
- 上传进度和结果



#### Linux/macOS 用户使用步骤

1. 配置同步脚本

```bash
cd scripts
cp sync-config.example.json sync-config.json
chmod +x sync-to-cloud.sh
```

2. 编辑 sync-config.json

```json
{
  "serverUrl": "http://your-server-domain.com:5000",
  "apiToken": "your-api-token-here",
  "dbPath": "/path/to/your/massCode.db"
}
```

3. 执行同步

```bash
./sync-to-cloud.sh
```

4. 设置 cron 定时任务（可选）

```bash
crontab -e
```

添加以下行（每天上午 9:00 执行）：

```bash
0 9 * * * cd /path/to/massCodeWebViewer/scripts && ./sync-to-cloud.sh >> /tmp/masscode-sync.log 2>&1
```

### 设置 Windows 自动同步任务（可选）

使用 Windows 任务计划程序创建定时任务，实现自动同步：

**方法一：使用交互式脚本（推荐）**

1. 进入 scripts 目录
2. 双击运行 `task.bat`
3. 按照提示输入任务名称、执行时间等信息
4. 脚本会自动创建定时任务

![image-20251020161410160](https://obsidian-note-1304818111.cos.ap-guangzhou.myqcloud.com/others/image-20251020161410160.png)

**方法二：通过图形界面手动创建**

1. 打开"任务计划程序"（Win + R，输入 taskschd.msc）
2. 点击右侧"创建基本任务"
3. 名称：massCode 自动同步
4. 触发器：每天（或根据需求选择）
5. 操作：启动程序
   - 程序或脚本：`C:\Path\To\massCodeWebViewer\scripts\sync-to-cloud(silent task run and compare).bat`
   - 起始于：`C:\Path\To\massCodeWebViewer\scripts`
6. 完成创建

**方法三：使用命令行创建**

```batch
cd scripts
schtasks /create /tn "massCode Auto Sync" /tr "%CD%\sync-to-cloud(silent task run and compare).bat" /sc daily /st 09:00
```

这将创建一个每天上午 9:00 执行的定时任务。

## 部署指南

### 本地部署

```bash
python app.py
```

### 使用 Gunicorn 部署（推荐生产环境）

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### 使用 Docker 部署

```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 5000

CMD ["python", "app.py"]
```

构建和运行：

```bash
docker build -t masscode-viewer .
docker run -d -p 5000:5000 -v $(pwd)/config.json:/app/config.json masscode-viewer
```

### 使用 Nginx 反向代理

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## 二次开发

### 项目结构

```
massCodeWebViewer/
├── app.py                  # Flask 应用主文件
├── config.json             # 配置文件
├── requirements.txt        # Python 依赖
├── static/                 # 静态资源
│   ├── css/
│   └── js/
├── templates/              # HTML 模板
├── scripts/                # 自动化脚本
│   ├── sync-to-cloud.bat                           # Windows 批处理脚本
│   ├── sync-to-cloud(silent task run and compare).bat  # Windows 静默脚本
│   ├── sync-to-cloud.ps1                           # PowerShell 脚本
│   ├── sync-to-cloud.sh                            # Linux/macOS Shell 脚本
│   ├── task.bat                                    # Windows 定时任务创建脚本
│   └── sync-config.example.json                    # 配置文件示例
└── uploads/                # 上传文件目录
```

### 开发环境设置

```bash
# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
# Windows
venv\Scripts\activate
# Linux/macOS
source venv/bin/activate

# 安装开发依赖
pip install -r requirements.txt

# 启用调试模式
# 在 config.json 中设置 "debug": true
python app.py
```

### API 接口

- GET /api/snippets - 获取所有代码片段
- POST /api/upload - 上传数据库文件
- GET /api/search?q=keyword - 搜索代码片段
- GET /api/folders - 获取文件夹列表

### 贡献指南

欢迎提交 Issue 和 Pull Request。在提交 PR 前，请确保：

1. 代码遵循 PEP 8 规范
2. 添加必要的注释和文档
3. 测试新功能是否正常工作
4. 更新相关文档

## 系统要求

- Python 3.7+
- Flask 3.0.0+
- 现代浏览器（Chrome、Firefox、Safari、Edge）

完整依赖列表请查看 `requirements.txt`

## 许可证

本项目采用 MIT 许可证。

## 免责声明

本项目与 massCode 官方无关，是一个独立开发的 massCode 数据库 Web 查看器。使用本项目时，请遵守 massCode 的相关协议和规定。

## 支持与反馈

如果你在使用过程中遇到问题，或有改进建议，欢迎：

- 提交 Issue：https://github.com/Zhangfen21082/massCodeWebViewer/issues
- 项目主页：https://github.com/Zhangfen21082/massCodeWebViewer