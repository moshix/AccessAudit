[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fmoshix%2FAccessAudit&count_bg=%2379C83D&title_bg=%23555555&icon=microsoftsqlserver.svg&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)

What is AccessAudit?
====================

AccessAudit is an extension to Linux instances to log all logins securely and tamperproof in in the immudb Vault immutable database for audit and forensic purposes. All logins are logged with rich metadata  (IP, time, user, time etc.). A query tool is provided to query and serach the audit log in the database and export it. 

AccessAudit allows server administrator, auditors etc. to provide a cryptographically strong, and tamperproof tally all accesses to their Linux instances. 


How does AccessAudit Work?
==========================

First, create an account on https://vault.immudb.io and obtian an API key there


AccessAudit is a script that will do the following for your local and remote Linux machines:


3. Modify your rsyslog.conf so that all logins to your Linux instance will *also* be logged in  immudb Vault. They will also continue to be stored in your local system, of course. 
4. Gives you a query tool to search immudb Vault for logins and related info and export values in CSV 

Features
========

| Feature                            | Supported          |
| --------------------------         | ------------------ |
| Debian/Ubuntu/Mint/Arch            | :white_check_mark: |  
| Red Hat/AlmaLinux/Rocky            | :white_check_mark: |  
| Obtains latest immudb              | :white_check_mark: |  
| Enables auto-start of db at boot   | :white_check_mark: |  
| Query tool with search for db      | :white_check_mark: |  
| SSL support                        | :white_check_mark: |  
| Windows                            | :x:                |  
| Extend to other event logging      | Soon               |

  

How To Install AccessAudit
==========================

1. Get the repo:
> git clone git@github.com:moshix/AccessAudit.git

2. Run the installation script
> ./install.bash

3. Use the query program:
>accessaudit last 5 

or

>accessaudit search moshix
  
  
If you experience problems during the install, check out the logs/ directory and then report an issue in this repo. 
  
  
  



Moshix  
July 18, 2022  
