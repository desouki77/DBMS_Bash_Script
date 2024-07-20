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


connect_database() {
    dbname=$(zenity --entry --title="Connect to Database" --text="Enter database name to connect:")
    if [ -d "$dbname" ]; then
        cd "$dbname"
        zenity --info --title="Connected" --text="Connected to $dbname."
        database_menu
    else
        zenity --error --title="Error" --text="Database $dbname does not exist."
    fi
}

drop_database() {
    dbname=$(zenity --entry --title="Drop Database" --text="Enter database name to drop:")
    if [ -d "$dbname" ]; then
        rm -r "$dbname"
        zenity --info --title="Database Dropped" --text="Database $dbname dropped."
    else
        zenity --error --title="Error" --text="Database $dbname does not exist."
    fi
}


create_table() {
    tablename=$(zenity --entry --title="Create Table" --text="Enter table name:")
    columns=$(zenity --entry --title="Create Table" --text="Enter columns (name:type, ...):")
    pk=$(zenity --entry --title="Create Table" --text="Enter primary key column:")
    if [ -n "$tablename" ] && [ -n "$columns" ] && [ -n "$pk" ]; then
        echo "$columns,primary_key:$pk" > "$tablename"
        zenity --info --title="Table Created" --text="Table $tablename created."
    else
        zenity --error --title="Error" --text="Incomplete table details provided."
    fi
}

list_tables() {
    tables=$(ls)
    if [ -n "$tables" ]; then
        zenity --list --title="Available Tables" --column="Tables" $tables
    else
        zenity --info --title="No Tables" --text="No tables found."
    fi
}


drop_table() {
    tablename=$(zenity --entry --title="Drop Table" --text="Enter table name to drop:")
    if [ -f "$tablename" ]; then
        rm "$tablename"
        zenity --info --title="Table Dropped" --text="Table $tablename dropped."
    else
        zenity --error --title="Error" --text="Table $tablename does not exist."
    fi
}

insert_table() {
    tablename=$(zenity --entry --title="Insert into Table" --text="Enter table name:")
    if [ -f "$tablename" ]; then
        columns=$(head -1 "$tablename")
        IFS=',' read -r -a colarray <<< "$columns"
        values=""
        for col in "${colarray[@]}"; do
            colname=$(echo $col | cut -d':' -f1)
            value=$(zenity --entry --title="Insert into Table" --text="Enter value for $colname:")
            values+="$value,"
        done
        values=${values::-1}  # Remove trailing comma
        echo "$values" >> "$tablename"
        zenity --info --title="Data Inserted" --text="Data inserted into $tablename."
    else
        zenity --error --title="Error" --text="Table $tablename does not exist."
    fi
}


select_table() {
    tablename=$(zenity --entry --title="Select from Table" --text="Enter table name:")
    if [ -f "$tablename" ]; then
        data=$(column -t -s "," < "$tablename")
        zenity --text-info --title="Table Data" --filename=<(echo "$data")
    else
        zenity --error --title="Error" --text="Table $tablename does not exist."
    fi
}

delete_table() {
    tablename=$(zenity --entry --title="Delete from Table" --text="Enter table name:")
    if [ -f "$tablename" ]; then
        pkvalue=$(zenity --entry --title="Delete from Table" --text="Enter primary key value to delete:")
        pkcol=$(head -1 "$tablename" | tr ',' '\n' | grep -n 'primary_key' | cut -d: -f1)
        awk -F, -v pkcol="$pkcol" -v pkvalue="$pkvalue" 'NR==1 || $pkcol != pkvalue' "$tablename" > tmp && mv tmp "$tablename"
        zenity --info --title="Record Deleted" --text="Record with primary key $pkvalue deleted from $tablename."
    else
        zenity --error --title="Error" --text="Table $tablename does not exist."
    fi
}


update_table() {
    tablename=$(zenity --entry --title="Update Table" --text="Enter table name:")
    if [ -f "$tablename" ]; then
        pkvalue=$(zenity --entry --title="Update Table" --text="Enter primary key value to update:")
        pkcol=$(head -1 "$tablename" | tr ',' '\n' | grep -n 'primary_key' | cut -d: -f1)
        columns=$(head -1 "$tablename")
        IFS=',' read -r -a colarray <<< "$columns"
        updated_row=""
        for col in "${colarray[@]}"; do
            colname=$(echo $col | cut -d':' -f1)
            value=$(zenity --entry --title="Update Table" --text="Enter new value for $colname:")
            updated_row+="$value,"
        done
        updated_row=${updated_row::-1}  # Remove trailing comma
        awk -F, -v pkcol="$pkcol" -v pkvalue="$pkvalue" -v new_row="$updated_row" 'BEGIN{OFS=","} {if($pkcol==pkvalue) print new_row; else print $0}' "$tablename" > tmp && mv tmp "$tablename"
        zenity --info --title="Record Updated" --text="Record with primary key $pkvalue updated in $tablename."
    else
        zenity --error --title="Error" --text="Table $tablename does not exist."
    fi
}
