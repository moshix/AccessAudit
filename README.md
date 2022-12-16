[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fmoshix%2FAccessAudit&count_bg=%2379C83D&title_bg=%23555555&icon=microsoftsqlserver.svg&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)

Welcome to AccessAudit
======================

What is AccessAudit?
====================

AccessAudit is a script that will do the following for your local and remote Linux machines:

1. Obtain the auditable and immutable database immudb in a container
2. Craete an 'audit' database in it
3. Modify your rsyslog.conf so that all logins to your Linux instance will *also* be logged in the database
4. Give you a tool to query and search the audit database for logins and related info 

Features
========

| Feature                            | Supported          |
| --------------------------         | ------------------ |
| Debian/Ubuntu/Mint   n             | :white_check_mark: |  
| Red Hat/AlmaLinux/Rocky            | :white_check_mark: |  
| Windows                            | :x:                |  
| Obtains latest immudb              | :white_check_mark: |  
| Enables auto-start of db at boot   | :white_check_mark: |  
| Query tool with search for db      | :white_check_mark: |  
| SSL support                        | :white_check_mark: |  
| Teleportation support              | :x:                |

  



Moshix  
December 16, 2022  
