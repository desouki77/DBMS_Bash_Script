#!/bin/bash


create_database() {
    dbname=$(zenity --entry --title="Create Database" --text="Enter database name:")
    if [ -n "$dbname" ]; then
        mkdir "$dbname"
        zenity --info --title="Database Created" --text="Database $dbname created."
    else
        zenity --error --title="Error" --text="No database name provided."
    fi
}

list_databases() {
    databases=$(ls -d */)
    if [ -n "$databases" ]; then
        zenity --list --title="Available Databases" --column="Databases" $databases
    else
        zenity --info --title="No Databases" --text="No databases found."
    fi
}
