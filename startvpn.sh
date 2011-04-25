#!/bin/bash


    ############
    # SETTINGS #
    ############

get_connections_paths()
{
    dbus-send --system --print-reply --dest="$1" "/org/freedesktop/NetworkManagerSettings" "org.freedesktop.NetworkManagerSettings.ListConnections" \
    | grep "object path" | cut -d '"' -f2
}

get_connection_settings()
{
    dbus-send --system --print-reply --dest="$1" "$2" org.freedesktop.NetworkManagerSettings.Connection.GetSettings
}

get_connection_string_setting()
{
    echo "$1" | grep -A 1 \""$2"\" | grep variant | cut -d '"' -f2
}

get_connection_id()
{
    get_connection_string_setting "$1" "id"
}

get_connection_type()
{
    get_connection_string_setting "$1" "type"
}

get_device_type_by_connection_type()
{
    echo "$1" | grep -q "ethernet" && echo 1 && return
    echo "$1" | grep -q "wireless" && echo 2 && return
    echo 0
}

find_connection_path()
{
    for connection_path in `get_connections_paths "$1"`
    do
        connection_settings=`get_connection_settings "$1" "$connection_path"`
        connection_settings_id=`get_connection_id "$connection_settings"`
        [ "$connection_settings_id" = "$2" ] && echo "$1" "$connection_path"
    done
}

find_connection_path_everywhere()
{
    find_connection_path "org.freedesktop.NetworkManagerSystemSettings" "$1"
    find_connection_path "org.freedesktop.NetworkManagerUserSettings" "$1"
}

print_connections_ids()
{
    for connection_path in `get_connections_paths "$1"`
    do
        connection_settings=`get_connection_settings "$1" "$connection_path"`
        connection_settings_id=`get_connection_id "$connection_settings"`
        echo "$connection_settings_id"
    done
}

print_connections_ids_everywhere()
{
    print_connections_ids "org.freedesktop.NetworkManagerSystemSettings"
    print_connections_ids "org.freedesktop.NetworkManagerUserSettings"
}


    ###########
    # DEVICES #
    ###########

get_devices_paths()
{
    dbus-send --system --print-reply --dest="org.freedesktop.NetworkManager" "/org/freedesktop/NetworkManager" "org.freedesktop.NetworkManager.GetDevices" \
    | grep "object path" | cut -d '"' -f2
}

get_device_property()
{
    dbus-send --system --print-reply --dest="org.freedesktop.NetworkManager" "$1" "org.freedesktop.DBus.Properties.Get" string:"org.freedesktop.NetworkManager.Device" string:"$2" \
    | grep variant | awk '{print $3}'
}

get_device_type()
{
    get_device_property "$1" "DeviceType"
}

get_device_path_by_device_type()
{
    device_path_by_device_type="/"
    for device_path in `get_devices_paths`
    do
        device_type=`get_device_type "$device_path"`
        [ "$device_type" = "$1" ] && device_path_by_device_type="$device_path"
    done
    echo "$device_path_by_device_type"
}


    #######################
    # ACTIVES CONNECTIONS #
    #######################

get_actives_connections_paths()
{
    dbus-send --system --print-reply --dest="org.freedesktop.NetworkManager" "/org/freedesktop/NetworkManager" "org.freedesktop.DBus.Properties.Get" string:"org.freedesktop.NetworkManager" string:"ActiveConnections" \
    | grep "object path" | cut -d '"' -f2
}

get_last_active_connection_path()
{
    get_actives_connections_paths | tail -n 1
}

get_parent_connection_path_by_device_type()
{
    parent_connection_path="/"
    [ "$1" = 0 ] && parent_connection_path=`get_last_active_connection_path`
    echo "$parent_connection_path"
}

get_active_connection_property()
{
    dbus-send --system --print-reply --dest="org.freedesktop.NetworkManager" "$1" "org.freedesktop.DBus.Properties.Get" string:"org.freedesktop.NetworkManager.Connection.Active" string:"$2" \
    | grep variant | awk -F '"' '{print $2}'
}

get_active_connection_service()
{
    get_active_connection_property "$1" "ServiceName"
}

get_active_connection_path()
{
    get_active_connection_property "$1" "Connection"
}

get_active_connection_path_by_connection_path()
{
    for active_connection_path in `get_actives_connections_paths`
    do
        service=`get_active_connection_service $active_connection_path`
        path=`get_active_connection_path $active_connection_path`
        [ "$service" = "$1" ] && [ "$path" = "$2" ] && echo "$active_connection_path"
    done
}

print_actives_connections_ids()
{
    for active_connection_path in `get_actives_connections_paths`
    do
        service=`get_active_connection_service $active_connection_path`
        path=`get_active_connection_path $active_connection_path`
        connection_settings=`get_connection_settings "$service" "$path"`
        connection_settings_id=`get_connection_id "$connection_settings"`
        echo "$connection_settings_id"
    done
}


    ##############
    # START/STOP #
    ##############

start_connection()
{
    my_connection_complete_path=`find_connection_path_everywhere "$1"`
    my_connection_settings=`get_connection_settings $my_connection_complete_path`
    my_connection_type=`get_connection_type "$my_connection_settings"`
    my_connection_device_type=`get_device_type_by_connection_type "$my_connection_type"`
    
    my_connection_service=`echo $my_connection_complete_path | awk '{print $1}'`
    my_connection_path=`echo $my_connection_complete_path | awk '{print $2}'`
    my_connection_device_path=`get_device_path_by_device_type "$my_connection_device_type"`
    my_parent_connection_path=`get_parent_connection_path_by_device_type "$my_connection_device_type"`
    
    echo "connection_service=$my_connection_service"
    echo "connection_path=$my_connection_path"
    echo "connection_device_path=$my_connection_device_path"
    echo "parent_connection_path=$my_parent_connection_path"
    
    dbus-send --system --print-reply --dest="org.freedesktop.NetworkManager" /org/freedesktop/NetworkManager "org.freedesktop.NetworkManager.ActivateConnection" string:"$my_connection_service" objpath:"$my_connection_path" objpath:"$my_connection_device_path" objpath:"$my_parent_connection_path"
}

stop_connection()
{
    my_connection_complete_path=`find_connection_path_everywhere "$1"`
    my_active_connection_path=`get_active_connection_path_by_connection_path $my_connection_complete_path`
    
    echo "active_connection_path=$my_active_connection_path"
    
    dbus-send --system --print-reply --dest="org.freedesktop.NetworkManager" /org/freedesktop/NetworkManager "org.freedesktop.NetworkManager.DeactivateConnection" objpath:"$my_active_connection_path"
}


    ########
    # MAIN #
    ########

invalid_arguments()
{
    echo "Usage: `basename "$0"` connexion_name start|stop"
    echo "---Available Connections:"
    print_connections_ids_everywhere
    echo "---Active Connections:"
    print_actives_connections_ids
    exit 0
}

[ "$#" != 2 ] && invalid_arguments

case "$2" in
    "start")
        start_connection "$1"
        ;;
    "stop")
        stop_connection "$1"
        ;;
    *)
        invalid_arguments
        ;;
esac
