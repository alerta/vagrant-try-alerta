#!/usr/bin/env bash

zypper removerepo systemsmanagement-chef
zypper removerepo systemsmanagement-puppet

zypper refresh

zypper --non-interactive install git curl wget
