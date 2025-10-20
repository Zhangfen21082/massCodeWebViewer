# massCode Web Viewer

A web-based massCode database viewer that allows you to access your code snippets anywhere, anytime.

[中文文档](README_CN.md)

## Background

[massCode](https://github.com/massCodeIO/massCode) is an excellent open-source code snippet management tool that provides powerful code organization and search capabilities, supports syntax highlighting for multiple programming languages, and features a clean and elegant user interface. It greatly improves developers' efficiency in managing code snippets.

![image-20251020160432437](https://obsidian-note-1304818111.cos.ap-guangzhou.myqcloud.com/others/image-20251020160432437.png)

However, **as a desktop application, massCode has an obvious limitation: you cannot access your code snippets anywhere, anytime**. When switching between different devices or when you need to view a code snippet temporarily, it's often impossible to access them in time.

**To solve this problem, I developed massCode Web Viewer**. With just the massCode database file `massCode.db`, you can access your code snippet library from anywhere with internet access using a browser.

**Project Repository**: [Zhangfen21082/massCodeWebViewer](https://github.com/Zhangfen21082/massCodeWebViewer)

![image-20251020160616797](https://obsidian-note-1304818111.cos.ap-guangzhou.myqcloud.com/others/image-20251020160616797.png)

## Main Interface

![image-20251016155814214](https://obsidian-note-1304818111.cos.ap-guangzhou.myqcloud.com/others/image-20251016155814214.png)

![image-20251016155345023](https://obsidian-note-1304818111.cos.ap-guangzhou.myqcloud.com/others/image-20251016155345023.png)

## Key Features

- Full support for massCode database format, browse and search all code snippets
- GitHub OAuth authentication to protect your code snippets
- API Token mechanism for secure database file uploads
- Automatic database backup to prevent data loss
- Dark/Light theme switching for different usage scenarios
- Responsive design, supports desktop and mobile devices
- Code syntax highlighting, consistent with massCode's reading experience

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Zhangfen21082/massCodeWebViewer.git
cd massCodeWebViewer
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure the Application

**Option 1**: Using Configuration File

```bash
cp config.example.json config.json
# Edit config.json with your configuration
```

**Option 2**: Using Web Configuration Interface (http://ip:5000/settings)

After running the application, access the configuration page and complete the setup through the visual interface. The application will automatically restart after saving the configuration.

![image-20251016160122493](https://obsidian-note-1304818111.cos.ap-guangzhou.myqcloud.com/others/image-20251016160122493.png)

### 4. Run the Application

```bash
python app.py
```

The application runs on http://localhost:5000 by default

## Configuration Guide

### Server Configuration

- host: Server binding address, 0.0.0.0 means listening on all network interfaces
- port: Server port number, default is 5000
- debug: Debug mode, set to false in production environments

### Security Configuration

- enabled: Enable/disable security authentication
- authType: Authentication method, currently supports github
- secretKey: Session encryption key, at least 32 characters
- sessionLifetime: Session validity period in seconds, default 86400 (24 hours)

### GitHub OAuth Configuration

1. Visit https://github.com/settings/developers to create an OAuth App
2. Fill in the following information:
   - Application name: Custom name
   - Homepage URL: Your server address
   - Authorization callback URL: http://your-domain.com:5000/auth/callback
3. Get Client ID and Client Secret and fill them into the configuration file
4. Add allowed GitHub usernames to the allowedUsers list

### API Token Configuration

Generate API Tokens in the settings page of the web interface for automated script uploads of database files.

### Application Configuration

- autoLoadDatabase: Automatically load database on startup
- autoRestartOnSave: Automatically restart application after saving configuration
- maxUploadSizeMB: Maximum upload file size (MB)
- uploadDirectory: Upload file storage directory

### Backup Configuration

- enabled: Enable/disable automatic backup
- autoBackupOnUpload: Automatically backup when uploading new database
- maxBackups: Maximum number of backups to keep
- backupDirectory: Backup file storage directory

## Upload massCode.db to Server

### Method 1: Manual Upload

Upload the massCode.db file directly on the upload page of the web interface.

### Method 2: Using Automated Scripts

The project provides cross-platform automated synchronization scripts located in the `scripts` directory:

- sync-to-cloud.bat - Windows batch script
- sync-to-cloud(silent task run and compare).bat - Windows silent script (with file comparison)
- sync-to-cloud.ps1 - Windows PowerShell script
- sync-to-cloud.sh - Linux/macOS Shell script

#### Windows Users

1. Configure the sync script

```bash
cd scripts
copy sync-config.example.json sync-config.json
```

2. Edit sync-config.json file

```json
{
  "serverUrl": "http://your-server-domain.com:5000",
  "apiToken": "your-api-token-here",
  "dbPath": "C:/Users/YourUsername/AppData/Roaming/massCode/storage/massCode.db"
}
```

Configuration details:
- serverUrl: Your server address and port
- apiToken: API Token generated in the web interface settings page
- dbPath: massCode database file path
  - Windows default path: C:/Users/YourUsername/AppData/Roaming/massCode/storage/massCode.db
  - If the script doesn't find the configuration, it will use the default path %APPDATA%\massCode\storage\massCode.db

3. Execute the sync script

**Normal Mode** (Interactive):

Double-click to run `sync-to-cloud.bat` or execute in command line:

```bash
cd scripts
sync-to-cloud.bat
```

**Silent Mode** (Suitable for scheduled tasks):

Double-click to run `sync-to-cloud(silent task run and compare).bat` or execute in command line:

```bash
cd scripts
"sync-to-cloud(silent task run and compare).bat"
```

Silent mode automatically compares local and server database files and only uploads when there are differences.

The script will display the following information:
- Database file path and size
- Server address
- Upload progress and results

#### Linux/macOS Users

1. Configure the sync script

```bash
cd scripts
cp sync-config.example.json sync-config.json
chmod +x sync-to-cloud.sh
```

2. Edit sync-config.json

```json
{
  "serverUrl": "http://your-server-domain.com:5000",
  "apiToken": "your-api-token-here",
  "dbPath": "/path/to/your/massCode.db"
}
```

3. Execute sync

```bash
./sync-to-cloud.sh
```

4. Set up cron scheduled task (Optional)

```bash
crontab -e
```

Add the following line (execute daily at 9:00 AM):

```bash
0 9 * * * cd /path/to/massCodeWebViewer/scripts && ./sync-to-cloud.sh >> /tmp/masscode-sync.log 2>&1
```

### Set Up Windows Automatic Sync Task (Optional)

Use Windows Task Scheduler to create scheduled tasks for automatic synchronization:

**Method 1: Using Interactive Script (Recommended)**

1. Navigate to the scripts directory
2. Double-click to run `task.bat`
3. Follow the prompts to enter task name, execution time, and other information
4. The script will automatically create the scheduled task

![image-20251020161410160](https://obsidian-note-1304818111.cos.ap-guangzhou.myqcloud.com/others/image-20251020161410160.png)

**Method 2: Manual Creation via GUI**

1. Open "Task Scheduler" (Win + R, type taskschd.msc)
2. Click "Create Basic Task" on the right side
3. Name: massCode Auto Sync
4. Trigger: Daily (or according to your needs)
5. Action: Start a program
   - Program/script: `C:\Path\To\massCodeWebViewer\scripts\sync-to-cloud(silent task run and compare).bat`
   - Start in: `C:\Path\To\massCodeWebViewer\scripts`
6. Complete creation

**Method 3: Using Command Line**

```batch
cd scripts
schtasks /create /tn "massCode Auto Sync" /tr "%CD%\sync-to-cloud(silent task run and compare).bat" /sc daily /st 09:00
```

This will create a scheduled task that executes daily at 9:00 AM.

## Deployment Guide

### Local Deployment

```bash
python app.py
```

### Deploy with Gunicorn (Recommended for Production)

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### Deploy with Docker

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

Build and run:

```bash
docker build -t masscode-viewer .
docker run -d -p 5000:5000 -v $(pwd)/config.json:/app/config.json masscode-viewer
```

### Using Nginx Reverse Proxy

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

## Development

### Project Structure

```
massCodeWebViewer/
├── app.py                  # Flask application main file
├── config.json             # Configuration file
├── requirements.txt        # Python dependencies
├── static/                 # Static resources
│   ├── css/
│   └── js/
├── templates/              # HTML templates
├── scripts/                # Automation scripts
│   ├── sync-to-cloud.bat                           # Windows batch script
│   ├── sync-to-cloud(silent task run and compare).bat  # Windows silent script
│   ├── sync-to-cloud.ps1                           # PowerShell script
│   ├── sync-to-cloud.sh                            # Linux/macOS Shell script
│   ├── task.bat                                    # Windows scheduled task creation script
│   └── sync-config.example.json                    # Configuration file example
└── uploads/                # Upload file directory
```

### Development Environment Setup

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows
venv\Scripts\activate
# Linux/macOS
source venv/bin/activate

# Install development dependencies
pip install -r requirements.txt

# Enable debug mode
# Set "debug": true in config.json
python app.py
```

### API Endpoints

- GET /api/snippets - Get all code snippets
- POST /api/upload - Upload database file
- GET /api/search?q=keyword - Search code snippets
- GET /api/folders - Get folder list

### Contributing

Issues and Pull Requests are welcome. Before submitting a PR, please ensure:

1. Code follows PEP 8 standards
2. Add necessary comments and documentation
3. Test that new features work correctly
4. Update relevant documentation

## System Requirements

- Python 3.7+
- Flask 3.0.0+
- Modern browsers (Chrome, Firefox, Safari, Edge)

See `requirements.txt` for complete dependency list

## License

This project is licensed under the MIT License.

## Disclaimer

This project is not affiliated with massCode. It is an independently developed web viewer for massCode databases. When using this project, please comply with massCode's relevant agreements and regulations.

## Support and Feedback

If you encounter problems during use or have suggestions for improvement, feel free to:

- Submit an Issue: https://github.com/Zhangfen21082/massCodeWebViewer/issues
- Project Homepage: https://github.com/Zhangfen21082/massCodeWebViewer
