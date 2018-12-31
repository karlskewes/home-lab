#!/bin/bash

## Ansible directory structure init script. 
##
## What this script does:
## 1. Create Base Environment directory to contain variables that are shared per environment.
## 2. Create per Environment directories to contain environment specific variables and overrides.
## 3. Create hosts file per Environment. 
## 4. Link Base Environment cross-env variables to each environment. 
##
## How to use:
## 1. Define your environments and host file extension. 
## 2. Run script.
##
## Note: This won't create a 'host_vars/all/000_cross_env_vars' symlink as 'group_vars/all' will suffice.

## Declare environments array
declare -a environments=("dev")
host_file_extension=".yml" # Change to ".yml" or empty "" if you prefer.

## Create base environment folders
mkdir -p env-base/{group_vars,host_vars}/all
# Create 000_cross_env_vars file for Ansible 'all' group in base. 
echo -e "---\n# Place group variables shared across all environments here" >>  env-base/group_vars/all/000_cross_env_vars.yml

## Loop through environments
for env in "${environments[@]}"
do
  echo "Setting up '$env' environment"
   
  # Create environment directories
  mkdir -p env-${env}/{group_vars,host_vars}/all

  # Create environment specific Ansible 'all' group and host vars files per env. 
  touch env-${env}/{group_vars,host_vars}/all/env_specific.yml

  # Create environment hosts file
  touch "env-${env}/hosts${host_file_extension}"
  
  # Link 000_cross_env_vars from base to each env. 
  ln -s ../../../env-base/group_vars/all/000_cross_env_vars.yml "env-${env}/group_vars/all/000_cross_env_vars.yml"

done
