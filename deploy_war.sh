#!/usr/bin/env 

# export JETTY_DIR="/jetty/"
# export TRANSLATION_PROJECT_ROOT="/translation-tool/translation-tool"

WAR_DEFAULT_NAME="ROOT"
NEW_WAR_DEFAULT_NAME="translations"
DEFAULT_APP_URL="http://localhost:8080/translations/test/"

if [[ -z "$JETTY_DIR" ]]; then
	echo "Specify jetty home dir variable - $JETTY_DIR in your .bashrc"
	exit
	if [[ -z "$TRANSLATION_PROJECT_ROOT" ]]; then
		echo "Specify project root dir variable - $TRANSLATION_PROJECT_ROOT in your .bashrc"
		exit
	fi
fi

cd ${HOME}${TRANSLATION_PROJECT_ROOT}
WARS_NUM=`ls ${HOME}${TRANSLATION_PROJECT_ROOT}/dist | egrep "^.+\.war$" | wc -l`

if [[ "$2" -eq "rebuild" ]]; then
	cd ${HOME}${TRANSLATION_PROJECT_ROOT}
	bash -c "ant war"
	wait
else
	echo "no ant rebuild selected" 
fi

if [[ $WARS_NUM -ne "0" ]]; then
	echo "OK, found "$WARS_NUM" war in dist dir"
	if [ -z "$1" ]; then
		echo "no war name given, i'll use translations.war"
		cp ${HOME}${TRANSLATION_PROJECT_ROOT}/dist/${WAR_DEFAULT_NAME}.war ${HOME}${JETTY_DIR}/webapps/${NEW_WAR_DEFAULT_NAME}.war
		bash ${HOME}${JETTY_DIR}bin/jetty.sh restart
		wait
		# нужно будет пофиксить - в chrome загружается не с первого раза, похоже на какой-то таймаут
		x-www-browser $DEFAULT_APP_URL
		wait
	else	
		cp ${HOME}${TRANSLATION_PROJECT_ROOT}/dist/${WAR_DEFAULT_NAME}.war ${HOME}${JETTY_DIR}/webapps/$1.war
		bash ${HOME}${JETTY_DIR}bin/jetty.sh restart
		wait
		# нужно будет пофиксить - в chrome загружается не с первого раза, похоже на какой-то таймаут
		x-www-browser $DEFAULT_APP_URL
		wait
	fi	
else
	echo "Nothing to deploy here"
fi
