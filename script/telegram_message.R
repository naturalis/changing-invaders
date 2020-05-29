#!/usr/bin/env Rscript
# function to send telegram message
# the bash program:
# first ask for the Telegram token, and chat id
# then find all files that could use telegram codes
# then replace in these files:
#  "TOKEN" by the actual token inputed first
# chat_id by the actual chat id (and not 0)
# uncomment lines that: load the telegram package
#  create a telegram bot object
#  and sent a message
# this is all prefixed by confusion=1#; because R views it as making confusion 1, followed by a comment ;read... etc.
# bash views # only as a comment when it is preceded by a (white)space character
# so in bash one is defining confusion as 1#. since the following character is a;, bash starts executing the next word
# as a new normal command: read -p ...
# the last command on the line is exit
# this is useful because it tells bash to exit, so it wont execute commands that are for the R part of this file
# it wont do much, but it will give some errors, we can bypass this way
confusion=1#;read -p "Telegram Token: " token;read -p "Telegram chat id: " chatid;find -type f |grep -v README.md\$|grep -Ev './(.git|doc)/'|xargs sed -Ei -e 's/(TGBot *\$ *new\(token *= *)"TOKEN"/\1"'"$token"'"/' -e 's/(\$ *(sendMessage|sendPhoto) *\( *.*\<chat_id\> *= *)[0-9]+/\1'$chatid'/' -e 's/# (.*library\( *telegram *\))/\1/' -e 's/# (.*TGBot *\$ *new\(token *=)/\1/' -e 's/# (.*\$ *sendMessage *\( *.*\<chat_id\> *=)/\1/';exit
boodschap <- commandArgs(trailingOnly=TRUE)[1]
send_telegram_message <- function(text) {
# 	library(telegram)
# 	bot <- telegram::TGBot$new(token = "TOKEN")
# 	bot$sendMessage(text = text, chat_id = 0)
	invisible(NULL)
}
send_telegram_message(boodschap)
