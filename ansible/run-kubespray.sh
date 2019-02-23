#!/bin/bash
ansible-playbook -b -i env-dev/hosts.ini cluster.yml
