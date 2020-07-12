###################################################
#
# Makefile to ease the stack managment
#
###################################################

-include .env
include ./make.d/colors.make
include ./make.d/strings.make

.DEFAULT_GOAL := help

THIS_FILE := $(lastword $(MAKEFILE_LIST))
WHOAMI := $$(whoami)

help:
	@printf "\n${YELLOW}Go to https://github.com/XSlender/srv-docker-minecraft for documentation.${RESET}\n\n"

up:
	@printf "${GREEN}Waking ${PROJECT_NAME}...${RESET}\n"
	@printf "${GREEN}${DOTTED_LINE}${RESET}\n"
	@docker-compose up -d
	@printf "\n"

down:
	@printf "${YELLOW}shutting down ${PROJECT_NAME}...${RESET}\n"
	@printf "${YELLOW}${DOTTED_LINE}${RESET}\n"
	@docker-compose down

build:
	@printf "${GREEN}Building ${PROJECT_NAME}...${RESET}\n"
	@printf "${GREEN}${DOTTED_LINE}${RESET}\n"
	@docker-compose build

launch:
	@printf "${GREEN}Launching ${PROJECT_NAME}...${RESET}\n"
	@printf "${GREEN}${DOTTED_LINE}${RESET}\n"
	@docker-compose up --build -d

.ONESHELL:
init:
	@clear
	@printf "Welcome to the quick minecraft-docker setup. \\o/\n"
	@printf "\n"
	@printf "This will guide you through the first launch of the stack, asking you some\n"
	@printf "questions andbuilding for you all the mandatory stuff.\n"
	@printf "\n"
	@printf "${BLUE}Stay calm, get a cup of coffee, and let start.${RESET}\n"
	@printf "\n"
	@printf "${BLUE}First, let's obtain sudo permissions${RESET}\n"
	@sudo ls > /dev/null
	@printf "\n"
	@printf "${BLUE}Now, let's complete some info about the project${RESET}\n"
	@printf "\n"
	## interactive variables definitinon
	@COMPOSE_PROJECT_NAME=""
	@DOMAIN=""
	@SERVER_PORT=""
	@SERVER_NAME=""
	@RAM_MEMORY=""
	## interactive
	@read -p "${YELLOW}Project name: ${RESET}" COMPOSE_PROJECT_NAME
	@read -p "${YELLOW}Domain of the server (aka minecraft.example.com): ${RESET}" DOMAIN
	@read -p "${YELLOW}Server port: ${RESET}" SERVER_PORT
	@read -p "${YELLOW}Server name: ${RESET}" SERVER_NAME
	@read -p "${YELLOW}RAM allowed (ex 2G): ${RESET}" RAM_MEMORY

	## env file creation
	@printf "\n"
	@printf "Generating environment file..."
	@rm .env 2> /dev/null 
	@cp -f env.d/.env.dist .env

	## replacing vars in environment file
	@sed -i "s~COMPOSE_PROJECT_NAME=~COMPOSE_PROJECT_NAME=$${COMPOSE_PROJECT_NAME}~g" .env
	@sed -i "s~DOMAIN=~DOMAIN=$${DOMAIN}~g" .env
	@sed -i "s~SERVER_PORT=~SERVER_PORT=$${SERVER_PORT}~g" .env
	@sed -i "s~SERVER_NAME=~SERVER_NAME=$${SERVER_NAME}~g" .env
	@sed -i "s~RAM_MEMORY=~RAM_MEMORY=$${RAM_MEMORY}~g" .env
	@printf "\t${GREEN}done${RESET}\n"

	## create run folders
	@printf "Generating run folders..."
	@sudo mkdir -p $$PWD/run/minecraft 2> /dev/null 
	@printf "\t${GREEN}done${RESET}\n"

	## Enabling firewall
	@printf "Generating run folders..."
	@sudo ufw allow $$SERVER_PORT comment "Minecraft server $$SERVER_NAME" 2> /dev/null 
	@printf "\t${GREEN}done${RESET}\n"

	## building machines
	@printf "\n"
	@printf "${BLUE}Now let's build some containers.${RESET}\n"
	@printf "\n"
	@docker-compose build
	## launching containers
	@printf "\n"
	@printf "${BLUE}Let's rev it up !${RESET}\n"
	@printf "\n"
	@docker-compose up -d
	@printf "\n"
	@printf "\t${GREEN}--- Yay ! $${COMPOSE_PROJECT_NAME} is started and ready ! ---${RESET}\n"
	@printf "\n"
	@printf "${BLUE}Server connection :${RESET} $$DOMAIN\n"
	@printf "${YELLOW}You can find back this list with 'make connect-help'${RESET}\n"
	@printf "\n"

connect-help:
	@printf "${BLUE}Listing access for ${COMPOSE_PROJECT_NAME}...${RESET}\n"
	@printf "${BLUE}${DOTTED_LINE}${RESET}\n"
	@printf "${BLUE}Server connection :${RESET} $$DOMAIN\n"
	@printf "\n"

exec:
	@printf "${BLUE}Connecting to ${COMPOSE_PROJECT_NAME}...${RESET}\n"
	@printf "${BLUE}${DOTTED_LINE}${RESET}\n"
	@docker exec -ti ${COMPOSE_PROJECT_NAME}-minecraft rcon-cli