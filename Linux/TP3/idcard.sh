#!/bin/bash
#03.01.2023 - Adryan
#idcard, en gros faut que sa renvoie nos information.

#Creation des variables contenant les informations
machine_name="$(hostnamectl | grep Trans | cut -d' ' -f3)"
os_name="$(sudo cat /etc/redhat-release)"
version="$(uname)"
ip="$(ip a | grep dynamic | tr -s ' ' | cut -d' ' -f3 | grep 9)"
ram_total="$(free -h | grep Mem | tr -s ' ' | cut -d' ' -f2)"
ram_restante="$(free -h | grep Mem | tr -s ' ' | cut -d' ' -f4)"
espace_restant="$(df -h | grep /dev/sda1 | tr -s ' ' | cut -d' ' -f4)"
process="$(ps  -eo %mem=,cmd= --sort -%mem | head -n5)"

# Mise en page 
echo '____________________________________________________________________________'
echo "Machine name : ${machine_name}"
echo "OS ${os_name} and kernel version is ${version}"
echo "IP : ${ip}"
echo "RAM : ${ram_restante} memory available on ${ram_total}"
echo "Disk : ${espace_restant} space left"
echo "Top 5 processes by RAM usage :"

# Script qui va prendre les lire les lignes 1par1et qui va les print 1par1
#(J'ai add un "-" avant la variables pour print une liste avec un tirer vant chaque print)
while read process; do
  echo "  - $process"
done <<< "$(ps  -eo %mem=,cmd= --sort -%mem | head -n5)"

echo "Listening Port :"

while read port; do

  name="$(echo $port | cut -d' ' -f1)"
  id="$(echo $port | cut -d' ' -f5 | cut -d':' -f2 )"

  echo "  - ${name} ${id} : sshd"


echo "Here is your random cat : $(curl -o catpicture.png https://cataas.com/cat) $(pwd catpicture.png) ./catpitcure"
echo '____________________________________________________________________________'
