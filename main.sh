#!/bin/bash


# Разработать скрипт командной оболочки для обработки текстовых файлов. 
# 1.	У скрипта есть список расширений временных файлов. По умолчанию список состоит из «*.log». 
# 2.	У скрипта есть список расширений рабочих файлов. По умолчанию список состоит из «*.py». 
# 3.	У скрипта есть рабочая папка, в которой выполняется вся работа скрипта. По умолчанию это папка самого скрипта. 
# 4.	Настройки скрипта сохраняются в файле «.myconfig» рядом со скриптом. Если файл при запуске нельзя обнаружить, генерируется файл настроек по умолчанию. 
# 5.	У скрипта есть записанная пользователем в виде строки команда. По умолчанию это «grep def* program.py >last.log». 
# Скрипт должен предоставлять пользователю с помощью меню и текстового интерфейса следующие возможности: 
# 1.	Возможность просмотреть или задать заново список расширений временных файлов. 
# 2.	Возможность добавлять или удалять конкретное расширение из списка расширений временных файлов. Достаточно реализовать удаление по номеру. 
# 3.	Возможность просмотреть или задать заново список расширений рабочих файлов. 
# 4.	Возможность добавлять или удалять конкретное расширение из списка расширений рабочих файлов. Достаточно реализовать удаление по номеру. 
# 5.	Возможность просмотреть, изменить или задать заново рабочую папку скрипта. 
# 6.	Возможность удалить временные файлы. 
# 7. Возможность выполнить или изменить записанную команду. 
# 8.	Возможность просмотреть все строки, ограниченные апострофами, во всех рабочих файлах. 
# 9.	Возможность просмотреть объём каждого временного файла. 
# Скрипт должен иметь возможность запуска в тихом режиме (без меню), для чего следует использовать позиционные аргументы.
# Скрипт не должен позволять запуск от имени администратора.


#  Создание файлов в которых хранятся расширения
createFiles() {
	local file=$(sed -n 1p $confname)
	if [ -e $file ]; then
		echo "File of temp exp is unable!"
	else
		touch $file
		local trash="*.log"
		echo $trash > $file
		echo "File of temp exp is unable!"
	fi

	file=$(sed -n 2p $confname)
	if [ -e $file ]; then
		echo "File of work exp is unable!"
	else
		touch $file
		local work="*.py"
		echo $work > $file
		echo "File of work exp is unable!"
	fi
}


#  Проверка на существование файла .config
confCheck() {
	confname="set.config"
	if [ -e $confname ]; then
		echo "A ready-made config file is used"
		createFiles
	else
		echo "creating a default config file"
		touch $confname
		echo "trash.txt" >> $confname
		echo "work.txt" >> $confname
		echo "grep def* program.py >last.log" >> $confname
		createFiles
	fi
	return 0
}


#  Функция проверяет пользователя на то что он не является суперпользователем
adminCheck() {
	if [ $USER == "root" ]; then
		echo "You are root user. Continue?"
		read answer
		if [ $answer ]; then
			if [ $answer == "Yes" ];then
				echo "WARNING!!! YOU ARE ROOT AND YOU CAN DELETE THE SYSTEM!!!"
			else
				exit 0
			fi
		else
			exit 0
		fi
	else
		echo "YOU ARE NOT ROOT-USER!"
	fi
	return 0
}


#  Функция проверяет ввод позиционных параметров
paramCheck() {
	if [ "$1" == "" ]; then
		echo "menu mod"
		e=0
	else
		echo "non-menu mod"
		e=1
	fi
	return $e
}


#  Функция для чтения пункта меню
menumod() {
	echo You are in menumod
	printMenu
	read menuset
	return $menuset
}


#  Функция для вывода расширений временных файлов
viewTrash(){
	local file=$(sed -n 1p $confname)
	cat $file
}


#  Функция для вывода расширений рабочих файлов
viewWork() {
	local file=$(sed -n 2p $confname)
	cat $file
}


#  Функция для записи заного расширений временных файлов
setTrash(){
	local file=$(sed -n 1p $confname)
	rm $file
	touch $file
	echo "Input quantity of tempFiles"
	read quantity
	local i=0
	while [ $i -lt $quantity ]; do
		read ex
		echo $ex >> $file
		let i++
	done
	echo "New list of expansions:"
	viewTrash
}


#  Функция для записи заного расширений рабочих файлов
setWork() {
	local file=$(sed -n 2p $confname)
	rm $file
	touch $file
	echo "Input quantity of work files"
	read quantity
	local i=0
	while [ $i -lt $quantity ]; do
		read ex
		echo $ex >> $file
		let i++
	done
	echo "New list of expansions:"
	viewWork
}


#  Функция удаления расширения временных файлов
delTrashExp() {
	local file=$(sed -n 1p $confname)
	local i=1
	colStr=`wc -l $file`
	colStr=${colStr% *}  # удаление лишнего
	# echo $colStr
	let colStr++
	# echo $colStr
	while [ $i -lt $colStr ]; do
		echo $i $(sed -n "$i"p $file)
		let i++
	done
	echo "Select the number to be deleted"
	read optinon
	touch "temp.txt"
	sed "$optinon d" $file > "temp.txt"
	cat "temp.txt" > $file
	rm "temp.txt"
	viewTrash
}


#  Функция для удаления расширения рабочих файлов
delWorkExp() {
	local file=$(sed -n 2p $confname)
	local i=1
	colStr=`wc -l $file`
	colStr=${colStr% *}
	let colStr++
	while [ $i -lt $colStr ]; do
		echo $i $(sed -n "$i"p $file)
		let i++
	done
	echo "Select the number to be deleted"
	read optinon
	touch "temp.txt"
	sed "$optinon d" $file > "temp.txt"
	cat "temp.txt" > $file
	rm "temp.txt"
	viewWork
}


#  Функция для удаления расширения временных файлов
addTrashExp() {
	local file=$(sed -n 1p $confname)
	read
	local newExp=$REPLY
	echo $newExp >> $file
	viewTrash
}


# Функция для добавления рабочего расширения
addWorkExp() {
	local file=$(sed -n 2p $confname)
	read
	local newExp=$REPLY
	echo $newExp >> $file
	viewWork
}


#  Вывод папки скрипта
viewWorkFolder () {
	echo "Your work folder:"
	DIR=$( cd $(dirname $0) ; pwd)
	echo $DIR
	ls -F
}


#  Меняет рабочую папку
ChangeWorkFolder () {
	DIR=$( cd $(dirname $0) ; pwd)
	read newDir
	mv $DIR $newDir
	cd $newDir
	echo "Your current place:"
	DIR=$( cd $(dirname $0) ; pwd)
	echo $DIR
}


#  Создание рабочей папки заново
SetWorkFolder () {
	echo "Set work folder"
	DIR=$( cd $(dirname $0) ; pwd)
	find $DIR -type f -not -name 'main.sh' -delete
	confCheck
}


#  Функция для действий с рабочей папкой
workFolder() {
	echo "
1. Просмотреть рабочую папку скрипта.
2. Изменить рабочую папку скрипта.
3. Задать заново рабочую папку скрипта.
"
	read optinon
	if [ $optinon -eq 1 ]; then
		viewWorkFolder
	elif [ $optinon -eq 2 ]; then
		ChangeWorkFolder
	elif [ $optinon -eq 3 ]; then
		SetWorkFolder
	fi
}


#  Функция для удаления временных файлов
rmTempFiles() {
	local file=$(sed -n 1p $confname)
	local i=1
	#  local file2=$(sed -n 2p $confname)
	colStr=`wc -l $file`
	colStr=${colStr% *}
	let colStr++
	while [ $i -lt $colStr ]; do
		local DIR=$(sed -n "$i"p $file)
		#  find $DIR -type f -not -name 'main.sh' -delete
		find $DIR -type f -delete
		let i++
	done
	 echo "Your Folder"
	 ls
}


#  Функция запуска команды пользователя
launchUserCommand() {
	userCommand=$(sed -n 3p $confname)
	$userCommand
}


#  Функция для редактирования команды пользоваетля
EditUserCommand() {
	echo "Input user command"
	read userCommand
	file1=$(sed -n 1p $confname)
	file2=$(sed -n 2p $confname)
	rm $confname
	touch $confname
	echo $file1 >> $confname
	echo $file2 >> $confname
	echo $userCommand >> $confname
	echo "
1. launch User Command
2. Show User Command
"
	read optinon
	if [ $optinon -eq 1 ]; then
		launchUserCommand
	else
		echo $userCommand
		echo "
1. launch User Command
2. exit
"
		read optinon
		if [ $optinon -eq 1 ]; then
			launchUserCommand
		fi
	fi
}


#  Показывает строки в рабочих файлах, ограниченные апострофами
showStrings() {
	echo "show strings"
	local file=$(sed -n 2p $confname)
	folders=(`cut -d@ -f1 $file`)
	lenFolders=${#folders[*]}
	local i=0
	while [ $i -lt $lenFolders ]; do
		local file=${folders[$i]}
		let i++
		echo "From file "$file
		cat $file | grep "^'.*'$"
	done
}


#  Функция вывода объема каждого временного файла
showTrashValue() {
	local file=$(sed -n 1p $confname)
	folders=(`cut -d@ -f1 $file`)
	lenFolders=${#folders[*]}
	local i=0
	while [ $i -lt $lenFolders ]; do
		local file=${folders[$i]}
		let i++
		du -sh $file
	done
}


#  Функция выбора пункта меню
setOption(){
	if [ $menuset -eq 1 ]; then
		echo "
1. view temp expansions
2. set temp expansions
Input optinon (1-2):
"
		read optinon
		if [ $optinon -eq 1 ]; then
			viewTrash
		else
			setTrash
		fi
	elif [ $menuset -eq 2 ]; then
		echo "
1.	Add new expansion
2.	Delete specific expansion
Select option:
"
		read optinon
		if [ $optinon -eq 1 ]; then
			addTrashExp
		else
			delTrashExp
		fi
	elif [ $menuset -eq 3 ]; then
		echo "
1. view work expansions
2. set work expansions
Input optinon (1-2):
"
		read optinon
		if [ $optinon -eq 1 ]; then
			viewWork
		else
			setWork
		fi
	elif [ $menuset -eq 4 ]; then
		echo "
1. Add new expansion
2. Delete specific expansion
Select option:
"
		read optinon
		if [ $optinon -eq 1 ]; then
			addWorkExp
		else
			delWorkExp
		fi
	elif [ $menuset -eq 5 ]; then
		workFolder
	elif [ $menuset -eq 6 ]; then
		rmTempFiles
	elif [ $menuset -eq 7 ]; then
		userCommand=$(sed -n 3p $confname)
		echo "User Command: "$userCommand
		echo "
1. Launch user command
2. Edit user command
"
		read optinon
		if [ $optinon -eq 1 ]; then
			launchUserCommand
		else
			EditUserCommand
		fi
	elif [ $menuset -eq 8 ]; then
		showStrings
	elif [ $menuset -eq 9 ]; then
		echo "Show temp files value"
		showTrashValue

	elif [ $menuset -eq 0 ]; then
		exit 0
	fi
}


#  Функция для вывода меню
printMenu(){
	echo "
1.	просмотреть или задать заново список расширений временных файлов. 
2.	добавлять или удалять конкретное расширение из списка расширений временных файлов.
3.	просмотреть или задать заново список расширений рабочих файлов. 
4.	добавлять или удалять конкретное расширение из списка расширений рабочих файлов.
5.	просмотреть, изменить или задать заново рабочую папку скрипта.
6.	удалить временные файлы. 
7.	выполнить или изменить записанную команду. 
8.	просмотреть все строки, ограниченные апострофами, во всех рабочих файлах. 
9.	просмотреть объём каждого временного файла. 
Введите номер пункта (1-9):
"
}


#  Задать расширения временных файлов заного в тихом режиме
setTemp() {
	echo "Set temp"
	local file=$(sed -n 1p $confname)
	rm $file
	touch $file
	local i=3
	while [ $i -lt $colParams ]; do
		ex=${params[$i]}
		echo $ex >> $file
		let i++
	done
	echo "New list of expansions:"
	viewTrash
}


#  Добавление расширения временных файлов в тихом режиме
addTempExp() {
	local file=$(sed -n 1p $confname)
	local newExp=${params[4]}
	echo $newExp >> $file
	viewTrash
}


#  Удаление расширений временных файлов в тихом режиме
delTempExp() {
	local file=$(sed -n 1p $confname)
	regex=${params[4]}
    #  sed s/$regex// "trash.txt"
    #  sed /http/d "trash.txt"
    touch "temp.txt"
    sed "/"$regex"/d" "$file" > "temp.txt"
    cat "temp.txt" > $file
    rm "temp.txt"
    viewTrash
}


#  Работа с временными файлами в тихом режиме
tempFileMod() {
	echo "Temp file mod"
	if [ ${params[2]} == "show" ]; then
		viewTrash
	elif [ ${params[2]} == "set" ]; then
		setTemp
	elif [[ ${params[2]} == "view" && ${params[3]} == "sizes" ]]; then
		showTrashValue
	elif [[ ${params[2]} == "add" && ${params[3]} == "exp" ]]; then
		addTempExp
	elif [[ ${params[2]} == "del" && ${params[3]} == "exp" ]]; then
		delTempExp
	elif [[ ${params[2]} == "del" ]]; then
		rmTempFiles
	fi
}


#  Инициализация рабочей папки в тихом режиме
setWorkF() {
	echo "Set work"
	local file=$(sed -n 2p $confname)
	rm $file
	touch $file
	local i=3
	while [ $i -lt $colParams ]; do
		ex=${params[$i]}
		echo $ex >> $file
		let i++
	done
	echo "New list of expansions:"
	viewWork
}


#  Добавление рабочего расширения в тихом режиме
addWorkExpF() {
	local file=$(sed -n 2p $confname)
	local newExp=${params[4]}
	echo $newExp >> $file
	viewWork
}


#  Функция для удаления рабочего расширения в тихом режиме
delWorkExpF() {
	local file=$(sed -n 2p $confname)
	regex=${params[4]}
    touch "temp.txt"
    sed "/"$regex"/d" "$file" > "temp.txt"
    cat "temp.txt" > $file
    rm "temp.txt"
    viewTrash
}


#  Функция для работы с рабочими файлами в тихом режиме
workFilesMod() {
	if [ ${params[2]} == "show" ]; then
		viewWork
	elif [[ ${params[2]} == "set" ]]; then
		setWorkF
	elif [[ ${params[2]} == "add" && ${params[3]} == "exp" ]]; then
		addWorkExpF
	elif [[ ${params[2]} == "del" && ${params[3]} == "exp" ]]; then
		delWorkExpF
	elif [[ ${params[2]} == "show" && ${params[3]} == "lines" ]]; then
		showStrings
	fi
}


#  Функция для смены рабочей папки в тихом режиме
ChangeWorkFolderF() {
	DIR=$( cd $(dirname $0) ; pwd)
	newDir=${params[3]}
	mv $DIR $newDir
	cd $newDir
	echo "Your current place:"
	DIR=$( cd $(dirname $0) ; pwd)
	echo $DIR
}


#  Функция для работы с рабочей папкой в тихом режиме
workFolderMod() {
	optinon=${params[2]}
	if [ $optinon == "show" ]; then
		viewWorkFolder
	elif [ $optinon == "change" ]; then
		ChangeWorkFolderF
	elif [ $optinon == "set" ]; then
		SetWorkFolder
	fi
}


#  Функция для редактирования команды пользователя в тихом режиме
EditUserCommandF() {
	userCommand=${params[3]}
	file1=$(sed -n 1p $confname)
	file2=$(sed -n 2p $confname)
	rm $confname
	touch $confname
	echo $file1 >> $confname
	echo $file2 >> $confname
	echo $userCommand >> $confname
	launchUserCommand
}



#  Функция для работы с командой пользоваетеля в тихом режиме
userCommandMod() {
	if [[ ${params[2]} == "launch" ]]; then
		launchUserCommand
	elif [[ ${params[2]} == "edit" ]]; then
		EditUserCommand
	fi
}


#  Функция для работы в тихом режиме
non-menumod() {
	echo "You are in non-menumod"
	if [[ ${params[0]} == "temp" && ${params[1]} == "files" ]]; then
		tempFileMod
	elif [[ ${params[0]} == "work" && ${params[1]} == "files" ]]; then
		workFilesMod
	elif [[ ${params[0]} == "work" && ${params[1]} == "folder" ]]; then
		workFolderMod
	elif [[ ${params[0]} == "user" && ${params[1]} == "command" ]]; then
		userCommandMod
	fi
	exit 0
}


clear
confCheck
adminCheck
paramCheck $*
#  echo $e
while true; do
	if [ $e -eq 0 ]; then
		menumod
		setOption
	else
		params=($*)
		colParams=$#
		non-menumod
	fi
done
