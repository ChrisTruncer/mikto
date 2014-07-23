Mikto
=====

Description
-----------
Mikto is a wrapper script that provides easy automation, management, and multithreading of Nikto scans.

Usage
-----
**Running Mikto**

 ./Mikto.sh -f [HOST FILE] [OPTIONS]

**Supported Switches:**

[Standard Options]
* -f = Host File ([[http[s]://]Hostname/IP[:Port] Format)
* -w = Number of Nikto Threads
* -t = Timeout (Seconds)
* -d = Daemonize
* -h = Show this Help Menu with Credits

[Daemonized Options]
Note: Use these switches after detaching from a session.
* -v = Show Running Threads
* -k = Kill Nikto Thread
* -a = Reattach to Detached Session

[Sessions Management]
* When Daemonizing Detach Session with 'ctrl+ad' .
* Session can be reattached using -a or simply calling 'screen -r mikto'.

Dependencies
------------

* Nikto
* Bash
* Screen
