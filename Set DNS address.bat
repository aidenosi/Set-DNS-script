:: This script allows users to set the DNS address for their Wifi and Ethernet adapters to either a default address or a specified DNS (and alternate if desired), or enable DHCP

@echo off

SET default=8.8.8.8

:: Detecting if run as administrator
net session >nul 2>&1
IF %errorLevel%==0 (GOTO :start) 
ECHO Error: Script requires elevated permissions. Please run the script as administrator.
GOTO :end

:: Select connection to set DNS address for
:start
ECHO 	1) Set Wifi DNS
ECHO 	2) Set Ethernet DNS
ECHO 	3) Set both
ECHO.
SET /p connection=Please input your selection: 
IF %connection%==1 (
	SET connection="Wi-Fi"
	GOTO :chooseDNS
)
IF %connection%==2 (
	SET connection="Ethernet"
	GOTO :chooseDNS
)
IF %connection%==3 (
	SET both=1
	SET connection="Wi-Fi"
	GOTO :chooseDNS
)
IF %connection% LEQ 0 GOTO :invalidInput
IF %connection% GEQ 4 GOTO :invalidInput

:: Select DNS address to use
:chooseDNS
ECHO.
ECHO Change DNS for %connection%:
ECHO.
ECHO 	1) Set DNS address to default (%default%)
ECHO 	2) Enter DNS address to set
ECHO 	3) Enable DHCP
ECHO 	0) Return
ECHO.
SET /p dns_choice=Please input your selection: 
IF %dns_choice%==0 (
	SET dns_choice=
	GOTO :start
)
IF %dns_choice%==1 GOTO :defaultDNS
IF %dns_choice%==2 GOTO :otherDNS
IF %dns_choice%==3 GOTO :dhcp
IF %dns_choice% GEQ 4 GOTO :invalidInput

:: Set DNS address to default DNS
:defaultDNS
netsh interface ipv4 set dns %connection% static %default%
ipconfig /flushdns
ECHO DNS address for %connection% set to default DNS (%default%).
GOTO :complete

:: Set DNS address to specified address
:otherDNS
SET /p input_dns_address=Enter the DNS address you wish to use: 
:: Allows user to set an alternate DNS address
SET /p alt_dns_address=Enter the alternate DNS address you wish to use, or press ENTER to not use an alternate address: 
netsh interface ipv4 set dns %connection% static %input_dns_address%
IF DEFINED alt_dns_address (
	netsh interface ipv4 add dns name=%connection% %alt_dns_address% index=2
)
ipconfig /flushdns
ECHO DNS address for %connection% set to %input_dns_address%.
IF DEFINED alt_dns_address (
	ECHO Alternate DNS address for %connection% set to %alt_dns_address%.
)
GOTO :complete

:: Enable DHCP on the chosen connection
:dhcp
netsh interface ipv4 set dns %connection% dhcp
ECHO DHCP enabled for %connection%.
GOTO :complete

:invalidInput
ECHO Error: invalid input.
IF NOT DEFINED dns_choice (GOTO :start)
GOTO :chooseDNS

:complete
IF DEFINED both (
	SET connection="Ethernet"
	SET both=
	GOTO :chooseDNS
)
ECHO.
ECHO Script completed.
:end
set /p=Press ENTER key to exit...