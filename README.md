```
Please note that this is only a sample of the code.
```

# Adsamba
Auto generate home folders based on Active Directory accounts. This script is designed to be run on a Linux (Ubuntu) server.<br>
Adsamba is designed to be used in an Active Directory environment already pre-configured with quotas and email. This script will need to be modified by the user with correct active directory configuration for your institute.

## Installation
Adsamba is designed to be run daily and should be copied to /etc/cron.daily to be run each morning. 

## What does it do?
It will create a new directory per user from the configured OU (or OUs), and automatically archive them when their account is removed. Adsamba will, by default, create a log for each time it runs and store it for a year.
Adsamba also utilises sendmail to email a support address each time the script is run, with a full log of all changes it has made.

## IMPORTANT
You should set up an LDAP bind account with minimal access. You will also need the credentials stored in a passwd file to avoid needing to copy them directly into this script.
Adsamba was designed with our specific needs and infrastructure in mind. It will need to be modified to suit third party environments.
