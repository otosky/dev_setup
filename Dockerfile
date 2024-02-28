FROM ubuntu:22.04

RUN apt update -y && apt upgrade -y && apt install curl git make build-essential sudo -y

RUN adduser --gecos "" --disabled-password ubuntu && usermod -aG sudo ubuntu && echo 'ubuntu:ubuntu' | chpasswd

USER ubuntu

