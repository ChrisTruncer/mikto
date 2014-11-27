#!/bin/bash

# Global Variables
fail=0
args=${@}

# Print Title Function
func_title(){
  clear
  echo '======================================================================'
  echo ' Mikto.sh | [Version]: 1.1.1 | [Updated]: 11.27.2014'
  echo '======================================================================'
}

# Print Menu Function
func_help(){
  echo
  echo "[Usage]...: ${0} -f [HOST FILE] [OPTIONS]"
  echo '[Options].: '
  echo '            [Standard Options]'
  echo '             -f = Host File ([[http[s]://]Hostname/IP[:Port] Format)'
  echo '             -w = Number of Nikto Threads'
  echo '             -t = Timeout (Seconds)'
  echo '             -d = Daemonize'
  echo '             -h = Show this Help Menu with Credits'
  echo
  echo '            [Daemonized Options]'
  echo '             -v = Show Running Threads'
  echo '             -k = Kill Nikto Thread'
  echo '             -a = Reattach to Detached Session'
  echo
  echo '[Session].: When Daemonizing Detach Session with ctrl+a ctrl+d'
  echo
}

# Validate File Function
func_valid_file(){
  if [ ! -f ${2} ]
  then
    echo
    echo "[Error]...: File ${2} does not exist."
    func_help
    exit 1
  else
    return
  fi
}

# Validate Numeric Function
func_valid_num(){
  if [[ ${2} == [0-9]* ]]
  then
    return
  else
    echo
    echo "[Error]...: Option -${1} only accepts numeric arguments."
    func_help
    exit 1
  fi
}

# Validate Daemon Function
func_valid_daemon(){
  if [[ $(screen -list|grep mikto|wc -l) -eq '0' ]]; then
    echo
    echo "[Error]...: Option -${1} only available in daemon mode."
    func_help
    exit 1
  fi
}

# Validate Dettached Session
func_valid_dsession(){
  if [[ $(screen -list|grep mikto|grep Detached|wc -l) -eq '0' ]]; then
    echo
    echo "[Error]...: No detached sessions found."
    echo
    exit 1
  fi
}

# Nikto Function
func_run(){
  # Check Required Switches
  if [[ ! -f "${hostfile}" ]]; then
    echo
    echo "[Error]...: Switch -f is Required."
    func_help
    exit 1
  fi

  # Variables
  host_num=1
  host_cnt=$(cat ${hostfile}|wc -l)

  # Daemonize Statement
  if [[ ${daemon} -eq '2' ]]; then
    screen -dmS mikto sh -c 'echo [*] Daemonizing... ; exec bash'
    screen -S mikto -p 0 -X stuff "echo ; ${0} ${args} $(printf \\r)"
    screen -r
    exit 0
  fi

  # Set Default Settings
  if [[ ${threads} == '' ]]; then
    echo '[>] Setting Default Threads: 5'
    threads=5
  fi

  if [[ ${timeout} == '' ]]; then
    echo '[>] Setting Default Timeout: 10'
    timeout=10
  fi

  # Manage Nikto Threads
  for i in $(cat ${hostfile})
  do
    while [[ $(jobs|wc -l) -ge ${threads} ]]
    do
      sleep 10
    done
    host=$(echo ${i}|sed -e 's,http.*://,,g')
    file=$(echo ${i}|sed -e 's,http.*://,,g' -e 's/:/-/')
    echo "[*] Nikto Thread Started On: ${host} [${host_num}/${host_cnt}]"
    nikto -host ${host} -timeout ${timeout} > ${file}.txt &
    ((host_num++))
  done

  # Clean Up Variables
  unset hostfile

  echo
}

# Print Title
func_title

# Requirements Check
for dep in screen nikto; do
  if [[ $(which ${dep}|wc -l) == '0' ]]; then
    echo "[Error]...: Missing Dependency - ${dep}"
    ((fail++))
  fi
done

if [[ ${fail} -gt '0' ]]; then
  echo '[Error]...: Install Above Dependencies Before Using Mikto.'
  echo
  exit 1
fi

# Show Help If No Arguments
if [[ ${#} -eq 0 ]]; then
  func_help
fi

# While Loop To Enumerate Options/Validate Input/Set Variables
while getopts ":f:w:t:dvkah" opt
do
  case ${opt} in
    f)
      unset hostfile
      export hostfile=${OPTARG}
      func_valid_file ${opt} ${OPTARG}
      ;;
    d)
      daemon=$(ps aux|grep -i mikto|grep -v 'grep '|wc -l)
      ;;
    w)
      threads=${OPTARG}
      func_valid_num ${opt} ${OPTARG}
      ;;
    t)
      timeout=${OPTARG}
      func_valid_num ${opt} ${OPTARG}
      ;;
    v)
      func_valid_daemon ${opt}
      echo -e '[PID]\t[TIME]\t[SITE]' && ps aux|grep -i nikto|awk '!/grep|-d/'|sed 's/\t//g'|tr -s '[:space:]'|cut -d" " -f 2,10,14|tr ' ' '\t'
      echo
      exit 0
      ;;
    k)
      func_valid_daemon ${opt}
      echo -e '[PID]\t[TIME]\t[SITE]' && ps aux|grep -i nikto|awk '!/grep|-d/'|sed 's/\t//g'|tr -s '[:space:]'|cut -d" " -f 2,10,14|tr ' ' '\t'
      echo
      read -p '[?] Enter PID To Kill: ' killthread
      echo "[*] Killing PID #${killthread}"
      kill -9 ${killthread}
      echo '[*] Re-Listing Threads'
      echo
      echo -e '[PID]\t[TIME]\t[SITE]' && ps aux|grep -i nikto|awk '!/grep|-d/'|sed 's/\t//g'|tr -s '[:space:]'|cut -d" " -f 2,10,14|tr ' ' '\t'
      echo
      exit 0
      ;;
    a)
      func_valid_daemon ${opt}
      func_valid_dsession
      screen -r mikto
      exit 0
      ;;
    h)
      echo ' [By]: Mike Wright | [GitHub]: http://github.com/themightyshiv'
      echo '======================================================================'
      func_help
      ;;
    :)
      echo
      echo "[Error]...: Option -${OPTARG} requires an argument."
      func_help
      ;;
    ?)
      echo
      echo "[Error]...: Option -${OPTARG} is not a valid option."
      func_help
      ;;
  esac
done

# Run Mikto
func_run
