 # Server Monitoring Setup

This document provides a step-by-step guide to setting up a server monitoring system to monitor specific services and resources on a Windows server. The purpose of this system is to troubleshoot development issues and ensure that your development isn't degrading the servers resources. This was made to help monitor and troubleshoot a FileMaker Server and FileMaker Data API. This guide assumes that the user has a basic understanding of PowerShell and Microsoft Graph API.

## Prerequisites

Before you begin, ensure that you have the following prerequisites in place:

- A Windows server with PowerShell installed.
- The MSOnline, ExchangeOnlineManagement, and Microsoft.Graph PowerShell modules installed.
- A Microsoft Graph API app configured with the necessary permissions.
- A Task Scheduler task configured to run the monitoring script at desired intervals.

## Step 1: Install the Necessary PowerShell Modules

Open the PowerShell console on the server and run the following commands to install the required PowerShell modules:

```
Install-Module -Name MSOnline
Install-Module -Name ExchangeOnlineManagement
Install-Module -Name Microsoft.Graph
```

## Step 2: Configure Microsoft Graph API

To configure Microsoft Graph API, follow these steps:

1. Go to https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade.
2. Click on **New Registration**.
3. Add the name of the application in the **Name** field.
4. In the **Redirect URI** section, click the drop-down menu and select **Web**.
5. Put the redirect URI as **http://localhost**.
6. Click **Register**.
7. In the **Overview** window, copy the **Application (client) ID** and **Directory (tenant) ID**.
8. Click on **Certificates & secrets**.
9. Click on **+New client secret**.
10. Enter a **Description**.
11. Set **Expiration**.
12. Copy the **secret value** that was just created.
13. Go to **API Permissions** and add the following user permissions:
    - Mail.Send Application
    - Mail.Send Delegations
    - SMTP.Send Application

## Step 3: Configure Task Scheduler

To configure Task Scheduler, follow these steps:

1. Go to **Server Manager**.
2. Go to **Tools**.
3. Click on **Task Scheduler**.
4. Click on **Create Task**.
5. On the **General** tab Tab Name the task

6. Ensure **Run whether user is logged on or not** is selected

7. Go to the **Triggers Tab**

8. Click **New Trigger**

9. Ensure the Begin the Task has **On a schedule**

10. Select One Time and set the date and time of when to start it

11. In Advanced Settings select **Repeat task every** and set the time interval you desire. 

12. The **for a duration of** is set to indefinitely.

13. Click **Ok**.

14. Go to the **Actions** Tab

15. Click on New

16. Set the Action drop down to **Start a program**

17. Program/Script field needs **Powershell.exe**

18. In the **Add arguments (optional):** to the file path of the powershell script

19. Press Ok

20. Press Ok on the main window to set your schedule task
