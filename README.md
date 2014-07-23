Mikto
=====

Description
-----------
Mikto is a wrapper script that provides easy automation, management, and multithreading of Nikto scans.

Usage
-----
**Running Mikto**

 ./Mikto.sh -f [HOST FILE] [OPTIONS]

**Standard Options**
* -f = Host File ([[http[s]://]Hostname/IP[:Port] Format)
* -w = Number of Nikto Threads
* -t = Timeout (Seconds)
* -d = Daemonize
* -h = Show this Help Menu with Credits

**Daemonized Options (Use these switches after detaching from a session.)**
* -v = Show Running Threads
* -k = Kill Nikto Thread
* -a = Reattach to Detached Session

**Sessions Management**
* When daemonizing (-d switch), detach from session with 'ctrl+ad' .
* Session can be reattached using the -a switch or simply calling 'screen -r mikto'.

Host File Formats
-----------------
Mikto accepts a host file with a mixture of [[http[s]://]Hostname/IP[:port]

Examples:
* protocol://hostname.or.ip.address:port
* hostname.or.ip.address:port
* hostname.or.ip.address

Dependencies
------------

* Nikto
* Bash
* Screen
