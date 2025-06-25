# pingloop-systemd-service
Systemd сервис с лимитами через slice. Пример с pingloop.sh
#Скрипт который будет выполнятся процессом.
	vim /usr/local/bin/pingloop.sh

--------------------------------------------------------
	#!/bin/bash

	LOGFILE="/var/log/pingloop.log"
	MEM=""
	while true; do
		echo "$(date): pinging 8.8.8.8..." >> "$LOGFILE"
		MEM="$MEM $(head -c 5M /dev/urandom | base64)"
		ping -c 1 8.8.8.8 >> "$LOGFILE" 2>&1
		sleep 5
	done
--------------------------------------------------------
# Делаем скрипт исполняемым
	chmod +x /usr/local/bin/pingloop.sh

#Создаем пустой лог-файл
	touch /var/log/pingloop.log
	chmod 666 /var/log/pingloop.log

#Создаем Unit-файл pingloop.service
vim /etc/systemd/system/pingloop.service
--------------------------------------------------------
	[Unit]
	Description=Pingloop service to ping 8.8.8.8 every 5 seconds
	After=network.target

	[Service]
	ExecStart=/usr/local/bin/pingloop.sh
	Restart=always
	RestartSec=3
	Slice=pingloop.slice

	[Install]
	WantedBy=multi-user.target
--------------------------------------------------------

#Создаём slice pingloop.slice с лимитами
	vim /etc/systemd/system/pingloop.slice
--------------------------------------------------------
	[Unit]
	Description=Slice for pingloop service

	[Slice]
	CPUQuota=5%
	MemoryLimit=40M
--------------------------------------------------------

#Перезагружаем конфигурации
	sudo systemctl daemon-reexec && sudo systemctl daemon-reload

#Запускаем сервис и slice
	systemctl start pingloop.service
	systemctl start pingloop.slice


#Смотрим на работу процессов
	systemd-cgtop -p pingloop.slice
#Смотрим в хвост лога, по желанию ))
	tail -f /var/log/pingloop.log
